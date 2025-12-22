# God-Mode-Terminal
Descubre Yazi, el gestor de archivos en terminal escrito en Rust que está revolucionando la productividad. En este video te muestro cómo usar Yazi, sus atajos esenciales y por qué es más rápido que muchos file managers gráficos. Si buscas mejorar tu flujo de trabajo y dominar la terminal

## Instalación de Rust y Yazi

Como primer paso instala Rust (no viene instalado por defecto):

```sh
curl https://sh.rustup.rs -sSf | sh
source $HOME/.cargo/env
```

Verifica la instalación:

```sh
cargo --version
```

Luego instala `yazi-fm` y `yazi-cli`:

```sh
cargo install yazi-fm yazi-cli
```

## Yazi en el Devcontainer ✅

La imagen del devcontainer ahora incluye `yazi` instalado durante el build del `Dockerfile`, por lo que no es necesario instalarlo cada vez que inicias el Codespace.

Para aplicar estos cambios en tu Codespace actual:

- En VS Code: abre la paleta (F1) y selecciona "Dev Containers: Rebuild Container" o "Remote-Containers: Rebuild and Reopen in Container".
- En GitHub Codespaces: recrea el Codespace o selecciona "Rebuild Container" desde la interfaz.

El script de instalación (`.devcontainer/install-yazi.sh`) queda como ayuda, pero ya no se ejecuta automáticamente al iniciar.
