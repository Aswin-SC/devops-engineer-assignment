# Evidence Index

This directory contains command-output proof captured from the live WSL environment.

## Files

- `kubernetes-pods.txt`: all Kubernetes pods across namespaces.
- `helm-releases.txt`: Helm releases for ingress, Jenkins, Loki, Prometheus stack, and Promtail.
- `services-ingress.txt`: services and ingress resources across namespaces.
- `application-health.txt`: frontend ingress response and backend `/status` response.
- `trivy-critical-scan.txt`: critical-only Trivy scan proof for API and frontend images.
- `jenkins-pipelines.txt`: Jenkins frontend/backend job configuration and successful build proof.
- `tool-versions.txt`: installed DevOps CLI versions.
- `git-state.txt`: recent commits and working tree state.

## Recapture Commands

```bash
kubectl get pods -A
helm list -A
kubectl get svc,ingress -A
curl -H 'Host: devops-assignment.local' http://127.0.0.1/
trivy image --severity CRITICAL --exit-code 1 --scanners vuln devops-assignment-api:local
trivy image --severity CRITICAL --exit-code 1 --scanners vuln devops-assignment-frontend:local
```
