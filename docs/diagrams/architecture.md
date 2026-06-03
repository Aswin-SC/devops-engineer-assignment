# Architecture Diagram

Editable Draw.io source: [devops-architecture.drawio](devops-architecture.drawio)

Open the `.drawio` file with [diagrams.net](https://app.diagrams.net/) by selecting **File > Open From > Device**, or by downloading it from GitHub and opening it locally in Draw.io Desktop.

```mermaid
flowchart LR
  user[User Browser] --> ingress[Ingress NGINX]
  ingress --> web[Frontend]
  web --> api[Backend API]
  api --> db[(PostgreSQL)]

  api --> metrics[Prometheus Scrape]
  kube[Kubernetes Nodes and Pods] --> metrics
  metrics --> grafana[Grafana]
  promtail[Promtail] --> loki[Loki]
  web --> promtail
  api --> promtail
  db --> promtail
  loki --> grafana

  jenkins[Jenkins Pipeline] --> registry[Container Registry]
  jenkins --> k8s[Kubernetes Deployments]
  registry --> k8s
```
