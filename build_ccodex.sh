#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
INSTALL_DIR="$HOME/.local/bin"
INSTALL_PATH="${INSTALL_DIR}/ccodex"
IMAGE_NAME="codex-arena:localbuild"
UNINSTALL_DOC="$HOME/CODEX_UNINSTALL_INSTRUCTIONS"

printf '%s\n' \
	'Recommended host setup before first use:' \
	'1. Install Codex on your host system, for example: npm install -g @openai/codex' \
	'2. Run: codex' \
	'3. Complete only the initial OpenAI account-linking setup.' \
	'4. It is strongly recommended to uninstall codex at this point to remove risk of unwanted reads.' \
	'ccodex will then reuse your host ~/.codex authentication inside the container.'


mkdir -p "${INSTALL_DIR}"
install -m 0755 "${SCRIPT_DIR}/ccodex" "${INSTALL_PATH}"
docker build -t "${IMAGE_NAME}" "${SCRIPT_DIR}"

cat > "${UNINSTALL_DOC}" <<EOF
Remove the ccodex wrapper:
rm -f "${INSTALL_PATH}"

Remove the Docker image:
docker image rm "${IMAGE_NAME}"

Optionally remove your host Codex auth/config:
rm -rf "${HOME}/.codex"

Remove this uninstall document:
rm -f "${UNINSTALL_DOC}"
EOF

printf 'Installed %s\n' "${INSTALL_PATH}"
printf 'Built Docker image %s\n' "${IMAGE_NAME}"
printf 'Wrote uninstall instructions to %s\n' "${UNINSTALL_DOC}"
