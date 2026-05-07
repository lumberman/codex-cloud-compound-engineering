#!/usr/bin/env bash
set -euo pipefail

# Codex Cloud bootstrap script.
# Pulls the Codex Cloud Compound Engineering setup kit from GitHub and runs it.
#
REPO_ARCHIVE_URL="https://github.com/lumberman/codex-cloud-compound-engineering/archive"
CE_KIT_REF="main"
TMP_DIR="$(mktemp -d)"

cleanup() {
  rm -rf "$TMP_DIR"
}
trap cleanup EXIT

echo "Fetching Codex Cloud Compound Engineering kit from ${CE_KIT_REF}..."

curl -fsSL "${REPO_ARCHIVE_URL}/${CE_KIT_REF}.tar.gz" \
  | tar -xz -C "$TMP_DIR" --strip-components=1

bash "$TMP_DIR/setup.sh"
