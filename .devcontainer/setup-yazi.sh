#!/usr/bin/env bash
set -euo pipefail

export DEBIAN_FRONTEND=noninteractive

echo "▶ Instalando dependencias del sistema…"
apt-get update
apt-get install -y --no-install-recommends \
  unzip \
  ffmpegthumbnailer \
  unar \
  jq \
  poppler-utils \
  fd-find \
  ripgrep \
  wget \
  ca-certificates \
  tar \
  gzip

# Asegurar que el comando `fd` exista (Debian lo llama `fdfind`)
if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then
  ln -s /usr/bin/fdfind /usr/local/bin/fd || true
fi

# Determinar el home del usuario no-root (vscode)
if [ -n "${SUDO_USER-}" ] && [ "$SUDO_USER" != "root" ]; then
  USER_HOME=$(getent passwd "$SUDO_USER" | cut -d: -f6)
else
  USER_HOME="$HOME"
fi

echo "▶ Usuario objetivo: $USER_HOME"

REPO="sxyazi/yazi"

echo "▶ Intentando instalar Yazi desde binario precompilado…"

ASSET_URL=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | \
  jq -r '.assets[] | select(.name | test("linux.*(x86_64|amd64)")) | .browser_download_url' | head -n1)

if [ -n "$ASSET_URL" ] && [ "$ASSET_URL" != "null" ]; then
  tmpdir=$(mktemp -d)
  wget -qO "$tmpdir/asset" "$ASSET_URL"

  if file "$tmpdir/asset" | grep -qi zip; then
    unzip -q "$tmpdir/asset" -d "$tmpdir"
  else
    tar -xf "$tmpdir/asset" -C "$tmpdir"
  fi

  BIN=$(find "$tmpdir" -type f -name 'yazi' -perm /111 | head -n1 || true)

  if [ -n "$BIN" ]; then
    install -m755 "$BIN" /usr/local/bin/yazi
    echo "✅ Yazi instalado desde binario en /usr/local/bin/yazi"
    rm -rf "$tmpdir"
    exit 0
  fi

  rm -rf "$tmpdir"
fi

echo "⚠ No se encontró binario precompilado, usando Cargo…"

# Instalar Rust/Cargo si no existe
if ! command -v cargo >/dev/null 2>&1; then
  echo "▶ Instalando Rust (rustup)…"
  curl https://sh.rustup.rs -sSf | sh -s -- -y
fi

export PATH="$USER_HOME/.cargo/bin:$PATH"

echo "▶ Instalando Yazi con cargo…"
cargo install yazi-fm yazi-cli || true

# Hacer yazi accesible globalmente
if [ -x "$USER_HOME/.cargo/bin/yazi" ]; then
  install -m755 "$USER_HOME/.cargo/bin/yazi" /usr/local/bin/yazi
fi

# Verificación final
if command -v yazi >/dev/null 2>&1; then
  echo "✅ Yazi instalado correctamente en $(command -v yazi)"
else
  echo "❌ Error: Yazi no quedó instalado"
  exit 1
fi
