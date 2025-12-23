FROM mcr.microsoft.com/vscode/devcontainers/base:alpine

# Instalar dependencias del sistema
RUN apk update && apk add --no-cache \
        unzip \
        ffmpegthumbnailer \
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

ARG YAZI_VERSION=v25.5.31
ARG YAZI_SHA256=a2fdc9c35719fa72d94820893eb2fedd93fd1c418c2cf568702643526c358f7a
ARG YAZI_ASSET_NAME=yazi-x86_64-unknown-linux-musl.zip

# Instalar Yazi (binario precompilado verificado por checksum, fallback a compilación)
RUN set -eux; \
    REPO="sxyazi/yazi"; \
    ASSET_URL="https://github.com/${REPO}/releases/download/${YAZI_VERSION}/${YAZI_ASSET_NAME}"; \
    echo "▶ Intentando descargar ${ASSET_URL}"; \
    if wget -qO /tmp/yazi_asset.zip "$ASSET_URL"; then \
      echo "${YAZI_SHA256}  /tmp/yazi_asset.zip" | sha256sum -c -; \
      unzip -q /tmp/yazi_asset.zip -d /tmp; \
      BIN="$(find /tmp -type f -name yazi -perm /111 | head -n1 || true)"; \
      if [ -n "$BIN" ]; then install -m755 "$BIN" /usr/local/bin/yazi; fi; \
    else \
      echo "⚠ No se pudo descargar binario precompilado, se usará compilación desde la fuente"; \
    fi; \
    if ! command -v yazi >/dev/null 2>&1; then \
      echo "▶ Compilando Yazi desde la fuente (fallback)"; \
      git clone --depth 1 --branch "${YAZI_VERSION}" https://github.com/sxyazi/yazi.git /tmp/yazi && cd /tmp/yazi && cargo build --release && install -m755 target/release/yazi /usr/local/bin/yazi; \
    fi; \
    rm -rf /tmp/yazi /tmp/yazi_asset.zip

# Verificar instalación
RUN yazi --version

# Instalar yazi-cli
RUN cargo install yazi-cli --locked 2>/dev/null || cargo install yazi-cli || true

# Crear la estructura de configuración de Yazi
RUN mkdir -p /root/.config/yazi && chmod -R 755 /root/.config

# Copiar la configuración de Yazi desde el contexto de build
COPY .config/ /root/.config/

# Asegurar permisos correctos
RUN chmod -R 755 /root/.config && chmod 644 /root/.config/yazi/yazi.toml 2>/dev/null || true