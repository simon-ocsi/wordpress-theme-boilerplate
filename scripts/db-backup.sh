#!/usr/bin/env sh
set -eu
mkdir -p database
echo "Backing up local WordPress database..."
docker compose exec -T db sh -lc 'mariadb-dump -u root -p"$MARIADB_ROOT_PASSWORD" --single-transaction --quick --lock-tables=false "$MARIADB_DATABASE"' > database/wordpress.sql
echo "Database backed up to database/wordpress.sql"
