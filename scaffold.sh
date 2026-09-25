#!/usr/bin/env bash
# Run any service scaffold from the repo root
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

SERVICES=(
  nextcloud
  immich
  jellyfin
  n8n
  ollama
  comfyui
  cloudflare-tunnel
)

usage() {
  cat <<EOF
Usage: $(basename "$0") <service> [scaffold args...]
       $(basename "$0") --list

Services:
$(printf '  %s\n' "${SERVICES[@]}")

Examples:
  $(basename "$0") nextcloud
  $(basename "$0") ollama --webui --pull llama3.2
  $(basename "$0") immich
EOF
}

if [[ $# -lt 1 || "$1" == "-h" || "$1" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "$1" == "--list" ]]; then
  printf '%s\n' "${SERVICES[@]}"
  exit 0
fi

SERVICE="$1"
shift

SCRIPT="${ROOT}/${SERVICE}/scaffold.sh"
if [[ ! -x "$SCRIPT" && ! -f "$SCRIPT" ]]; then
  echo "Unknown service: ${SERVICE}" >&2
  usage >&2
  exit 1
fi

chmod +x "$SCRIPT"
exec "$SCRIPT" "$@"
