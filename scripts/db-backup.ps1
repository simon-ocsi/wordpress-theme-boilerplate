$ErrorActionPreference = "Stop"

$backupDirectory = "database"
$backupFile = "$backupDirectory/wordpress.sql"
$containerBackupFile = "/tmp/wordpress.sql"

New-Item -ItemType Directory -Force $backupDirectory | Out-Null

Write-Host "Backing up local WordPress database..." -ForegroundColor Cyan

# Create the dump inside the database container so PowerShell never handles
# the SQL contents as text. Database credentials come from the container's
# MARIADB_ROOT_PASSWORD and MARIADB_DATABASE environment variables.
docker compose exec -T db sh -lc 'mariadb-dump -u root -p"$MARIADB_ROOT_PASSWORD" --single-transaction --quick --lock-tables=false --default-character-set=utf8mb4 "$MARIADB_DATABASE" > /tmp/wordpress.sql'

if ($LASTEXITCODE -ne 0) {
    throw "Database backup failed."
}

# Copy the completed SQL dump byte-for-byte to the host.
docker compose cp "db:$containerBackupFile" $backupFile

if ($LASTEXITCODE -ne 0) {
    throw "Failed to copy database backup from container."
}

# Remove the temporary dump from the container.
docker compose exec -T db rm -f $containerBackupFile

if ($LASTEXITCODE -ne 0) {
    Write-Warning "Database backup succeeded, but temporary file cleanup failed."
}

Write-Host "Database backed up to $backupFile" -ForegroundColor Green
