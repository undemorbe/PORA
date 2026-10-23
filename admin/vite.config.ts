import react from '@vitejs/plugin-react';
import { defineConfig } from 'vitest/config';

export default defineConfig({
  plugins: [react()],
  build: {
    rollupOptions: {
      output: {
        // Recharts (+ d3) меняется редко и нужен только экранам с графиками; ядро — отдельным кэшируемым чанком.
        manualChunks(id) {
          if (!id.includes('/node_modules/')) return undefined;
          if (/\/node_modules\/(recharts|recharts-scale|react-smooth|d3-[^/]+|victory-vendor|internmap|decimal\.js-light|lodash|eventemitter3|fast-equals|tiny-invariant|clsx|react-is|prop-types|dom-helpers|react-transition-group)\//.test(id)) {
            return 'recharts';
          }
          if (/\/node_modules\/(react|react-dom|scheduler|react-router|react-router-dom|@remix-run\/router|@tanstack\/[^/]+)\//.test(id)) {
            return 'vendor';
          }
          return undefined;
        },
      },
    },
  },
  server: {
    port: 5173,
    // Dev: тот же origin, что и в проде через nginx — без CORS.
    proxy: { '/api': 'http://localhost:5040' },
  },
  test: {
    environment: 'jsdom',
    globals: true,
    setupFiles: './src/test/setup.ts',
  },
});
