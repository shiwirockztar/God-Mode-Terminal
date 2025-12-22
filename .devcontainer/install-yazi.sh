#!/usr/bin/env bash
set -euo pipefail

echo "▶ Comprobando si 'yazi' ya está instalado..."
if command -v yazi >/dev/null 2>&1; then
  echo "✅ yazi ya instalado en $(command -v yazi)"
  exit 0
fi

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
REPO="sxyazi/yazi"

ARCH=$(uname -m)
case "$ARCH" in
  x86_64|amd64) arch_regex="(x86_64|amd64)";;
  aarch64|arm64) arch_regex="(aarch64|arm64)";;
  *) arch_regex="linux";;
esac

# Intentar descargar binario precompilado
ASSET_URL=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | jq -r ".assets[] | select(.name | test(\"linux.*${arch_regex}\")) | .browser_download_url" | head -n1)

if [ -n "$ASSET_URL" ] && [ "$ASSET_URL" != "null" ]; then
  echo "▶ Descargando binario precompilado..."
  wget -qO "$TMPDIR/asset" "$ASSET_URL"

  if file "$TMPDIR/asset" | grep -qi zip; then
    unzip -q "$TMPDIR/asset" -d "$TMPDIR"
  else
    tar -xf "$TMPDIR/asset" -C "$TMPDIR"
  fi

  BIN=$(find "$TMPDIR" -type f -name 'yazi' -perm /111 | head -n1 || true)

  if [ -n "$BIN" ]; then
    echo "▶ Instalando binario en /usr/local/bin..."
    if sudo install -m755 "$BIN" /usr/local/bin/yazi; then
      echo "✅ Yazi instalado en /usr/local/bin/yazi"
      exit 0
    else
      echo "⚠ No se pudo instalar con sudo, intentando instalar en \$HOME/.local/bin"
      mkdir -p "$HOME/.local/bin"
      cp "$BIN" "$HOME/.local/bin/yazi"
      chmod +x "$HOME/.local/bin/yazi"
      echo 'export PATH="\$HOME/.local/bin:\$PATH"' >> "$HOME/.profile" || true
      echo "✅ Yazi instalado en \$HOME/.local/bin/yazi (agrega \$HOME/.local/bin al PATH si es necesario)"
      exit 0
    fi
  fi
fi

# Si no hay binario, intentar con cargo
echo "⚠ No se encontró binario precompilado, intentando instalación via Cargo..."
if command -v cargo >/dev/null 2>&1; then
  cargo install yazi-fm yazi-cli || true
  if command -v yazi >/dev/null 2>&1; then
    echo "✅ Yazi instalado via cargo en $(command -v yazi)"
    exit 0
  fi
fi

# Instalar rustup/cargo si falta
if ! command -v cargo >/dev/null 2>&1; then
  echo "▶ Instalando Rust (rustup)..."
  curl https://sh.rustup.rs -sSf | sh -s -- -y
  export PATH="$HOME/.cargo/bin:$PATH"
  cargo install yazi-fm yazi-cli || true
  if command -v yazi >/dev/null 2>&1; then
    echo "✅ Yazi instalado via cargo en $(command -v yazi)"
    exit 0
  fi
fi

echo "❌ No se pudo instalar Yazi automáticamente. Por favor instala manualmente: 'cargo install yazi-fm yazi-cli' o revisa logs."