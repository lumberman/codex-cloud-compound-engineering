#!/usr/bin/env bash
set -euo pipefail

# Codex Cloud setup script for the Compound Engineering plugin.
# Paste this into a Codex Cloud environment setup script, or commit it and call:
#   bash codex-cloud-compound-engineering/setup.sh

export DEBIAN_FRONTEND="${DEBIAN_FRONTEND:-noninteractive}"
export CI="${CI:-true}"

log() {
  printf '\n==> %s\n' "$*"
}

warn() {
  printf 'WARN: %s\n' "$*" >&2
}

have() {
  command -v "$1" >/dev/null 2>&1
}

as_root() {
  if [ "$(id -u)" -eq 0 ]; then
    "$@"
  elif have sudo; then
    sudo "$@"
  else
    warn "Need root privileges for: $*"
    return 1
  fi
}

append_once() {
  local line="$1"
  local file="$2"
  mkdir -p "$(dirname "$file")"
  touch "$file"
  if ! grep -Fqx "$line" "$file"; then
    printf '%s\n' "$line" >> "$file"
  fi
}

export PATH="$HOME/.bun/bin:$HOME/.npm-global/bin:$HOME/go/bin:$HOME/.cargo/bin:$PATH"
append_once 'export PATH="$HOME/.bun/bin:$HOME/.npm-global/bin:$HOME/go/bin:$HOME/.cargo/bin:$PATH"' "$HOME/.bashrc"

install_apt_base() {
  if ! have apt-get; then
    warn "apt-get not found. Skipping Debian/Ubuntu package installation."
    return 0
  fi

  log "Installing base packages with apt"
  as_root apt-get update
  as_root apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    gnupg \
    jq \
    unzip \
    xz-utils \
    build-essential \
    pkg-config \
    golang-go \
    ffmpeg \
    libfontconfig1-dev \
    libfreetype6-dev \
    libharfbuzz-dev \
    libxcb1-dev \
    libx11-dev \
    libxext-dev \
    libxrender-dev \
    libpng-dev \
    libonig-dev
}

install_gh() {
  if have gh; then
    return 0
  fi

  if have apt-get; then
    log "Installing GitHub CLI"
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | as_root dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg >/dev/null
    as_root chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
    printf 'deb [arch=%s signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main\n' "$(dpkg --print-architecture)" \
      | as_root tee /etc/apt/sources.list.d/github-cli.list >/dev/null
    as_root apt-get update
    as_root apt-get install -y gh
  else
    warn "gh is not installed and no apt-get package path is available."
  fi
}

install_node_tools() {
  if ! have npm; then
    if have apt-get; then
      log "Installing npm"
      as_root apt-get install -y npm
    else
      warn "npm not found. Install Node.js/npm in the environment image first."
      return 1
    fi
  fi

  mkdir -p "$HOME/.npm-global"
  npm config set prefix "$HOME/.npm-global" >/dev/null

  if ! have agent-browser; then
    log "Installing agent-browser"
    npm install -g agent-browser --no-audit --no-fund --loglevel=error
  fi

  if have agent-browser; then
    log "Installing agent-browser browser runtime"
    agent-browser install || warn "agent-browser install failed. Browser capture skills may need a follow-up install."
  fi

  if ! have ast-grep; then
    log "Installing ast-grep CLI"
    npm install -g @ast-grep/cli --no-audit --no-fund --loglevel=error
  fi

  if ! have ast-grep && have cargo; then
    log "Installing ast-grep CLI with cargo fallback"
    cargo install ast-grep --locked
  fi

  log "Installing ast-grep agent skill"
  npx --yes skills add ast-grep/agent-skill -g -y
}

install_bun() {
  if have bun; then
    return 0
  fi

  log "Installing Bun for compound-plugin installer"
  curl -fsSL https://bun.sh/install | bash
  export PATH="$HOME/.bun/bin:$PATH"
}

install_vhs() {
  if have vhs; then
    return 0
  fi

  if have go; then
    log "Installing vhs with go install"
    go install github.com/charmbracelet/vhs@latest
  else
    warn "Go is not installed, so vhs could not be installed. Add Go to package versions or install vhs another way."
  fi
}

install_silicon() {
  if have silicon; then
    return 0
  fi

  if ! have cargo; then
    log "Installing Rust toolchain for silicon"
    curl -fsSL https://sh.rustup.rs | sh -s -- -y --profile minimal
    # shellcheck disable=SC1091
    [ -f "$HOME/.cargo/env" ] && . "$HOME/.cargo/env"
    export PATH="$HOME/.cargo/bin:$PATH"
  fi

  if have cargo; then
    log "Installing silicon v0.5.3 from GitHub"
    cargo install --git https://github.com/Aloxaf/silicon --tag v0.5.3 --locked
  else
    warn "Rust cargo is not installed, so silicon could not be installed. Add Rust to package versions or install silicon another way."
  fi
}

install_compound_engineering() {
  install_bun
  log "Installing Compound Engineering plugin into Codex"
  bunx @every-env/compound-plugin install compound-engineering --to codex
}

verify() {
  log "Verifying Compound Engineering tools"
  local missing=0
  for tool in agent-browser gh jq vhs silicon ffmpeg ast-grep; do
    if have "$tool"; then
      printf 'OK   %s -> %s\n' "$tool" "$(command -v "$tool")"
    else
      printf 'MISS %s\n' "$tool"
      missing=1
    fi
  done

  if [ -f "$HOME/.agents/skills/ast-grep/SKILL.md" ]; then
    printf 'OK   ast-grep skill -> %s\n' "$HOME/.agents/skills/ast-grep/SKILL.md"
  else
    printf 'MISS ast-grep skill\n'
    missing=1
  fi

  if find "$HOME/.codex/skills" "$HOME/.codex/prompts" -maxdepth 4 -type f 2>/dev/null | grep -Eq '/ce-setup/|ce-setup'; then
    printf 'OK   compound-engineering Codex install detected\n'
  else
    printf 'MISS compound-engineering Codex install not detected under ~/.codex\n'
    missing=1
  fi

  return "$missing"
}

main() {
  install_apt_base
  install_gh
  install_node_tools
  install_vhs
  install_silicon
  install_compound_engineering
  verify
}

main "$@"
