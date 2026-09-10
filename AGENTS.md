# Coding agent instructions

This repository is a reusable WordPress theme-development environment. Keep changes generic unless the project using the boilerplate has introduced its own requirements.

## WordPress and Docker

- Run WordPress CLI commands through the `wpcli` Docker service from the repository root.
- Prefer `docker compose run --rm wpcli <command>` to host-installed WP-CLI so commands execute against the same PHP, WordPress files and database as the local environment.
- Do not edit the WordPress database directly when an established WordPress or plugin CLI operation exists.
- Do not commit production credentials, database dumps containing personal data, `node_modules/`, generated caches or local environment secrets.

## ACF workflow

`acf-json/` is the version-controlled source for ACF field-group configuration.

When an ACF field group is saved in WordPress admin, ACF Local JSON updates the corresponding JSON file automatically.

When creating or changing ACF configuration in code or JSON:

1. Edit or create the relevant file in the active theme's `acf-json/` directory.
2. Check the pending state:
   `docker compose run --rm wpcli acf json status`
3. Preview the database change where appropriate:
   `docker compose run --rm wpcli acf json sync --dry-run`
4. Apply it:
   `docker compose run --rm wpcli acf json sync`
5. Verify the field group in WordPress and ensure the JSON remains committed to Git.

The scripts in `scripts/acf-status.*` and `scripts/acf-sync.*` are convenience wrappers for humans. Agents should normally use the WP-CLI commands directly because they are cross-platform and explicit.

Do not maintain a separate custom export/import implementation for ACF when the supported CLI workflow is available.

## Theme development

- Run front-end commands from the active theme directory.
- Use `npm run dev` for local Vite development and `npm run build` before validating a production-ready change.
- Keep reusable environment concerns separate from project-specific copy, branding, analytics, content models and business logic.
- Follow the existing PHP naming/text-domain conventions after the starter has been renamed with `scripts/setup-theme.ps1` or `scripts/setup-theme.sh`.
