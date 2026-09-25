#!/usr/bin/env bash
# Scaffold Cloudflare Tunnel (public HTTPS without opening router ports)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

SERVICE_NAME="Cloudflare Tunnel"
DOCS_URL="https://developers.cloudflare.com/cloudflare-one/connections/connect-apps/"

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
fi

# shellcheck disable=SC1091
set -a; source .env; set +a

if [[ -z "${TUNNEL_TOKEN:-}" || "$TUNNEL_TOKEN" == *"replace-with-your-tunnel-token"* || "$TUNNEL_TOKEN" == "eyJ...replace-with-your-tunnel-token" ]]; then
  cat <<EOF
Set TUNNEL_TOKEN in ${ROOT}/.env before starting.

1. Open Cloudflare Zero Trust → Networks → Tunnels
2. Create a tunnel and copy the connector token
3. Paste it into .env as TUNNEL_TOKEN=...
4. Route hostnames to local services, e.g.:
     photos.example.com       → http://localhost:2283
     cloud.example.com        → http://localhost:8080
     media.example.com        → http://localhost:8096
     automations.example.com  → http://localhost:5678

Docs: ${DOCS_URL}

Then re-run:  ${ROOT}/scaffold.sh
EOF
  exit 1
fi

echo "Pulling images…"
docker compose pull

echo "Starting ${SERVICE_NAME}…"
docker compose up -d

cat <<EOF

${SERVICE_NAME} is up (network_mode: host).
Configure Public Hostnames in the Cloudflare dashboard to reach local ports.

Docs: ${DOCS_URL}

Logs:  docker compose -f ${ROOT}/docker-compose.yaml logs -f
Stop:  docker compose -f ${ROOT}/docker-compose.yaml down

EOF
