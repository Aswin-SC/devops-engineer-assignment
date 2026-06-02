#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

helm repo add jenkins https://charts.jenkins.io >/dev/null
helm repo update >/dev/null
helm upgrade --install jenkins jenkins/jenkins \
  --namespace jenkins --create-namespace \
  --values "${ROOT_DIR}/helm/charts/jenkins/values.yaml" \
  --wait
