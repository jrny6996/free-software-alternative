#!/usr/bin/env bash
# Scaffold Immich (Google Photos alternative)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

SERVICE_NAME="Immich"
UI_URL="http://localhost:2283"
DOCS_URL="https://docs.immich.app/install/docker-compose"

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
  echo "Created .env from .env.example — change DB_PASSWORD (A-Za-z0-9 only)."
else
  echo ".env already exists — leaving it alone."
fi

# Paths from .env (defaults match .env.example)
UPLOAD_LOCATION="${UPLOAD_LOCATION:-./library}"
DB_DATA_LOCATION="${DB_DATA_LOCATION:-./postgres}"
# shellcheck disable=SC1091
set -a; [[ -f .env ]] && source .env; set +a
UPLOAD_LOCATION="${UPLOAD_LOCATION:-./library}"
DB_DATA_LOCATION="${DB_DATA_LOCATION:-./postgres}"

mkdir -p "$UPLOAD_LOCATION" "$DB_DATA_LOCATION"

echo "Note: for upgrades, prefer release files from:"
echo "  ${DOCS_URL}"
echo

echo "Pulling images…"
docker compose pull

echo "Starting ${SERVICE_NAME}…"
docker compose up -d

cat <<EOF

${SERVICE_NAME} is up.
  UI: ${UI_URL}

Create your account on first visit, then install the Immich mobile app
and point it at this URL (or your Cloudflare Tunnel hostname).

Logs:  docker compose -f ${ROOT}/docker-compose.yaml logs -f
Stop:  docker compose -f ${ROOT}/docker-compose.yaml down

EOF
