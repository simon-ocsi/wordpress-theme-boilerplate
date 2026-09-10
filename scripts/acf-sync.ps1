$ErrorActionPreference = "Stop"
Write-Host "Syncing ACF Local JSON..." -ForegroundColor Cyan

docker compose run --rm wpcli acf json sync
if ($LASTEXITCODE -ne 0) { throw "ACF JSON sync failed. Is ACF PRO active?" }

Write-Host "ACF JSON synced successfully." -ForegroundColor Green
