#!/usr/bin/env bash
set -euo pipefail

# Codex Cloud maintenance script for cached containers.
# Use this when Codex resumes a cached environment. It refreshes the plugin
# conversion and verifies tools without repeating heavyweight package installs.

export CI="${CI:-true}"
export PATH="$HOME/.bun/bin:$HOME/.npm-global/bin:$HOME/go/bin:$HOME/.cargo/bin:$PATH"

if command -v bunx >/dev/null 2>&1; then
  bunx @every-env/compound-plugin install compound-engineering --to codex
else
  printf 'WARN: bunx not found; skipping Compound Engineering refresh.\n' >&2
fi

for tool in agent-browser gh jq vhs silicon ffmpeg ast-grep; do
  if command -v "$tool" >/dev/null 2>&1; then
    printf 'OK   %s\n' "$tool"
  else
    printf 'MISS %s\n' "$tool"
  fi
done

if [ -f "$HOME/.agents/skills/ast-grep/SKILL.md" ]; then
  printf 'OK   ast-grep skill\n'
else
  printf 'MISS ast-grep skill\n'
fi
