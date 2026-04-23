#!/usr/bin/env bash
# PRのcheck状態を表示し、失敗があれば詳細を自動取得する読み取り専用ラッパー
# Usage: gh-ci-status.sh [--repo <owner/repo>] [--branch <branch>]
#
# gh pr checks ベース。PRがない場合は check-runs API にフォールバック。
#
# 出力:
# - 全checkの status 一覧（ワークフロー名付き）
# - 失敗checkがあれば失敗ステップとアノテーション/ログを自動付与

set -euo pipefail

REPO=""
BRANCH=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO="$2"
      shift 2
      ;;
    --branch)
      BRANCH="$2"
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

if [[ -z "$BRANCH" ]]; then
  BRANCH=$(git branch --show-current 2>/dev/null) || {
    echo "Error: ブランチを特定できません。--branch を指定してください。" >&2
    exit 1
  }
fi

if [[ -z "$REPO" ]]; then
  REPO=$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null) || {
    echo "Error: リポジトリを特定できません。--repo owner/repo を指定してください。" >&2
    exit 1
  }
fi

REPO_FLAG="--repo ${REPO}"

SHA=$(git rev-parse --short HEAD 2>/dev/null || true)
echo "Branch: ${BRANCH}${SHA:+ (${SHA})}"
echo ""

# 1. gh pr checks でPRのcheck状態を取得
CHECKS=$(gh pr checks "$BRANCH" $REPO_FLAG --json name,state,workflow,link,bucket 2>/dev/null || true)

if [[ -z "$CHECKS" || "$CHECKS" == "[]" ]]; then
  # PRがない場合はcheck-runs APIにフォールバック
  SHA=$(git rev-parse HEAD 2>/dev/null || true)
  if [[ -n "$SHA" ]]; then
    CHECKS=$(gh api "repos/${REPO}/commits/${SHA}/check-runs" \
      --jq '[.check_runs[] | {name, state: .status, workflow: "", link: "", bucket: (if .conclusion == "success" then "pass" elif .conclusion == "failure" then "fail" else .conclusion // .status end)}]' 2>/dev/null || true)
  fi
fi

if [[ -z "$CHECKS" || "$CHECKS" == "[]" ]]; then
  echo "No checks found."
  exit 0
fi

# 2. ワークフロー名ごとに最新のみ残す（reruns対策）
CHECKS=$(echo "$CHECKS" | jq '[group_by(.workflow + "/" + .name) | .[] | last]')

# 3. check一覧を表示
echo "Checks:"
echo "$CHECKS" | jq -r '.[] | (
  (if .workflow != "" then "\(.workflow) / \(.name)" else .name end) as $display |
  if .bucket == "pass" then "✓ \($display)"
  elif .bucket == "fail" then "✗ \($display)"
  elif .bucket == "pending" then "⏳ \($display)"
  else "  \($display) (\(.bucket))"
  end
)'

# 4. 失敗checkの詳細を取得
FAILED=$(echo "$CHECKS" | jq -r '[.[] | select(.bucket == "fail")]')

if [[ "$FAILED" == "[]" ]]; then
  exit 0
fi

for ENTRY in $(echo "$FAILED" | jq -r '.[] | @base64'); do
  NAME=$(echo "$ENTRY" | base64 -d | jq -r '.name')
  WORKFLOW=$(echo "$ENTRY" | base64 -d | jq -r '.workflow')
  LINK=$(echo "$ENTRY" | base64 -d | jq -r '.link')

  if [[ "$WORKFLOW" != "" ]]; then
    DISPLAY="${WORKFLOW} / ${NAME}"
  else
    DISPLAY="$NAME"
  fi

  # linkからrun IDとjob IDを抽出
  RUN_ID=$(echo "$LINK" | sed -n 's|.*/runs/\([0-9]*\).*|\1|p')
  JOB_ID=$(echo "$LINK" | sed -n 's|.*/job/\([0-9]*\).*|\1|p')

  echo ""
  if [[ -n "$RUN_ID" ]]; then
    echo "--- ${DISPLAY} (run ${RUN_ID}) ---"
  else
    echo "--- ${DISPLAY} ---"
  fi

  # 失敗ステップを取得
  if [[ -n "$JOB_ID" ]]; then
    STEPS=$(gh api "repos/${REPO}/actions/jobs/${JOB_ID}" \
      --jq '[.steps[] | select(.conclusion == "failure") | .name] | join(", ")' 2>/dev/null || true)
    if [[ -n "$STEPS" ]]; then
      echo "  failed: $STEPS"
    fi
  fi

  # アノテーション取得
  ANNOTS=""
  if [[ -n "$JOB_ID" ]]; then
    ANNOTS=$(gh api "repos/${REPO}/check-runs/${JOB_ID}/annotations" \
      --jq '.[] | select(.annotation_level == "failure" or .annotation_level == "warning") | "  \(.path):\(.start_line) — \(.message)"' 2>/dev/null || true)
  fi

  if [[ -n "${ANNOTS:-}" ]]; then
    echo "$ANNOTS"
  elif [[ -n "$RUN_ID" ]]; then
    # アノテーションがない場合、失敗ログをフォールバック取得
    echo "  Logs:"
    gh run view "$RUN_ID" --repo "$REPO" --log-failed 2>/dev/null \
      | sed 's/\x1b\[[0-9;]*m//g' \
      | sed 's/^[0-9T:.Z-]* //' \
      | tail -200 \
      | sed 's/^/  /' || true
  fi
done
