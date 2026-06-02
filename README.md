# DevOps Engineer Assignment

This repository implements a small cloud-native application platform with a frontend, backend API, PostgreSQL database, Docker Compose local development, Kind Kubernetes deployment, Jenkins CI/CD, and observability through Prometheus, Grafana, Loki, and Promtail.

## Architecture

See [docs/diagrams/architecture.md](docs/diagrams/architecture.md).

## Repository Layout

- `frontend/`: static frontend served by non-root NGINX.
- `backend/`: FastAPI backend with health, readiness, status, and metrics endpoints.
- `docker-compose.yml`: local profiles for `core`, `app`, and `monitoring`.
- `k8s/`: Kustomize base and dev overlay.
- `helm/charts/`: Helm wrapper values for infrastructure components.
- `jenkins/` and `Jenkinsfile`: CI/CD pipeline and Jenkins deployment.
- `monitoring/`: Prometheus rules, Grafana dashboard, and local scrape configs.
- `terraform/`: optional AKS, ACR, and Key Vault modules.

## Prerequisites

- Docker Desktop or Docker Engine
- kubectl
- Kind v0.22+
- Helm v3.13+
- Kustomize v5+
- Trivy
- Git
- Node.js 18+
- Python 3.12+

## Local Docker Compose

Create local configuration:

```bash
cp environments/local/.env.example environments/local/.env
```

Start all profiles:

```bash
./deploy.sh start
```

Check status:

```bash
./deploy.sh status
```

Stop:

```bash
./deploy.sh stop
```

Local endpoints:

- Frontend: http://localhost:8080
- API health: http://localhost:8000/health
- API metrics: http://localhost:8000/metrics
- Prometheus: http://localhost:9090
- Grafana: http://localhost:3000
- Loki: http://localhost:3100

## Kubernetes With Kind

Bootstrap the full local platform:

```bash
./scripts/bootstrap-kind.sh
```

Or apply only application manifests:

```bash
kubectl apply -k k8s/overlays/dev
```

Add local hostnames:

```bash
echo "127.0.0.1 devops-assignment.local jenkins.local" | sudo tee -a /etc/hosts
```

Validate:

```bash
kubectl get pods -n devops-assignment
kubectl get ingress -n devops-assignment
kubectl rollout status deployment/api -n devops-assignment
kubectl rollout status deployment/frontend -n devops-assignment
```

## Jenkins CI/CD

Install Jenkins:

```bash
./jenkins/install-jenkins.sh
```

Configure credentials documented in [jenkins/README.md](jenkins/README.md), then create a multibranch or pipeline job pointing to this repository.

Pipeline stages:

- Checkout source
- Lint
- Unit tests
- Docker build
- Trivy security scan
- Push image
- Deploy to Kubernetes
- Post-deployment validation

Rollback:

```bash
kubectl rollout undo deployment/api -n devops-assignment
kubectl rollout undo deployment/frontend -n devops-assignment
```

## Observability

The monitoring stack is installed by `scripts/bootstrap-kind.sh`. Apply assignment-specific dashboards and alerts:

```bash
kubectl apply -f monitoring/alerts/application-rules.yaml
```

Import `monitoring/dashboards/devops-assignment-dashboard.json` into Grafana or mount it through the Grafana dashboard sidecar.

Dashboard coverage:

- Cluster CPU utilization
- Cluster memory utilization
- Pod restarts
- Application availability
- Application response times
- Application logs

To demonstrate an alert, temporarily scale the API to zero:

```bash
kubectl scale deployment/api -n devops-assignment --replicas=0
```

Restore service:

```bash
kubectl scale deployment/api -n devops-assignment --replicas=1
```

## Security Controls

- Containers run as non-root.
- Privilege escalation is disabled.
- Linux capabilities are dropped.
- Resource requests and limits are configured.
- Readiness and liveness probes are configured.
- Default-deny ingress and egress network policies are configured.
- CI fails on critical Trivy image vulnerabilities.

## Screenshots

Capture final evidence using [docs/screenshots/README.md](docs/screenshots/README.md).

Required screenshots:

- Jenkins pipeline
- Kubernetes workloads
- Grafana dashboard
- Alert firing
- Security scan results

## Bonus

Included:

- Jenkins shared library functions for build, scan, deploy, and rollback.
- Terraform modules for AKS, ACR, and Key Vault.
- Operational runbook for PostgreSQL connection exhaustion.
