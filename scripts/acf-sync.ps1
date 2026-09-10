param(
    [switch]$DryRun
)

$ErrorActionPreference = "Stop"

if ($DryRun) {
    Write-Host "Previewing ACF Local JSON sync..." -ForegroundColor Cyan
    docker compose run --rm wpcli acf json sync --dry-run
} else {
    Write-Host "Syncing ACF Local JSON..." -ForegroundColor Cyan
    docker compose run --rm wpcli acf json sync
}

if ($LASTEXITCODE -ne 0) { throw "ACF JSON sync failed. Is ACF 6.8+ active?" }

if (-not $DryRun) {
    Write-Host "ACF JSON synced successfully." -ForegroundColor Green
}
