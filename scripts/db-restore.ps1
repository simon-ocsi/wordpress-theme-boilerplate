$ErrorActionPreference = "Stop"

$backupFile = "database/wordpress.sql"
$containerBackupFile = "/tmp/wordpress.sql"

if (-not (Test-Path $backupFile)) {
    throw "Database backup not found: $backupFile"
}

Write-Host "Restoring local WordPress database..." -ForegroundColor Cyan

# Copy the SQL dump into the database container byte-for-byte so PowerShell
# never decodes or re-encodes the file.
docker compose cp $backupFile "db:$containerBackupFile"

if ($LASTEXITCODE -ne 0) {
    throw "Failed to copy database backup into container."
}

# Restore inside the database container using its configured environment
# variables for the database password and database name.
docker compose exec -T db sh -lc 'mariadb -u root -p"$MARIADB_ROOT_PASSWORD" --default-character-set=utf8mb4 "$MARIADB_DATABASE" < /tmp/wordpress.sql'

if ($LASTEXITCODE -ne 0) {
    throw "Database restore failed."
}

# Remove the temporary dump from the container.
docker compose exec -T db rm -f $containerBackupFile

if ($LASTEXITCODE -ne 0) {
    Write-Warning "Database restore succeeded, but temporary file cleanup failed."
}

Write-Host "Database restored from $backupFile" -ForegroundColor Green
