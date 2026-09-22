# WordPress Theme Development Boilerplate

A reusable local development environment for building custom WordPress themes with Docker, Vite and Tailwind CSS.

The repository is intentionally split into two layers:

- **Development environment:** WordPress, MariaDB, phpMyAdmin, WP-CLI, local PHP settings and database tooling.
- **Starter theme:** a small, unbranded classic PHP theme with a modern front-end asset pipeline.

Project-specific content models, copy, plugins and business logic should be added by the project rather than baked into the boilerplate.

## Stack

- WordPress 7.1 / PHP 8.3 / Apache
- MariaDB 11.4
- WP-CLI
- phpMyAdmin 5.2.3
- Vite 7
- Tailwind CSS v4 via `@tailwindcss/vite`
- Sass
- ESLint and Prettier
- PHPCS with WordPress Coding Standards
- GitHub Actions CI
- Lucide icons
- Optional ACF Local JSON workflow
- Optional WP Migrate Lite workflow, recommended through TGM Plugin Activation

## Requirements

- Docker Desktop
- Node.js 20.19+ (the repository includes `.nvmrc`)
- npm
- Composer 2 (only needed locally if you want to run PHPCS outside CI)
- PowerShell 7+ **or** a POSIX-compatible shell for the included helper scripts
- Git

## Start a new project

Clone or copy the boilerplate, then from the repository root:

```powershell
Copy-Item .env.example .env
.\scripts\setup-theme.ps1 -ThemeName "My Project" -ThemeSlug "my-project"
docker compose up -d
cd wp-content/themes/my-project
npm ci
npm run dev
```

Open:

- WordPress: `http://localhost:8080`
- phpMyAdmin: `http://localhost:8081`

Complete the WordPress installer and activate your renamed theme under **Appearance > Themes**.

`setup-theme.ps1` (or `scripts/setup-theme.sh`) renames the starter theme, PHP function/class prefixes and text domain, and updates the VS Code path. Run it once, before adding project code.

## Normal development

Start the WordPress stack:

```powershell
docker compose up -d
```

Start Vite from the active theme directory:

```powershell
npm run dev
```

Vite provides HMR for CSS and JavaScript. Changes to PHP files trigger a full browser reload.

Stop containers without deleting your database:

```powershell
docker compose stop
```

To delete the local database and WordPress Docker volumes as well:

```powershell
docker compose down -v
```

## Production assets

Run from the theme directory:

```powershell
npm ci
npm run build
```

This creates `dist/` and a Vite manifest. The theme's PHP asset loader uses the Vite development server only when WordPress reports the `local` environment; otherwise it loads the built assets from the manifest.

Do not deploy the local `wp-config.php` unchanged to a production environment.

## Code quality and CI

The boilerplate commits `package-lock.json`, so use `npm ci` for reproducible installs. `.nvmrc` pins the baseline Node.js runtime used by CI.

GitHub Actions runs the following checks on pushes and pull requests:

```text
npm ci
npm run lint
npm run format:check
npm run build
php -l
composer phpcs
```

PHP coding standards are configured in `phpcs.xml.dist` using the WordPress Coding Standards package. To run the PHP checks locally, install Composer dependencies from the repository root and run:

```powershell
composer install
composer phpcs
```

Use `composer phpcbf` to automatically fix PHPCS issues that are safe to correct mechanically.

## Database scripts

Create a local database dump:

```powershell
.\scripts\db-backup.ps1
```

Restore it:

```powershell
.\scripts\db-restore.ps1
```

Database dumps are ignored by default. Only version a sanitised seed database when your project explicitly needs one.

## Restore a WP Migrate Lite export

The starter theme recommends [WP Migrate Lite](https://wordpress.org/plugins/wp-migrate-db/) as an optional plugin through TGM Plugin Activation. Install it from the WordPress admin notice when a project uses this workflow; the theme does not require or automatically activate it.

Export the production site from **WP Migrate > Export**. The restore helpers accept a full-site `.zip`, a database `.sql`, or a compressed `.sql.gz` export. They start Docker, create timestamped local database and uploads backups, import the export, safely replace serialized production URLs with the local URL, flush caches, and verify WordPress.

PowerShell:

```powershell
.\scripts\import-wp-migrate.ps1 -ImportFile .\path\to\export.zip `
  -ProductionUrl "https://www.example.com"
```

macOS/Linux:

```sh
./scripts/import-wp-migrate.sh ./path/to/export.zip https://www.example.com
```

The local URL defaults to `http://localhost:8080` (or `WORDPRESS_PORT` when set). Override it with `-LocalUrl` in PowerShell or a third shell argument. A full-site export restores `uploads`; database-only exports leave local uploads unchanged. Pre-import backups are written to the ignored `database/backups/` directory.

This is a destructive local restore. Confirm the production URL and keep the generated backup until you have verified the imported site. Do not commit production exports because they may contain credentials or personal data.

## ACF Local JSON

The starter theme contains an empty `acf-json/` directory. If a project uses ACF, keep field group JSON there and commit it to Git. ACF writes Local JSON automatically when field groups are saved in WordPress admin.

For changes made in code or pulled from Git, **WP-CLI is the canonical sync mechanism**. The included PowerShell and shell scripts are convenience wrappers around the same commands. ACF 6.8+ is recommended for this workflow.

Check whether JSON and the database differ:

```powershell
docker compose run --rm wpcli acf json status
# or
.\scripts\acf-status.ps1
```

Preview a sync without changing the database:

```powershell
docker compose run --rm wpcli acf json sync --dry-run
# or
.\scripts\acf-sync.ps1 -DryRun
```

Apply the JSON changes to WordPress:

```powershell
docker compose run --rm wpcli acf json sync
# or
.\scripts\acf-sync.ps1
```

Coding agents should use the WP-CLI commands directly unless there is a reason to use the host-specific helper scripts. See `AGENTS.md` for the expected agent workflow.

ACF itself is not included in this repository because licensing and plugin requirements vary by project.

## What belongs in the boilerplate

Good candidates are environment and framework concerns that should behave the same on almost every theme project: local services, Vite integration, code formatting, reusable theme setup, accessibility foundations and development scripts.

Keep project-specific concerns out of the boilerplate: client branding, content copy, hard-coded URLs, analytics IDs, business-specific shortcodes, custom data tooling, client-only plugins and production credentials.

## Suggested project structure

```text
.
├── .env.example
├── .github/workflows/ci.yml
├── .nvmrc
├── .vscode/
├── composer.json
├── database/
├── docker-compose.yml
├── phpcs.xml.dist
├── php/
├── scripts/
├── wp-config.php
└── wp-content/
    ├── plugins/
    └── themes/
        └── starter-theme/
            ├── acf-json/
            ├── inc/
            ├── src/
            │   ├── css/
            │   ├── js/
            │   └── scss/
            ├── template-parts/
            ├── functions.php
            ├── package.json
            ├── package-lock.json
            ├── style.css
            └── vite.config.js
```

## Security notes

The defaults in `.env.example` and `wp-config.php` are for local development only. Do not reuse them for a public deployment. Never commit production databases, secrets, API keys or personal data.

## macOS / Linux helper equivalents

The `scripts/` directory also includes `setup-theme.sh`, `db-backup.sh`, `db-restore.sh`, `import-wp-migrate.sh`, `acf-status.sh` and `acf-sync.sh` for teams not using PowerShell.
