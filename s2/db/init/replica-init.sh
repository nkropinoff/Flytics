#!/bin/bash
set -e

echo "Waiting for primary..."
until pg_isready -h primary -p 5432 -U postgres; do
  sleep 2
done

if [ ! -f "$PGDATA/PG_VERSION" ]; then
  echo "No data found, running pg_basebackup..."
  rm -rf "$PGDATA"/*
  PGPASSWORD=replicatorpass pg_basebackup \
    -h primary \
    -D "$PGDATA" \
    -U replicator \
    -P \
    -R
  echo "pg_basebackup complete."
fi

exec docker-entrypoint.sh postgres
