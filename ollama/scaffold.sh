#!/usr/bin/env bash
# Scaffold Ollama (local ChatGPT / Claude alternative)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

SERVICE_NAME="Ollama"
API_URL="http://localhost:11434"
WEBUI_URL="http://localhost:3000"
LMSTUDIO_URL="https://lmstudio.ai"
NATIVE_URL="https://ollama.com/download"

WITH_WEBUI=0
USE_GPU=0
PULL_MODEL=""
COMPOSE_FILES=(-f docker-compose.yaml)

usage() {
  cat <<EOF
Usage: $(basename "$0") [--cpu|--gpu] [--webui] [--pull MODEL]

  --cpu         CPU-only (default) — docker-compose.yaml
  --gpu         NVIDIA GPU — also applies docker-compose.gpu.yaml
  --webui       Also start Open WebUI (ChatGPT-like UI on :3000)
  --pull MODEL  Pull a model after start (e.g. llama3.2)
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cpu) USE_GPU=0; shift ;;
    --gpu) USE_GPU=1; shift ;;
    --webui) WITH_WEBUI=1; shift ;;
    --pull)
      PULL_MODEL="${2:-}"
      [[ -n "$PULL_MODEL" ]] || { echo "--pull requires a model name" >&2; exit 1; }
      shift 2
      ;;
    -h|--help) usage; exit 0 ;;
    *) echo "Unknown option: $1" >&2; usage; exit 1 ;;
  esac
done

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

if [[ "$USE_GPU" -eq 1 ]]; then
  COMPOSE_FILES+=(-f docker-compose.gpu.yaml)
  MODE_LABEL="GPU"
else
  MODE_LABEL="CPU"
fi

COMPOSE=(docker compose "${COMPOSE_FILES[@]}")

echo "Pulling images (${MODE_LABEL})…"
if [[ "$WITH_WEBUI" -eq 1 ]]; then
  "${COMPOSE[@]}" --profile webui pull
  echo "Starting ${SERVICE_NAME} + Open WebUI (${MODE_LABEL})…"
  "${COMPOSE[@]}" --profile webui up -d
else
  "${COMPOSE[@]}" pull
  echo "Starting ${SERVICE_NAME} (${MODE_LABEL})…"
  "${COMPOSE[@]}" up -d
fi

if [[ -n "$PULL_MODEL" ]]; then
  echo "Pulling model: ${PULL_MODEL}"
  "${COMPOSE[@]}" exec -T ollama ollama pull "$PULL_MODEL"
fi

cat <<EOF

${SERVICE_NAME} is up (${MODE_LABEL}).
  API:  ${API_URL}
EOF

if [[ "$WITH_WEBUI" -eq 1 ]]; then
  echo "  WebUI: ${WEBUI_URL}"
else
  echo "  WebUI: re-run with --webui  →  ${WEBUI_URL}"
fi

if [[ "$USE_GPU" -eq 0 ]]; then
  echo
  echo "CPU mode: prefer small models (llama3.2:1b, phi3:mini)."
  echo "For NVIDIA:  ./scaffold.sh --gpu"
fi

cat <<EOF

Desktop alternatives (not Docker):
  LM Studio: ${LMSTUDIO_URL}
  Ollama:    ${NATIVE_URL}

Example pull:  docker compose exec ollama ollama pull llama3.2

Logs:  ${COMPOSE[*]} logs -f
Stop:  ${COMPOSE[*]} --profile webui down

EOF
