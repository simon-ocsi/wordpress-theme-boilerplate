#!/usr/bin/env sh
set -eu
[ -f database/wordpress.sql ] || { echo "Database backup not found: database/wordpress.sql" >&2; exit 1; }
echo "Restoring local WordPress database..."
docker compose exec -T db sh -lc 'mariadb -u root -p"$MARIADB_ROOT_PASSWORD" "$MARIADB_DATABASE"' < database/wordpress.sql
echo "Database restored from database/wordpress.sql"
