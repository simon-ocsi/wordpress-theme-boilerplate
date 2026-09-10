#!/usr/bin/env sh
set -eu
echo "Checking ACF Local JSON status..."
docker compose run --rm wpcli acf json status
