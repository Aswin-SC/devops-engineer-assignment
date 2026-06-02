#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CLUSTER_NAME="${CLUSTER_NAME:-devops-assignment}"

require() {
  command -v "$1" >/dev/null 2>&1 || {
    echo "Missing required command: $1" >&2
    exit 1
  }
}

require docker
require kind
require kubectl
require helm

if ! kind get clusters | grep -qx "${CLUSTER_NAME}"; then
  kind create cluster --name "${CLUSTER_NAME}" --config "${ROOT_DIR}/kind-config.yaml"
fi

helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx >/dev/null
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts >/dev/null
helm repo add grafana https://grafana.github.io/helm-charts >/dev/null
helm repo update >/dev/null

helm upgrade --install ingress-nginx ingress-nginx/ingress-nginx \
  --namespace ingress-nginx --create-namespace \
  --values "${ROOT_DIR}/helm/charts/ingress-nginx/values.yaml" \
  --wait

helm upgrade --install prometheus-stack prometheus-community/kube-prometheus-stack \
  --namespace monitoring --create-namespace \
  --values "${ROOT_DIR}/helm/charts/prometheus-stack/values.yaml" \
  --wait

helm upgrade --install loki grafana/loki \
  --namespace monitoring --create-namespace \
  --values "${ROOT_DIR}/helm/charts/loki/values.yaml" \
  --wait

helm upgrade --install promtail grafana/promtail \
  --namespace monitoring --create-namespace \
  --values "${ROOT_DIR}/helm/charts/promtail/values.yaml" \
  --wait

docker build -t devops-assignment-api:local "${ROOT_DIR}/backend"
docker build -t devops-assignment-frontend:local "${ROOT_DIR}/frontend"
kind load docker-image devops-assignment-api:local --name "${CLUSTER_NAME}"
kind load docker-image devops-assignment-frontend:local --name "${CLUSTER_NAME}"

kubectl apply -k "${ROOT_DIR}/k8s/overlays/dev"
kubectl rollout status deployment/api -n devops-assignment --timeout=180s
kubectl rollout status deployment/frontend -n devops-assignment --timeout=180s
kubectl get pods -n devops-assignment
