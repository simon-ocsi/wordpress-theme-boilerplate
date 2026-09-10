$ErrorActionPreference = "Stop"
$backupFile = "database/wordpress.sql"

New-Item -ItemType Directory -Force "database" | Out-Null
Write-Host "Backing up local WordPress database..." -ForegroundColor Cyan

docker compose exec -T db sh -lc 'mariadb-dump -u root -p"$MARIADB_ROOT_PASSWORD" --single-transaction --quick --lock-tables=false "$MARIADB_DATABASE"' | Set-Content -Encoding utf8 $backupFile

if ($LASTEXITCODE -ne 0) { throw "Database backup failed." }
Write-Host "Database backed up to $backupFile" -ForegroundColor Green
