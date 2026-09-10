$ErrorActionPreference = "Stop"
Write-Host "Checking ACF Local JSON status..." -ForegroundColor Cyan

docker compose run --rm wpcli acf json status
if ($LASTEXITCODE -ne 0) { throw "ACF JSON status check failed. Is ACF 6.8+ active?" }
