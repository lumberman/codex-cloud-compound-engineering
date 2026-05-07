#!/usr/bin/env bash
set -euo pipefail

export PATH="$HOME/.local/bin:$HOME/.bun/bin:$HOME/.npm-global/bin:$HOME/go/bin:$HOME/.cargo/bin:$PATH"

missing=0

compound_engineering_installed() {
  [ -f "$HOME/.codex/.compound-engineering-installed" ] \
    || [ -f "$HOME/.codex/plugins/compound-engineering/.codex-plugin/plugin.json" ] \
    || [ -f "$HOME/.codex/plugins/compound-engineering/plugin.json" ] \
    || [ -f "$HOME/.codex/skills/compound-engineering/ce-setup/SKILL.md" ] \
    || [ -f "$HOME/.codex/skills/ce-setup/SKILL.md" ] \
    || [ -f "$HOME/.codex/prompts/ce-setup.md" ] \
    || find "$HOME/.codex" -maxdepth 6 -type f \( -path '*/compound-engineering/*/ce-setup/SKILL.md' -o -path '*/compound-engineering/.codex-plugin/plugin.json' \) 2>/dev/null | grep -q .
}

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

if compound_engineering_installed; then
  printf 'OK   %-14s %s\n' "CE plugin" "$HOME/.codex"
else
  printf 'MISS %-14s\n' "CE plugin"
  missing=1
fi

if command -v ce >/dev/null 2>&1; then
  printf 'OK   %-14s %s\n' "ce shell hint" "$(command -v ce)"
else
  printf 'MISS %-14s\n' "ce shell hint"
  missing=1
fi

exit "$missing"
