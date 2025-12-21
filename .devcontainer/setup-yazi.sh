#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

apt-get update
apt-get install -y --no-install-recommends \
  unzip ffmpegthumbnailer unar jq poppler-utils fd-find ripgrep wget ca-certificates tar gzip

# Ensure `fd` command exists (Debian names it `fdfind`)
if [ -x /usr/bin/fdfind ] && [ ! -x /usr/local/bin/fd ]; then
  ln -s /usr/bin/fdfind /usr/local/bin/fd || true
fi

# Determine non-root user's home (Codespaces / devcontainers set SUDO_USER)
if [ -n "${SUDO_USER-}" ] && [ "$SUDO_USER" != "root" ]; then
  USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
  USER_HOME="$HOME"
fi

REPO="shiwirockztar/yazi"

# Try to get a precompiled Linux asset from the latest GitHub release
ASSET_URL=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | \
  jq -r '.assets[] | select(.name|test("linux.*(x86_64|amd64)")) | .browser_download_url' | head -n1)

if [ -n "$ASSET_URL" ] && [ "$ASSET_URL" != "null" ]; then
  tmpdir=$(mktemp -d)
  echo "Downloading precompiled Yazi from: $ASSET_URL"
  wget -qO "$tmpdir/asset" "$ASSET_URL"
  if file "$tmpdir/asset" | grep -qi zip; then
    unzip -q "$tmpdir/asset" -d "$tmpdir"
  else
    tar -xf "$tmpdir/asset" -C "$tmpdir"
  fi
  BIN=$(find "$tmpdir" -type f -name 'yazi' -perm /111 | head -n1 || true)
  if [ -n "$BIN" ]; then
    install -m755 "$BIN" /usr/local/bin/yazi
    echo "Installed yazi (precompiled) to /usr/local/bin/yazi"
    exit 0
  fi
fi

# Fallback: install via cargo (instala rustup si hace falta)
if ! command -v cargo >/dev/null 2>&1; then
  echo "Rust/cargo no encontrado — instalando rustup"
  curl https://sh.rustup.rs -sSf | sh -s -- -y
  # Load cargo env for the current shell and target user
  export PATH="$USER_HOME/.cargo/bin:$PATH"
fi

echo "Instalando yazi mediante cargo (yazi-fm y yazi-cli)"
cargo install yazi-fm yazi-cli || true

# Ensure yazi from cargo bin is reachable system-wide
if [ -x "$USER_HOME/.cargo/bin/yazi" ]; then
  ln -sf "$USER_HOME/.cargo/bin/yazi" /usr/local/bin/yazi || true
fi

echo "Listo: el comando 'yazi' debería estar disponible en la terminal." 
