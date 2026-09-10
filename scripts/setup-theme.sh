#!/usr/bin/env sh
set -eu

if [ "$#" -ne 2 ]; then
  echo "Usage: ./scripts/setup-theme.sh \"Theme Name\" theme-slug" >&2
  exit 1
fi

THEME_NAME=$1
THEME_SLUG=$2
case "$THEME_SLUG" in
  *[!a-z0-9-]*|'') echo "Theme slug must contain only lowercase letters, numbers and hyphens." >&2; exit 1 ;;
esac

OLD_DIR="wp-content/themes/starter-theme"
NEW_DIR="wp-content/themes/$THEME_SLUG"
[ -d "$OLD_DIR" ] || { echo "Starter theme not found at $OLD_DIR" >&2; exit 1; }
[ ! -e "$NEW_DIR" ] || { echo "Theme directory already exists: $NEW_DIR" >&2; exit 1; }

PHP_PREFIX=$(printf '%s' "$THEME_SLUG" | tr '-' '_')
CLASS_PREFIX=$(printf '%s' "$THEME_SLUG" | awk -F- '{for(i=1;i<=NF;i++){printf "%s%s", toupper(substr($i,1,1)) substr($i,2), (i<NF?"_":"")}}')
export THEME_NAME THEME_SLUG PHP_PREFIX CLASS_PREFIX

mv "$OLD_DIR" "$NEW_DIR"
find "$NEW_DIR" -type f \( -name '*.php' -o -name '*.js' -o -name '*.css' -o -name '*.scss' -o -name '*.json' -o -name '*.md' \) -exec perl -0pi -e '
  s/Starter Theme/$ENV{THEME_NAME}/g;
  s/starter-theme/$ENV{THEME_SLUG}/g;
  s/starter_theme/$ENV{PHP_PREFIX}/g;
  s/Starter_Theme/$ENV{CLASS_PREFIX}/g;
' {} +

perl -0pi -e 's/starter-theme/$ENV{THEME_SLUG}/g' .vscode/settings.json
perl -0pi -e 's/THEME_SLUG=starter-theme/THEME_SLUG=$ENV{THEME_SLUG}/g' .env.example

echo "Created '$THEME_NAME' in $NEW_DIR"
echo "Next: cd $NEW_DIR && npm install && npm run dev"
