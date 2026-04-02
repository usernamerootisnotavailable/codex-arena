# codex-arena

`codex-arena` is a small Dockerized wrapper around the OpenAI Codex CLI.
It builds a local image with the tools the container should have, then installs a `ccodex` shell wrapper that runs `codex` inside that container instead of on your host machine.

The wrapper mounts your current working directory into the container and reuses your host `~/.codex` auth, so you keep your normal project context and login while using the containerized environment.

## Install

```bash
./build_ccodex.sh
```

`build_ccodex.sh` does three things:

1. Installs the `ccodex` wrapper file to `~/.local/bin/ccodex`.
2. Builds the Docker image as `codex-arena:localbuild`.
3. Writes uninstall instructions to `~/CODEX_UNINSTALL_INSTRUCTIONS`.

To get started right away in the current shell, source the wrapper script.
```bash
source ~/.local/bin/ccodex
ccodex
```

## Uninstall
To uninstall, remove the ccodex wrapper, the ccodex container (and the image, if you want), the uninstall instructions, and optionally the codex config in .codex.
```bash
rm -f ~/.local/bin/ccodex
docker image rm codex-arena:localbuild
rm -f ~/CODEX_UNINSTALL_INSTRUCTIONS
rm -rf ~/.codex    # optional
```
