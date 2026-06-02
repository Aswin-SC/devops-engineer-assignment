# DevOps Engineer Assignment Submission

## Repository

- GitHub repository: `https://github.com/Aswin-SC/devops-engineer-assignment`
- Working WSL path: `/home/abarn/devops-engineer-assignment`
- Primary branch: `main`

## Objective Coverage

This submission implements a local cloud-native platform with:

- Frontend web application served by non-root NGINX.
- FastAPI backend with `/health`, `/ready`, `/status`, and `/metrics`.
- PostgreSQL database.
- Docker Compose profiles for local development.
- Kind Kubernetes cluster with Kustomize-managed application manifests.
- Helm-managed infrastructure for ingress, monitoring, logging, and Jenkins.
- Network policies, security contexts, probes, and resource requests/limits.
- Jenkins CI/CD pipeline definition with Trivy scanning and rollback behavior.
- Prometheus, Grafana, Loki, and Promtail observability stack.
- Terraform bonus modules for AKS, ACR, and Key Vault.
- PostgreSQL connection exhaustion runbook.

## Architecture

Architecture diagram: [docs/diagrams/architecture.md](docs/diagrams/architecture.md)

Flow summary:

1. Browser traffic enters through `ingress-nginx`.
2. The frontend serves the UI and proxies API calls.
3. The backend API connects to PostgreSQL and exposes metrics.
4. Prometheus scrapes Kubernetes and application metrics.
5. Promtail ships logs to Loki.
6. Grafana visualizes metrics and logs.
7. Jenkins runs CI/CD stages for lint, tests, image build, Trivy scan, push, deploy, and validation.

## How To Reproduce

Run from WSL:

```bash
cd /home/abarn/devops-engineer-assignment
```

Start the Docker Compose environment:

```bash
cp -n environments/local/.env.example environments/local/.env
./deploy.sh start
./deploy.sh status
```

Bootstrap the Kind platform:

```bash
./scripts/bootstrap-kind.sh
```

Install Jenkins if it is not already installed:

```bash
./jenkins/install-jenkins.sh
```

Add local hostnames if needed:

```bash
echo "127.0.0.1 devops-assignment.local jenkins.local" | sudo tee -a /etc/hosts
```

Open:

- Application: `http://devops-assignment.local`
- Jenkins: `http://jenkins.local`
- Grafana: use port-forwarding from the `monitoring` namespace.

## Validation Proofs

Live proof files are stored in [docs/evidence](docs/evidence).

- Kubernetes workloads: [docs/evidence/kubernetes-pods.txt](docs/evidence/kubernetes-pods.txt)
- Helm releases: [docs/evidence/helm-releases.txt](docs/evidence/helm-releases.txt)
- Services and ingresses: [docs/evidence/services-ingress.txt](docs/evidence/services-ingress.txt)
- Application health: [docs/evidence/application-health.txt](docs/evidence/application-health.txt)
- Trivy critical scans: [docs/evidence/trivy-critical-scan.txt](docs/evidence/trivy-critical-scan.txt)
- Tool versions: [docs/evidence/tool-versions.txt](docs/evidence/tool-versions.txt)
- Git state: [docs/evidence/git-state.txt](docs/evidence/git-state.txt)

Current validation highlights:

- All application pods are `Running`.
- Jenkins pod is `Running`.
- Prometheus, Grafana, Loki, Promtail, and Alertmanager pods are `Running`.
- `devops-assignment.local` returns the frontend HTML through ingress.
- Backend `/status` reports `api=available` and `database=available`.
- Trivy critical-only scans report zero critical vulnerabilities for both local app images.

## CI/CD Proof

Pipeline definition: [Jenkinsfile](Jenkinsfile)

Pipeline stages implemented:

- Checkout Source
- Lint
- Unit Tests
- Docker Build
- Security Scan
- Push Image
- Deploy to Kubernetes
- Post-Deployment Validation
- Rollback on failure

Jenkins deployment proof:

- Helm release: `jenkins` in namespace `jenkins`
- Workload: `jenkins-0`, `2/2 Running`
- Ingress host: `jenkins.local`

Jenkins credential requirements are documented in [jenkins/README.md](jenkins/README.md).

## Security Controls

- Workloads run as non-root.
- Containers drop Linux capabilities.
- Privilege escalation is disabled.
- Kubernetes probes are configured.
- CPU and memory requests/limits are configured.
- Default deny ingress and egress network policies are configured.
- Explicit allow policies connect ingress, frontend, API, PostgreSQL, and DNS.
- Trivy critical vulnerability scans pass for local API and frontend images.

## Observability Proof

Monitoring files:

- Prometheus local config: [monitoring/prometheus/prometheus.local.yml](monitoring/prometheus/prometheus.local.yml)
- Prometheus alerts: [monitoring/alerts/application-rules.yaml](monitoring/alerts/application-rules.yaml)
- Grafana dashboard JSON: [monitoring/dashboards/devops-assignment-dashboard.json](monitoring/dashboards/devops-assignment-dashboard.json)
- Grafana dashboard ConfigMap: [monitoring/dashboard-configmap.yaml](monitoring/dashboard-configmap.yaml)
- Promtail local config: [monitoring/promtail/promtail.local.yml](monitoring/promtail/promtail.local.yml)

Dashboard covers:

- Cluster CPU utilization
- Cluster memory utilization
- Pod restarts
- Application availability
- Application response times
- Application logs

Alert rules cover:

- High CPU usage
- High memory usage
- Pod failures
- Application unavailable
- Excessive error rates

## Demo Script

Use this sequence during walkthrough:

```bash
kubectl get pods -A
helm list -A
kubectl get svc,ingress -A
curl -H 'Host: devops-assignment.local' http://127.0.0.1/
kubectl get prometheusrule -n monitoring
trivy image --severity CRITICAL --exit-code 1 --scanners vuln devops-assignment-api:local
trivy image --severity CRITICAL --exit-code 1 --scanners vuln devops-assignment-frontend:local
```

Show Jenkins:

```bash
kubectl get pods,ingress -n jenkins
```

Show rollback:

```bash
kubectl rollout history deployment/api -n devops-assignment
kubectl rollout undo deployment/api -n devops-assignment
kubectl rollout status deployment/api -n devops-assignment
```

Show alert firing:

```bash
kubectl scale deployment/api -n devops-assignment --replicas=0
kubectl get prometheusrule -n monitoring
kubectl scale deployment/api -n devops-assignment --replicas=1
kubectl rollout status deployment/api -n devops-assignment
```

## Screenshot Checklist

Before final submission, capture screenshots into [docs/screenshots](docs/screenshots):

- Jenkins pipeline page.
- Kubernetes workloads output.
- Grafana dashboard.
- Alert firing.
- Trivy scan output.

The text proof files in [docs/evidence](docs/evidence) are included as reproducible evidence if screenshots are not accepted as the only proof format.

## Known Notes

- The environment is implemented and validated inside WSL.
- The WSL-native repo is the source of truth for the working local environment.
- Docker group membership may require a fresh WSL shell after installation.
