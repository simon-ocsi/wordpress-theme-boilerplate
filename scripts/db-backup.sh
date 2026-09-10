#!/usr/bin/env sh
set -eu

backup_file="database/wordpress.sql"
container_backup_file="/tmp/wordpress.sql"

mkdir -p database
echo "Backing up local WordPress database..."

# Create the dump inside the database container, then copy it byte-for-byte.
docker compose exec -T db sh -lc 'mariadb-dump -u root -p"$MARIADB_ROOT_PASSWORD" --single-transaction --quick --lock-tables=false --default-character-set=utf8mb4 "$MARIADB_DATABASE" > /tmp/wordpress.sql'
docker compose cp "db:$container_backup_file" "$backup_file"
docker compose exec -T db rm -f "$container_backup_file"

echo "Database backed up to $backup_file"
