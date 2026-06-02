# PostgreSQL Connection Exhaustion Runbook

## Symptoms

- API readiness checks fail or return `database: unavailable`.
- Application logs contain connection timeout or `too many clients` errors.
- Grafana shows elevated API errors and database readiness at `0`.
- PostgreSQL reports many active or idle connections.

## Investigation Steps

1. Check application health:
   ```bash
   kubectl get pods -n devops-assignment
   kubectl logs deployment/api -n devops-assignment
   ```
2. Inspect PostgreSQL connection usage:
   ```bash
   kubectl exec -n devops-assignment statefulset/postgres -- psql -U app -d app -c "select state, count(*) from pg_stat_activity group by state;"
   ```
3. Confirm current connection limits:
   ```bash
   kubectl exec -n devops-assignment statefulset/postgres -- psql -U app -d app -c "show max_connections;"
   ```
4. Review recent deployments and traffic changes.

## Mitigation

- Scale API replicas down temporarily if connection pressure is severe.
- Restart API pods to clear leaked idle connections.
- Terminate obviously stale database sessions after confirming they are safe.

## Recovery

1. Restore API replica count.
2. Confirm `/ready` returns success.
3. Confirm Grafana application availability is healthy.
4. Keep watching connection count for at least 15 minutes.

## Prevention

- Add application-side connection pooling.
- Set conservative pool size per API replica.
- Alert on connection usage above 80 percent.
- Load test connection behavior before increasing replica count.
