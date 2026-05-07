#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.bun/bin:$HOME/.npm-global/bin:$HOME/go/bin:$HOME/.cargo/bin:$PATH"

missing=0

for tool in agent-browser gh jq vhs silicon ffmpeg ast-grep; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf 'OK   %-14s %s\n' "$tool" "$(command -v "$tool")"
  else
    printf 'MISS %-14s\n' "$tool"
    missing=1
  fi
done

if [ -f "$HOME/.agents/skills/ast-grep/SKILL.md" ]; then
  printf 'OK   %-14s %s\n' "ast-grep skill" "$HOME/.agents/skills/ast-grep/SKILL.md"
else
  printf 'MISS %-14s\n' "ast-grep skill"
  missing=1
fi

if find "$HOME/.codex/skills" "$HOME/.codex/prompts" -maxdepth 4 -type f 2>/dev/null | grep -Eq '/ce-setup/|ce-setup'; then
  printf 'OK   %-14s %s\n' "CE plugin" "$HOME/.codex"
else
  printf 'MISS %-14s\n' "CE plugin"
  missing=1
fi

exit "$missing"
