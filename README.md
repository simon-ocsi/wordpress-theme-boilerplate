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
- phpMyAdmin
- Vite 7
- Tailwind CSS v4 via `@tailwindcss/vite`
- Sass
- ESLint and Prettier
- Lucide icons
- Optional ACF Local JSON workflow

## Requirements

- Docker Desktop
- Node.js 20.19+ (or a compatible newer LTS release)
- npm
- PowerShell 7+ **or** a POSIX-compatible shell for the included helper scripts
- Git

## Start a new project

Clone or copy the boilerplate, then from the repository root:

```powershell
Copy-Item .env.example .env
.\scripts\setup-theme.ps1 -ThemeName "My Project" -ThemeSlug "my-project"
docker compose up -d
cd wp-content/themes/my-project
npm install
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
npm run build
```

This creates `dist/` and a Vite manifest. The theme's PHP asset loader uses the Vite development server only when WordPress reports the `local` environment; otherwise it loads the built assets from the manifest.

Do not deploy the local `wp-config.php` unchanged to a production environment.

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

## ACF Local JSON

The starter theme contains an empty `acf-json/` directory. If a project uses ACF PRO, keep field group JSON there and commit it to Git.

With ACF PRO installed and active:

```powershell
.\scripts\acf-sync.ps1
```

ACF itself is not included in this repository because licensing and plugin requirements vary by project.

## What belongs in the boilerplate

Good candidates are environment and framework concerns that should behave the same on almost every theme project: local services, Vite integration, code formatting, reusable theme setup, accessibility foundations and development scripts.

Keep project-specific concerns out of the boilerplate: client branding, content copy, hard-coded URLs, analytics IDs, business-specific shortcodes, custom data tooling, client-only plugins and production credentials.

## Suggested project structure

```text
.
├── .env.example
├── .vscode/
├── database/
├── docker-compose.yml
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
            ├── style.css
            └── vite.config.js
```

## Security notes

The defaults in `.env.example` and `wp-config.php` are for local development only. Do not reuse them for a public deployment. Never commit production databases, secrets, API keys or personal data.

## macOS / Linux helper equivalents

The `scripts/` directory also includes `setup-theme.sh`, `db-backup.sh`, `db-restore.sh` and `acf-sync.sh` for teams not using PowerShell.
