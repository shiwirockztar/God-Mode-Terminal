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

La imagen del devcontainer instala `yazi` durante la fase de build del `Dockerfile`, de modo que cuando abres el contenedor ya tienes `yazi` disponible inmediatamente —no hace falta ejecutar la instalación dentro del contenedor en cada inicio.

Qué hace el `Dockerfile` (resumen):

- **ARGs para versión y artefacto**: define `YAZI_VERSION`, `YAZI_ASSET_NAME` y `YAZI_SHA256` para pinnear la versión y el binario a usar.
- **Descarga y verificación**: si hay un binario precompilado (asset) compatible, el Dockerfile lo descarga desde los releases, verifica el `SHA256`, lo descomprime y lo coloca en `/usr/local/bin` con permisos ejecutables.
- **Fallback: compilación desde fuente**: si no existe un binario precompilado, instala la toolchain de Rust y compila `yazi` desde la fuente —esto ocurre durante el build de la imagen (es lento), no al iniciar el contenedor.
- **Limpieza y cache de capas**: elimina archivos temporales para mantener la imagen ligera y aprovecha el cache de capas de Docker/Dev Containers, por lo que la instalación no se repite a menos que cambie la parte del Dockerfile que la afecta.

Por qué esto acelera el arranque de `yazi`:

- La instalación de `yazi` se realiza mientras se construye la imagen (build time). Una vez la imagen está construida, iniciar el contenedor es rápido porque el binario ya está incluido en la imagen.
- No necesitas ejecutar `cargo install` ni descargar dependencias al abrir el Codespace o contenedor —esto evita esperar minutos por compilar o instalar.
- Las reconstrucciones solo son necesarias cuando cambias la versión o el `Dockerfile`; las ejecuciones diarias reutilizan la imagen ya preparada.

Cómo actualizar la versión de `yazi` en el contenedor:

1. Edita los ARGs en `.devcontainer/Dockerfile` (por ejemplo `YAZI_VERSION`, `YAZI_ASSET_NAME`, `YAZI_SHA256`).
2. Reconstruye el contenedor en VS Code: usa la paleta (F1) → "Dev Containers: Rebuild Container" (o en Codespaces, selecciona "Rebuild Container").

Notas adicionales:

- Si existe, el script auxiliar `.devcontainer/install-yazi.sh` puede usarse manualmente, pero no es necesario al usar la imagen ya construida.
- Si prefieres no incluir `yazi` en la imagen, el Dockerfile puede modificarse para dejar la instalación como paso de primer arranque, pero perderás la ventaja del inicio inmediato.

Comandos rápidos:

```sh
# Reconstruir el contenedor en VS Code
# F1 → Dev Containers: Rebuild Container

# (Opcional) Forzar rebuild desde la línea si tienes Docker local
docker build -f .devcontainer/Dockerfile -t god-mode-terminal-dev .
```

Con esto, al abrir el devcontainer tendrás `yazi` listo para usar sin esperar instalaciones adicionales.

## Uso básico de Yazi

Aquí tienes comandos y consejos rápidos para comenzar a usar `yazi` dentro del devcontainer o en tu máquina local:

- **Abrir el explorador TUI:**

```sh
yazi
```

- **Abrir `yazi` en una carpeta específica:**

```sh
yazi /ruta/a/mi/carpeta
```

- **Obtener ayuda y versión:**

```sh
yazi --help
yazi --version
```

- **Archivo de configuración:**

El directorio de configuración por defecto es `$HOME/.config/yazi`. Puedes crear o editar la configuración con un archivo `yazi.toml`:

```sh
mkdir -p $HOME/.config/yazi
nano $HOME/.config/yazi/yazi.toml
```

- **Navegación básica:** usa las flechas del teclado para moverte, `Enter` para abrir un archivo o carpeta y `q` o `Esc` para salir (comprueba los atajos en `--help` para tu versión).

- **Consejo rápido:** si trabajas dentro del devcontainer, `yazi` ya está instalado en la imagen; solo abre el contenedor y ejecuta `yazi` inmediatamente.


