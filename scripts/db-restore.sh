#!/usr/bin/env sh
set -eu

backup_file="database/wordpress.sql"
container_backup_file="/tmp/wordpress.sql"

[ -f "$backup_file" ] || {
    echo "Database backup not found: $backup_file" >&2
    exit 1
}

echo "Restoring local WordPress database..."

# Copy the dump into the container and import it there byte-for-byte.
docker compose cp "$backup_file" "db:$container_backup_file"
docker compose exec -T db sh -lc 'mariadb -u root -p"$MARIADB_ROOT_PASSWORD" --default-character-set=utf8mb4 "$MARIADB_DATABASE" < /tmp/wordpress.sql'
docker compose exec -T db rm -f "$container_backup_file"

echo "Database restored from $backup_file"
