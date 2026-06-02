# Jenkins CI/CD

Install Jenkins into the Kind cluster:

```bash
./jenkins/install-jenkins.sh
```

Create Jenkins credentials:

- `container-registry-url`: secret text containing the registry host, for example `ghcr.io`.
- `container-registry-credentials`: username/password credential for pushing images.
- Kubernetes access is expected to be available from the Jenkins agent pod.

Pipeline behavior:

- Builds frontend and backend images.
- Runs Trivy scans and fails on critical vulnerabilities.
- Pushes images to the registry.
- Updates Kubernetes deployments.
- Rolls back deployments on pipeline failure.

Demo scenarios:

- Successful deployment: run the pipeline on the main branch.
- Failed security scan: temporarily use a vulnerable base image and verify Trivy fails.
- Successful redeployment: restore the secure base image and rerun.
- Rollback: trigger a failed rollout and confirm `kubectl rollout undo` runs.
