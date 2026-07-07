import { describe, it, expect } from 'vitest';
import { loadConfig } from '../src/core/config.js';

const base = {
  DATABASE_URL: 'postgres://x:x@localhost:5432/x',
  JWT_SECRET: 'a'.repeat(32),
};

describe('loadConfig', () => {
  it('applies defaults and coerces PORT', () => {
    const c = loadConfig({ ...base, PORT: '8080' });
    expect(c.PORT).toBe(8080);
    expect(c.DATABASE_URL).toBe(base.DATABASE_URL);
  });

  it('rejects short JWT_SECRET', () => {
    expect(() => loadConfig({ ...base, JWT_SECRET: 'short' })).toThrow();
  });

  it('rejects missing DATABASE_URL', () => {
    expect(() => loadConfig({ JWT_SECRET: base.JWT_SECRET })).toThrow();
  });
});
