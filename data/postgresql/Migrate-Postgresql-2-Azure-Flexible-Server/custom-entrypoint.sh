#!/bin/bash
set -e

# Substitute environment variables in init SQL files
for file in /docker-entrypoint-initdb.d/*.sql; do
  if [ -f "$file" ]; then
    envsubst < "$file" > "${file}.tmp" && mv "${file}.tmp" "$file"
  fi
done

# Call the original PostgreSQL entrypoint
if [ $# -eq 0 ]; then
  exec /usr/local/bin/docker-entrypoint.sh postgres
else
  exec /usr/local/bin/docker-entrypoint.sh "$@"
fi