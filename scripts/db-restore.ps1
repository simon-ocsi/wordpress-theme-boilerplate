$ErrorActionPreference = "Stop"
$backupFile = "database/wordpress.sql"

if (-not (Test-Path $backupFile)) { throw "Database backup not found: $backupFile" }
Write-Host "Restoring local WordPress database..." -ForegroundColor Cyan

Get-Content -Raw $backupFile | docker compose exec -T db sh -lc 'mariadb -u root -p"$MARIADB_ROOT_PASSWORD" "$MARIADB_DATABASE"'

if ($LASTEXITCODE -ne 0) { throw "Database restore failed." }
Write-Host "Database restored from $backupFile" -ForegroundColor Green
