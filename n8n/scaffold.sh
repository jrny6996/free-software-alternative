#!/usr/bin/env bash
# Scaffold n8n (Zapier alternative)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

SERVICE_NAME="n8n"
UI_URL="http://localhost:5678"

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
  echo "Created .env from .env.example — change POSTGRES_* passwords."
else
  echo ".env already exists — leaving it alone."
fi

chmod +x ./init-data.sh 2>/dev/null || true

echo "Pulling images…"
docker compose pull

echo "Starting ${SERVICE_NAME}…"
docker compose up -d

cat <<EOF

${SERVICE_NAME} is up.
  UI: ${UI_URL}

Create the owner account on first visit.
To use local models, run ../ollama/scaffold.sh and point AI nodes at
  http://host.docker.internal:11434  (Docker Desktop)
  or join both stacks on one compose network.

Logs:  docker compose -f ${ROOT}/docker-compose.yaml logs -f
Stop:  docker compose -f ${ROOT}/docker-compose.yaml down

EOF
