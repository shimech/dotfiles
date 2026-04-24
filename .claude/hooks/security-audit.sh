#!/usr/bin/env bash
# Log suspicious Bash commands without blocking (log-only mode).
# Output: ~/.claude/security-audit.log

set -uo pipefail

LOG_FILE="${HOME}/.claude/security-audit.log"
input=$(cat)
cmd=$(printf '%s' "$input" | jq -r '.tool_input.command // empty' 2>/dev/null || true)

[[ -z "${cmd:-}" ]] && exit 0

patterns=(
  '\|[[:space:]]*(sh|bash|zsh)([[:space:]]|$)'
  '(curl|wget)[[:space:]].+\|[[:space:]]*(sh|bash|zsh)'
  '\beval[[:space:]]+.*\$\('
  'rm[[:space:]]+(-[rfRF]+[[:space:]]+)+(/|~|\$HOME)([[:space:]]|$)'
  'rm[[:space:]]+(-[rfRF]+[[:space:]]+)+/(usr|var|etc|System|Library|bin|sbin|boot|opt|home|Users)'
  '(cat|less|more|head|tail|grep)[[:space:]].+\.(ssh|aws|gnupg)/'
  '>[[:space:]]*~?/?\.(bashrc|zshrc|profile|zprofile|bash_profile)'
  '\$\([[:space:]]*curl'
  '`[[:space:]]*curl'
  'chmod[[:space:]]+(-[rR]+[[:space:]]+)?[0-9]*7[0-9]*[[:space:]]+/'
)

matched=()
for pattern in "${patterns[@]}"; do
  if printf '%s' "$cmd" | grep -Eq -- "$pattern"; then
    matched+=("$pattern")
  fi
done

if [[ ${#matched[@]} -gt 0 ]]; then
  ts=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
  {
    echo "[$ts] SUSPICIOUS_CMD"
    echo "  command: $cmd"
    for m in "${matched[@]}"; do
      echo "  matched: $m"
    done
  } >> "$LOG_FILE"
fi

exit 0
