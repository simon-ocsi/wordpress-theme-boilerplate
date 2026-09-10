# Starter Theme

A deliberately small classic WordPress theme scaffold. It is intended to provide the wiring, not prescribe a site's content model.

## Included

- Vite development server and production manifest loading
- Tailwind CSS v4
- SCSS entry point
- ESLint and Prettier
- Reproducible npm dependencies via `package-lock.json`
- Lucide icons
- Accessible responsive navigation scaffold
- Basic `index`, `page`, `single` and `404` templates
- `theme.json`
- `acf-json/` ready for ACF Local JSON

## Asset workflow

```powershell
npm ci
npm run dev
```

Production build:

```powershell
npm run build
```

The theme automatically uses Vite in the local Docker environment. Outside `WP_ENVIRONMENT_TYPE=local`, it loads files from `dist/manifest.json`.

## ACF

ACF is intentionally not bundled. If your project uses ACF PRO, install it separately and keep exported Local JSON in `acf-json/`.

## Customise first

1. Run `scripts/setup-theme.ps1` from the repository root.
2. Replace the starter brand tokens in `src/css/tailwind.css`.
3. Add project-specific templates and components.
4. Add only the plugins your project actually requires.
