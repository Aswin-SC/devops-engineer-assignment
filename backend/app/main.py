import os
import time

import psycopg
from fastapi import FastAPI, Response

APP_VERSION = os.getenv("APP_VERSION", "1.0.0")
DATABASE_URL = os.getenv(
    "DATABASE_URL",
    "postgresql://app:app@postgres:5432/app",
)
REQUEST_COUNT = 0
START_TIME = time.time()

app = FastAPI(title="DevOps Assignment API", version=APP_VERSION)


def database_ready() -> bool:
    try:
        with psycopg.connect(DATABASE_URL, connect_timeout=2) as connection:
            with connection.cursor() as cursor:
                cursor.execute("select 1")
                return cursor.fetchone()[0] == 1
    except Exception:
        return False


@app.middleware("http")
async def count_requests(request, call_next):
    global REQUEST_COUNT
    REQUEST_COUNT += 1
    return await call_next(request)


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/ready")
def ready(response: Response):
    if not database_ready():
        response.status_code = 503
        return {"status": "not_ready", "database": "unavailable"}
    return {"status": "ready", "database": "available"}


@app.get("/status")
def status():
    return {
        "api": "available",
        "database": "available" if database_ready() else "unavailable",
        "version": APP_VERSION,
    }


@app.get("/metrics")
def metrics(response: Response):
    uptime = int(time.time() - START_TIME)
    response.media_type = "text/plain; version=0.0.4"
    return (
        "# HELP app_requests_total Total HTTP requests observed by the app middleware\n"
        "# TYPE app_requests_total counter\n"
        f"app_requests_total {REQUEST_COUNT}\n"
        "# HELP app_uptime_seconds Application uptime in seconds\n"
        "# TYPE app_uptime_seconds gauge\n"
        f"app_uptime_seconds {uptime}\n"
        "# HELP app_database_ready Database readiness, 1 means ready\n"
        "# TYPE app_database_ready gauge\n"
        f"app_database_ready {1 if database_ready() else 0}\n"
    )
