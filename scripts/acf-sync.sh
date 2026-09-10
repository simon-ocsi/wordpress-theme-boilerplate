#!/usr/bin/env sh
set -eu

if [ "${1:-}" = "--dry-run" ]; then
  echo "Previewing ACF Local JSON sync..."
  docker compose run --rm wpcli acf json sync --dry-run
else
  echo "Syncing ACF Local JSON..."
  docker compose run --rm wpcli acf json sync
  echo "ACF JSON synced successfully."
fi
