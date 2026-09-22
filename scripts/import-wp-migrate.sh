#!/usr/bin/env sh
set -eu

if [ "$#" -lt 2 ] || [ "$#" -gt 3 ]; then
	echo "Usage: ./scripts/import-wp-migrate.sh <export.zip|export.sql|export.sql.gz> <production-url> [local-url]" >&2
	exit 1
fi

import_file=$1
production_url=${2%/}
local_url=${3:-"http://localhost:${WORDPRESS_PORT:-8080}"}
local_url=${local_url%/}
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
backup_directory="$repo_root/database/backups"
uploads_path="$repo_root/wp-content/uploads"
working_directory=$(mktemp -d "${TMPDIR:-/tmp}/wp-migrate-import.XXXXXX")
timestamp=$(date +%Y%m%d-%H%M%S)

cleanup() { rm -rf -- "$working_directory"; }
trap cleanup EXIT HUP INT TERM

[ -f "$import_file" ] || { echo "Import file not found: $import_file" >&2; exit 1; }
case "$import_file" in *.zip|*.sql|*.sql.gz) ;; *) echo "Use a WP Migrate Lite .zip, .sql, or .sql.gz export." >&2; exit 1 ;; esac
command -v docker >/dev/null 2>&1 || { echo "Docker is not available in PATH." >&2; exit 1; }

cd "$repo_root"
echo "[1/7] Starting the local environment"
docker compose up -d
docker compose run --rm wpcli --info

echo "[2/7] Reading the WP Migrate Lite export"
uploads_directory=
case "$import_file" in
	*.zip)
		command -v unzip >/dev/null 2>&1 || { echo "unzip is required to read a full-site export." >&2; exit 1; }
		unzip -q "$import_file" -d "$working_directory"
		sql_path=$(find "$working_directory" -type f \( -name '*.sql' -o -name '*.sql.gz' \) -print | head -n 1)
		uploads_directory=$(find "$working_directory" -type d -name uploads -print | head -n 1)
		;;
	*) sql_path=$(CDPATH= cd -- "$(dirname -- "$import_file")" && pwd)/$(basename -- "$import_file") ;;
esac
[ -n "${sql_path:-}" ] || { echo "No .sql or .sql.gz database export was found." >&2; exit 1; }

echo "[3/7] Backing up the current local database and uploads"
mkdir -p "$backup_directory"
container_backup="/tmp/before-wp-migrate-$timestamp.sql"
docker compose exec -T db sh -lc "mariadb-dump -u root -\$MARIADB_ROOT_PASSWORD --single-transaction --quick --lock-tables=false --default-character-set=utf8mb4 \$MARIADB_DATABASE > '$container_backup'"
docker compose cp "db:$container_backup" "$backup_directory/before-wp-migrate-$timestamp.sql"
docker compose exec -T db rm -f "$container_backup"
if [ -d "$uploads_path" ] && [ -n "$(find "$uploads_path" -mindepth 1 -print -quit)" ]; then
	tar -czf "$backup_directory/uploads-before-wp-migrate-$timestamp.tar.gz" -C "$uploads_path" .
fi

echo "[4/7] Importing the database"
case "$sql_path" in *.gz) container_import="/tmp/wp-migrate-$timestamp.sql.gz" ;; *) container_import="/tmp/wp-migrate-$timestamp.sql" ;; esac
docker compose cp "$sql_path" "db:$container_import"
case "$container_import" in
	*.gz) docker compose exec -T db sh -lc "gzip -dc '$container_import' | mariadb -u root -\$MARIADB_ROOT_PASSWORD \$MARIADB_DATABASE" ;;
	*) docker compose exec -T db sh -lc "mariadb -u root -\$MARIADB_ROOT_PASSWORD \$MARIADB_DATABASE < '$container_import'" ;;
esac
docker compose exec -T db rm -f "$container_import"

echo "[5/7] Restoring exported uploads"
if [ -n "$uploads_directory" ]; then
	rm -rf -- "$uploads_path"
	mkdir -p "$uploads_path"
	cp -R "$uploads_directory"/. "$uploads_path"/
else
	echo "No uploads directory was present; existing local uploads were left unchanged."
fi

echo "[6/7] Replacing production URLs"
docker compose run --rm wpcli search-replace "$production_url" "$local_url" --all-tables-with-prefix --skip-columns=guid --precise
docker compose run --rm wpcli option update home "$local_url"
docker compose run --rm wpcli option update siteurl "$local_url"

echo "[7/7] Flushing caches and verifying WordPress"
docker compose run --rm wpcli cache flush
docker compose run --rm wpcli rewrite flush --hard
docker compose run --rm wpcli core is-installed
echo "Import complete. Pre-import backups are in $backup_directory"
