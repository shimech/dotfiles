#!/usr/bin/env bash
# PRのフィードバック（レビュー＋インラインコメント）を一括取得する読み取り専用ラッパー
# Usage: gh-pr-feedback.sh [<number>] [--repo <owner/repo>]
#
# GraphQL API で reviews + reviewThreads (resolved 状態含む) を一括取得。
# 出力はAIフレンドリーなテキスト形式。構造と本文を "| " プレフィックスで分離。
# 各コメントにIDを付与し、返信操作を容易にする。
# ユーザータイプ（human/bot）を表示し、bot コメントの識別が可能。
# 読み取り専用（query のみ）で安全。

set -euo pipefail

PR_NUMBER=""
REPO_FLAG=""
REPO_VALUE=""
REPO=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      [[ $# -ge 2 ]] || { echo "Error: --repo requires a value" >&2; exit 1; }
      REPO_FLAG="--repo"
      REPO_VALUE="$2"
      REPO="$2"
      shift 2
      ;;
    *)
      PR_NUMBER="$1"
      shift
      ;;
  esac
done

if [[ -n "$PR_NUMBER" ]] && ! [[ "$PR_NUMBER" =~ ^[0-9]+$ ]]; then
  echo "Error: PR番号は数値で指定してください: $PR_NUMBER" >&2
  exit 1
fi

if [[ -z "$PR_NUMBER" ]]; then
  PR_NUMBER=$(gh pr view --json number --jq '.number' $REPO_FLAG $REPO_VALUE) || {
    echo "Error: 現在のブランチにPRが見つかりません。PR番号を指定してください。" >&2
    exit 1
  }
fi

if [[ -z "$REPO" ]]; then
  REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null) || {
    echo "Error: リポジトリを特定できません。--repo owner/repo を指定してください。" >&2
    exit 1
  }
fi

OWNER="${REPO%%/*}"
REPO_NAME="${REPO##*/}"

# GraphQL で reviews + reviewThreads を一括取得 (query のみ, read-only)
RESULT=$(gh api graphql -F owner="$OWNER" -F repo="$REPO_NAME" -F "pr=$PR_NUMBER" -f query='
query($owner: String!, $repo: String!, $pr: Int!) {
  repository(owner: $owner, name: $repo) {
    pullRequest(number: $pr) {
      reviews(first: 100) {
        pageInfo { hasNextPage }
        nodes {
          databaseId
          author { login __typename }
          state
          body
        }
      }
      comments(first: 100) {
        pageInfo { hasNextPage }
        nodes {
          databaseId
          author { login __typename }
          body
          createdAt
        }
      }
      reviewThreads(first: 100) {
        pageInfo { hasNextPage }
        nodes {
          isResolved
          comments(first: 100) {
            nodes {
              databaseId
              author { login __typename }
              body
              path
              line
              originalLine
              diffHunk
              createdAt
              pullRequestReview { databaseId }
            }
          }
        }
      }
    }
  }
}')

# 全セクションを単一の jq で出力
echo "$RESULT" | jq -r --arg pr "$PR_NUMBER" --arg repo "$REPO" '
# --- ヘルパー関数 ---
# bot 判定: author オブジェクトから "bot" / "human" を返す
def utype: if (.author.__typename // "") == "Bot" or ((.author.login // "") | test("\\[bot\\]$")) then "bot" else "human" end;
# 表示名: GraphQL の login に [bot] suffix がなければ付与
def login: (.author.login // "ghost") as $l | if utype == "bot" and ($l | test("\\[bot\\]$") | not) then $l + "[bot]" else $l end;
# 本文を "| " プレフィックス付きでインデント
def body_indent(prefix): split("\n") | join("\n" + prefix + "| ");

.data.repository.pullRequest as $pull |

"==== PR #\($pr) Feedback (\($repo)) ====",
"",
# truncation 警告
(
  [
    (if $pull.reviews.pageInfo.hasNextPage then "reviews" else empty end),
    (if $pull.comments.pageInfo.hasNextPage then "comments" else empty end),
    (if $pull.reviewThreads.pageInfo.hasNextPage then "reviewThreads" else empty end)
  ] |
  if length > 0 then "(Warning: \(join(", ")) は100件を超えています。出力は先頭100件に制限されています。)", "" else empty end
),

# --- Reviews ---
"[Reviews]",
"",
(
  [$pull.reviews.nodes // [] | .[] | select(.state != "PENDING" and .state != "DISMISSED") | select(.state != "COMMENTED" or ((.body // "") != ""))] |
  if length == 0 then "(レビューなし)"
  else
    group_by(.author.login // "ghost") | to_entries[] |
    .key as $idx | .value[-1] as $latest |
    (if $idx > 0 then "\n---\n" else empty end),
    "[@\($latest | login)] \($latest | utype) | \($latest.state) (review_id: \($latest.databaseId))" +
    (if ($latest.body // "") != "" then "\n  | " + ($latest.body | body_indent("  ")) else "" end)
  end
),
"",

# --- Comments（会話コメント） ---
"[Comments]",
"",
(
  [$pull.comments.nodes // [] | .[]] |
  if length == 0 then "(コメントなし)"
  else
    to_entries[] |
    .key as $idx | .value as $c |
    (if $idx > 0 then "\n---\n" else empty end),
    "[@\($c | login)] \($c | utype) (comment_id: \($c.databaseId))",
    ("  | " + ($c.body | body_indent("  ")))
  end
),
"",

# --- Inline Comments ---
"[Inline Comments]",
"",
(
  [$pull.reviewThreads.nodes // [] | .[] | .comments.nodes[0] as $root | {
    resolved: .isResolved,
    path: $root.path,
    comments: [.comments.nodes[] | {
      id: .databaseId,
      user: (. | login),
      user_type: (. | utype),
      line: (.line // .originalLine),
      diff_context: (.diffHunk // "" | split("\n") | .[-3:] | join("\n")),
      body: .body,
      review_id: (.pullRequestReview.databaseId // null)
    }]
  }] |
  if length == 0 then "(インラインコメントなし)"
  else
    group_by(.path)[] | . as $file_threads |
    "---- \(.[0].path) ----",
    "",
    (
      to_entries[] |
      .key as $idx | .value as $thread |
      $thread.comments[0] as $root |
      (if $idx > 0 then "---" else empty end),
      (
        (if $thread.resolved then "[RESOLVED] " else "" end) +
        "[comment_id: \($root.id)] @\($root.user) (\($root.user_type)) | L\($root.line // "?") | review: \($root.review_id // "?")",
        ($root.diff_context | if . != "" then "  > " + (split("\n") | join("\n  > ")) else empty end),
        ("  | " + ($root.body | body_indent("  "))),
        (
          $thread.comments[1:][] |
          "  \u21b3 [comment_id: \(.id)] @\(.user) (\(.user_type))",
          ("    | " + (.body | body_indent("    ")))
        ),
        ""
      )
    )
  end
)'
