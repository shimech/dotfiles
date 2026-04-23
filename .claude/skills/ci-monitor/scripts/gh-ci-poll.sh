#!/usr/bin/env bash
# CIが完了するまでポーリングし、完了時にgh-ci-status.shの結果を返す読み取り専用ラッパー
# Usage: gh-ci-poll.sh [--repo <owner/repo>] [--branch <branch>] [--interval <seconds>]
#
# run_in_background で実行することを想定。
# 終了条件: 1つでも失敗が確定 or 全check完了。結果を1回だけ出力する。

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO=""
BRANCH=""
INTERVAL=20
REPO_FLAG=""
BRANCH_FLAG=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repo)
      REPO="$2"
      REPO_FLAG="--repo $2"
      shift 2
      ;;
    --branch)
      BRANCH="$2"
      BRANCH_FLAG="--branch $2"
      shift 2
      ;;
    --interval)
      INTERVAL="$2"
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

while true; do
  CHECKS=$(gh pr checks "$BRANCH" --repo "$REPO" --json state,bucket 2>/dev/null || true)

  if [[ -z "$CHECKS" || "$CHECKS" == "[]" ]]; then
    sleep "$INTERVAL"
    continue
  fi

  HAS_FAILURE=$(echo "$CHECKS" | jq '[.[] | select(.bucket == "fail")] | length')
  STILL_RUNNING=$(echo "$CHECKS" | jq '[.[] | select(.bucket == "pending")] | length')

  # 1つでも失敗 or 全完了で終了
  if [[ "$HAS_FAILURE" != "0" || "$STILL_RUNNING" == "0" ]]; then
    bash "${SCRIPT_DIR}/gh-ci-status.sh" $REPO_FLAG $BRANCH_FLAG
    break
  fi

  sleep "$INTERVAL"
done
