#!/usr/bin/env sh
set -eu
echo "Syncing ACF Local JSON..."
docker compose run --rm wpcli acf json sync
echo "ACF JSON synced successfully."
