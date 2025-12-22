FROM mcr.microsoft.com/vscode/devcontainers/base:alpine

# Instalar dependencias del sistema
RUN apk update && apk add --no-cache \
        unzip \
        ffmpegthumbnailer \
        unar \
        jq \
        poppler-utils \
        fd \
        ripgrep \
        wget \
        ca-certificates \
        tar \
        gzip \
        rust \
        cargo \
        build-base

# Instalar Yazi (preferir binario precompilado)
RUN set -eux; \
    REPO="sxyazi/yazi"; \
    ARCH="$(uname -m)"; \
    case "$ARCH" in \
      x86_64|amd64) arch_regex="linux.*(x86_64|amd64)";; \
      aarch64|arm64) arch_regex="linux.*(aarch64|arm64)";; \
      *) arch_regex="linux";; \
    esac; \
    ASSET_URL="$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | jq -r '.assets[] | select(.name | test("'""$arch_regex"'"")) | .browser_download_url' | head -n1)" || true; \
    if [ -n "$ASSET_URL" ] && [ "$ASSET_URL" != "null" ]; then \
      echo "▶ Descargando binario precompilado $ASSET_URL"; \
      wget -qO /tmp/yazi_asset "$ASSET_URL"; \
      if file /tmp/yazi_asset | grep -qi zip; then unzip -q /tmp/yazi_asset -d /tmp; else tar -xf /tmp/yazi_asset -C /tmp; fi; \
      BIN="$(find /tmp -type f -name yazi -perm /111 | head -n1 || true)"; \
      if [ -n "$BIN" ]; then install -m755 "$BIN" /usr/local/bin/yazi; fi; \
    fi; \
    if ! command -v yazi >/dev/null 2>&1; then \
      echo "▶ No se encontró binario; compilando desde fuente..."; \
      git clone https://github.com/sxyazi/yazi.git /tmp/yazi && cd /tmp/yazi && cargo build --release && install -m755 target/release/yazi /usr/local/bin/yazi || true; \
    fi; \
    rm -rf /tmp/yazi /tmp/yazi_asset

# Verificar instalación
RUN yazi --version