import { defineConfig, loadEnv } from 'vite'
import tailwindcss from '@tailwindcss/vite'
import FullReload from 'vite-plugin-full-reload'

export default defineConfig(({ mode }) => {
  const env = loadEnv(mode, '../../../', '')
  const vitePort = Number(env.VITE_PORT || 5173)
  const wordpressPort = Number(env.WORDPRESS_PORT || 8080)

  return {
    plugins: [
      tailwindcss(),
      FullReload(['**/*.php']),
      {
        name: 'wordpress-dev-url',
        configureServer() {
          console.log(`\nWordPress: http://localhost:${wordpressPort}\n`)
        },
      },
    ],
    server: {
      host: '0.0.0.0',
      port: vitePort,
      strictPort: true,
      cors: true,
      origin: `http://localhost:${vitePort}`,
    },
    build: {
      outDir: 'dist',
      emptyOutDir: true,
      manifest: 'manifest.json',
      rollupOptions: {
        input: {
          app: 'src/js/app.js',
        },
      },
    },
  }
})
