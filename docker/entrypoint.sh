#!/bin/sh
set -e

echo "[entrypoint] Waiting for postgres..."
until python -c "
import os, psycopg2
psycopg2.connect(
    dbname=os.environ['POSTGRES_DB'],
    user=os.environ['POSTGRES_USER'],
    password=os.environ['POSTGRES_PASSWORD'],
    host=os.environ.get('POSTGRES_HOST', 'db'),
    port=os.environ.get('POSTGRES_PORT', '5432'),
)
" 2>/dev/null; do
  echo "[entrypoint] Postgres unavailable - sleeping 2s"
  sleep 2
done
echo "[entrypoint] Postgres is up."

echo "[entrypoint] Running migrations..."
python manage.py migrate --noinput

echo "[entrypoint] Collecting static files..."
python manage.py collectstatic --noinput

echo "[entrypoint] Starting gunicorn..."
exec gunicorn OpenSite.wsgi:application \
    --bind 0.0.0.0:8000 \
    --workers "${GUNICORN_WORKERS:-3}" \
    --timeout "${GUNICORN_TIMEOUT:-120}" \
    --access-logfile - \
    --error-logfile -
