#!/usr/bin/env bash
# Scaffold Nextcloud (Google Drive alternative)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

SERVICE_NAME="Nextcloud"
UI_URL="http://localhost:8080"
DESKTOP_URL="https://nextcloud.com/install/#desktop-files"

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
  echo "Created .env from .env.example — edit passwords before production use."
else
  echo ".env already exists — leaving it alone."
fi

echo "Pulling images…"
docker compose pull

echo "Starting ${SERVICE_NAME}…"
docker compose up -d

cat <<EOF

${SERVICE_NAME} is up.
  UI:      ${UI_URL}
  Desktop: ${DESKTOP_URL}

First visit creates the admin account from NEXTCLOUD_ADMIN_* in .env.
Logs:  docker compose -f ${ROOT}/docker-compose.yaml logs -f
Stop:  docker compose -f ${ROOT}/docker-compose.yaml down

EOF
