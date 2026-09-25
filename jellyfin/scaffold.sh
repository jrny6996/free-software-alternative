#!/usr/bin/env bash
# Scaffold Jellyfin (Netflix / Hulu / Spotify-style media server)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

SERVICE_NAME="Jellyfin"
UI_URL="http://localhost:8096"

need_cmd() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

need_cmd docker
docker compose version >/dev/null 2>&1 || {
  echo "Docker Compose plugin required (docker compose)" >&2
  exit 1
}

if [[ ! -f .env ]]; then
  cp .env.example .env
  echo "Created .env from .env.example"
else
  echo ".env already exists — leaving it alone."
fi

# shellcheck disable=SC1091
set -a; source .env; set +a
CONFIG_PATH="${CONFIG_PATH:-./config}"
CACHE_PATH="${CACHE_PATH:-./cache}"
MEDIA_PATH="${MEDIA_PATH:-./media}"

mkdir -p "$CONFIG_PATH" "$CACHE_PATH" "$MEDIA_PATH"

echo "Put owned media under: ${ROOT}/${MEDIA_PATH#./}"
echo

echo "Pulling images…"
docker compose pull

echo "Starting ${SERVICE_NAME}…"
docker compose up -d

cat <<EOF

${SERVICE_NAME} is up.
  UI: ${UI_URL}

Complete the wizard, then add a library pointed at /media inside the container
(your host folder: ${MEDIA_PATH}).

TCO note: no catalog / discovery — only media you already have.

Logs:  docker compose -f ${ROOT}/docker-compose.yaml logs -f
Stop:  docker compose -f ${ROOT}/docker-compose.yaml down

EOF
