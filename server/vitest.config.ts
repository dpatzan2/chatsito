import { defineConfig } from 'vitest/config';

export default defineConfig({
  // ponytail: cada archivo de test levanta su propio Postgres (Testcontainers);
  // sin límite, ~18 contenedores en paralelo hacen timeout a los tests de WS
  test: { hookTimeout: 120_000, testTimeout: 30_000, maxWorkers: 4 },
});
