#!/usr/bin/env sh
set -eu

backup_file="database/wordpress.sql"
container_backup_file="/tmp/wordpress.sql"

if [ ! -f "$backup_file" ]; then
	echo "Database backup not found: $backup_file" >&2
	exit 1
fi

echo "Restoring local WordPress database..."

# Copy the SQL dump into the database container byte-for-byte.
docker compose cp "$backup_file" "db:$container_backup_file"

# Restore inside the database container using its configured environment
# variables for the database password and database name.
docker compose exec -T db sh -lc \
	'mariadb -u root -p"$MARIADB_ROOT_PASSWORD" --default-character-set=utf8mb4 "$MARIADB_DATABASE" < /tmp/wordpress.sql'

# Remove the temporary dump from the container.
docker compose exec -T db rm -f "$container_backup_file"

echo "Database restored from $backup_file"
