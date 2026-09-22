param(
    [Parameter(Mandatory = $true, Position = 0)][string]$ImportFile,
    [Parameter(Mandatory = $true)][string]$ProductionUrl,
    [string]$LocalUrl
)

$ErrorActionPreference = "Stop"
Set-StrictMode -Version Latest

if (-not $LocalUrl) {
    $wordPressPort = if ($env:WORDPRESS_PORT) { $env:WORDPRESS_PORT } else { '8080' }
    $LocalUrl = "http://localhost:$wordPressPort"
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$backupDirectory = Join-Path $repoRoot "database/backups"
$uploadsPath = Join-Path $repoRoot "wp-content/uploads"
$workingDirectory = Join-Path ([System.IO.Path]::GetTempPath()) ("wp-migrate-import-" + [guid]::NewGuid().ToString("N"))
$timestamp = Get-Date -Format "yyyyMMdd-HHmmss"

function Invoke-Docker {
    param([Parameter(Mandatory = $true)][string[]]$Arguments, [Parameter(Mandatory = $true)][string]$ErrorMessage)
    & docker @Arguments
    if ($LASTEXITCODE -ne 0) { throw $ErrorMessage }
}

function Get-ImportSql {
    param([Parameter(Mandatory = $true)][string]$Root)
    $files = @(Get-ChildItem -LiteralPath $Root -Recurse -File | Where-Object { $_.Name -match '\.sql(\.gz)?$' })
    if ($files.Count -eq 0) { return $null }
    $preferred = @($files | Where-Object { $_.Name -match '(database|dump|export|migrate)' })
    if ($preferred.Count -eq 0) { $preferred = $files }
    return ($preferred | Sort-Object Length -Descending | Select-Object -First 1).FullName
}

try {
    if (-not (Get-Command docker -ErrorAction SilentlyContinue)) { throw "Docker is not available in PATH." }
    if (-not (Test-Path -LiteralPath $ImportFile -PathType Leaf)) { throw "Import file not found: $ImportFile" }
    if (-not [uri]::IsWellFormedUriString($ProductionUrl, [UriKind]::Absolute)) { throw "ProductionUrl must be an absolute URL." }
    if (-not [uri]::IsWellFormedUriString($LocalUrl, [UriKind]::Absolute)) { throw "LocalUrl must be an absolute URL." }

    $resolvedImport = (Resolve-Path -LiteralPath $ImportFile).Path
    $lowerName = [IO.Path]::GetFileName($resolvedImport).ToLowerInvariant()
    if ($lowerName -notmatch '\.(zip|sql|sql\.gz)$') { throw "Use a WP Migrate Lite .zip export, .sql file, or .sql.gz file." }

    Write-Host "[1/7] Starting the local environment"
    Invoke-Docker @("compose", "up", "-d") "Docker Compose could not start the local environment."
    Invoke-Docker @("compose", "run", "--rm", "wpcli", "--info") "The WP-CLI service is unavailable."

    New-Item -ItemType Directory -Path $workingDirectory, $backupDirectory -Force | Out-Null
    if ($lowerName.EndsWith(".zip")) {
        Write-Host "[2/7] Extracting the WP Migrate Lite full-site export"
        Expand-Archive -LiteralPath $resolvedImport -DestinationPath $workingDirectory -Force
        $sqlPath = Get-ImportSql $workingDirectory
        $uploadsDirectory = Get-ChildItem -LiteralPath $workingDirectory -Recurse -Directory |
            Where-Object { $_.Name -ieq "uploads" } |
            Sort-Object { $_.FullName.Length } |
            Select-Object -First 1
    } else {
        Write-Host "[2/7] Reading the WP Migrate Lite database export"
        $sqlPath = $resolvedImport
        $uploadsDirectory = $null
    }
    if (-not $sqlPath) { throw "No .sql or .sql.gz database export was found." }

    Write-Host "[3/7] Backing up the current local database and uploads"
    $databaseBackup = Join-Path $backupDirectory "before-wp-migrate-$timestamp.sql"
    $containerBackup = "/tmp/before-wp-migrate-$timestamp.sql"
    Invoke-Docker @("compose", "exec", "-T", "db", "sh", "-lc", "mariadb-dump -u root -`$MARIADB_ROOT_PASSWORD --single-transaction --quick --lock-tables=false --default-character-set=utf8mb4 `$MARIADB_DATABASE > '$containerBackup'") "The local database backup failed."
    Invoke-Docker @("compose", "cp", "db:$containerBackup", $databaseBackup) "The database backup could not be copied to the host."
    Invoke-Docker @("compose", "exec", "-T", "db", "rm", "-f", $containerBackup) "The temporary database backup could not be removed."
    if ((Test-Path -LiteralPath $uploadsPath -PathType Container) -and (Get-ChildItem -LiteralPath $uploadsPath -Force)) {
        Compress-Archive -Path (Join-Path $uploadsPath "*") -DestinationPath (Join-Path $backupDirectory "uploads-before-wp-migrate-$timestamp.zip") -Force
    }

    Write-Host "[4/7] Importing the database"
    $containerImport = if ($sqlPath.EndsWith(".gz")) { "/tmp/wp-migrate-$timestamp.sql.gz" } else { "/tmp/wp-migrate-$timestamp.sql" }
    Invoke-Docker @("compose", "cp", $sqlPath, "db:$containerImport") "The database export could not be copied into the database container."
    $importCommand = if ($containerImport.EndsWith(".gz")) { "gzip -dc '$containerImport' | mariadb -u root -`$MARIADB_ROOT_PASSWORD `$MARIADB_DATABASE" } else { "mariadb -u root -`$MARIADB_ROOT_PASSWORD `$MARIADB_DATABASE < '$containerImport'" }
    Invoke-Docker @("compose", "exec", "-T", "db", "sh", "-lc", $importCommand) "The database import failed."
    Invoke-Docker @("compose", "exec", "-T", "db", "rm", "-f", $containerImport) "The temporary database export could not be removed."

    Write-Host "[5/7] Restoring exported uploads"
    if ($uploadsDirectory) {
        if (Test-Path -LiteralPath $uploadsPath) { Remove-Item -LiteralPath $uploadsPath -Recurse -Force }
        New-Item -ItemType Directory -Path $uploadsPath -Force | Out-Null
        foreach ($item in Get-ChildItem -LiteralPath $uploadsDirectory.FullName -Force) {
            Copy-Item -LiteralPath $item.FullName -Destination $uploadsPath -Recurse -Force
        }
    } else { Write-Host "No uploads directory was present; existing local uploads were left unchanged." }

    Write-Host "[6/7] Replacing production URLs"
    Invoke-Docker @("compose", "run", "--rm", "wpcli", "search-replace", $ProductionUrl.TrimEnd('/'), $LocalUrl.TrimEnd('/'), "--all-tables-with-prefix", "--skip-columns=guid", "--precise") "URL replacement failed."
    Invoke-Docker @("compose", "run", "--rm", "wpcli", "option", "update", "home", $LocalUrl.TrimEnd('/')) "The home URL could not be updated."
    Invoke-Docker @("compose", "run", "--rm", "wpcli", "option", "update", "siteurl", $LocalUrl.TrimEnd('/')) "The site URL could not be updated."

    Write-Host "[7/7] Flushing caches and verifying WordPress"
    Invoke-Docker @("compose", "run", "--rm", "wpcli", "cache", "flush") "The WordPress cache could not be flushed."
    Invoke-Docker @("compose", "run", "--rm", "wpcli", "rewrite", "flush", "--hard") "Rewrite rules could not be flushed."
    Invoke-Docker @("compose", "run", "--rm", "wpcli", "core", "is-installed") "WordPress did not pass the final check."
    Write-Host "Import complete. Pre-import backups are in $backupDirectory" -ForegroundColor Green
} finally {
    if (Test-Path -LiteralPath $workingDirectory) { Remove-Item -LiteralPath $workingDirectory -Recurse -Force -ErrorAction SilentlyContinue }
}
