FROM mcr.microsoft.com/vscode/devcontainers/base:ubuntu

# Instalar dependencias del sistema
RUN apt-get update && export DEBIAN_FRONTEND=noninteractive \
    && apt-get -y install --no-install-recommends \
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
        gzip \
    && apt-get autoremove -y && apt-get clean -y && rm -rf /var/lib/apt/lists/*

# Enlazar fd si es necesario
RUN if command -v fdfind >/dev/null 2>&1 && ! command -v fd >/dev/null 2>&1; then \
        ln -s /usr/bin/fdfind /usr/local/bin/fd; \
    fi

# Instalar Yazi desde binario precompilado
RUN REPO="sxyazi/yazi" \
    && ASSET_URL=$(curl -s "https://api.github.com/repos/${REPO}/releases/latest" | \
        jq -r '.assets[] | select(.name | test("linux.*(x86_64|amd64)")) | .browser_download_url' | head -n1) \
    && if [ -n "$ASSET_URL" ] && [ "$ASSET_URL" != "null" ]; then \
        tmpdir=$(mktemp -d) \
        && wget -qO "$tmpdir/asset" "$ASSET_URL" \
        && if file "$tmpdir/asset" | grep -qi zip; then \
            unzip -q "$tmpdir/asset" -d "$tmpdir"; \
        else \
            tar -xf "$tmpdir/asset" -C "$tmpdir"; \
        fi \
        && BIN=$(find "$tmpdir" -type f -name 'yazi' -perm /111 | head -n1) \
        && if [ -n "$BIN" ]; then \
            install -m755 "$BIN" /usr/local/bin/yazi; \
        fi \
        && rm -rf "$tmpdir"; \
    fi

# Verificar instalación
RUN yazi --version