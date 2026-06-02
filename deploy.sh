#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${ROOT_DIR}/environments/local/.env"
COMPOSE=(docker compose --env-file "${ENV_FILE}" --profile core --profile app --profile monitoring)

if [[ ! -f "${ENV_FILE}" ]]; then
  cp "${ROOT_DIR}/environments/local/.env.example" "${ENV_FILE}"
fi

case "${1:-}" in
  start)
    "${COMPOSE[@]}" up -d --build
    ;;
  stop)
    "${COMPOSE[@]}" down
    ;;
  restart)
    "${COMPOSE[@]}" down
    "${COMPOSE[@]}" up -d --build
    ;;
  status)
    "${COMPOSE[@]}" ps
    ;;
  *)
    echo "Usage: ./deploy.sh {start|stop|restart|status}" >&2
    exit 1
    ;;
esac
