#!/usr/bin/env bash
# Scaffold ComfyUI (local Firefly / media generation)
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT"

SERVICE_NAME="ComfyUI"
UI_URL="http://localhost:8188"
COMPOSE_FILE="docker-compose.yaml"
MODE_LABEL="GPU"

usage() {
  cat <<EOF
Usage: $(basename "$0") [--cpu|--gpu]

  --gpu   NVIDIA GPU (default) — docker-compose.yaml
  --cpu   CPU only (slow)      — docker-compose.cpu.yaml
EOF
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --cpu)
      COMPOSE_FILE="docker-compose.cpu.yaml"
      MODE_LABEL="CPU"
      shift
      ;;
    --gpu)
      COMPOSE_FILE="docker-compose.yaml"
      MODE_LABEL="GPU"
      shift
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

# shellcheck disable=SC1091
set -a; source .env; set +a
MODELS_PATH="${MODELS_PATH:-./models}"
OUTPUT_PATH="${OUTPUT_PATH:-./output}"
INPUT_PATH="${INPUT_PATH:-./input}"
CUSTOM_NODES_PATH="${CUSTOM_NODES_PATH:-./custom_nodes}"

mkdir -p "$MODELS_PATH" "$OUTPUT_PATH" "$INPUT_PATH" "$CUSTOM_NODES_PATH"

COMPOSE=(docker compose -f "$COMPOSE_FILE")

if [[ "$MODE_LABEL" == "GPU" ]] && ! docker info 2>/dev/null | grep -qi nvidia; then
  echo "Warning: NVIDIA runtime not detected."
  echo "Use CPU mode instead:  ./scaffold.sh --cpu"
  echo "Or install the NVIDIA Container Toolkit and re-run."
  echo
fi

if [[ "$MODE_LABEL" == "CPU" ]]; then
  echo "CPU mode is for testing — expect minutes per image, not seconds."
  echo "Video workflows are usually not practical without a GPU."
  echo
fi

echo "Pulling images (${MODE_LABEL})…"
"${COMPOSE[@]}" pull

echo "Starting ${SERVICE_NAME} (${MODE_LABEL})…"
"${COMPOSE[@]}" up -d

cat <<EOF

${SERVICE_NAME} is up (${MODE_LABEL}).
  UI: ${UI_URL}

Drop checkpoints / LoRAs under ${MODELS_PATH}.
Video + large models need VRAM, disk, and electricity — that's the TCO.

Logs:  ${COMPOSE[*]} logs -f
Stop:  ${COMPOSE[*]} down

EOF
