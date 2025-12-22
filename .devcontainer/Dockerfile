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

# Instalar Yazi desde código fuente
RUN git clone https://github.com/sxyazi/yazi.git /tmp/yazi && \
    cd /tmp/yazi && \
    cargo build --release && \
    install -m755 target/release/yazi /usr/local/bin/yazi && \
    rm -rf /tmp/yazi

# Verificar instalación
RUN yazi --version