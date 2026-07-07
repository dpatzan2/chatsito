import { describe, it, expect } from 'vitest';
import { z } from 'zod';
import { buildApp } from '../src/app.js';
import { AppError } from '../src/core/errors.js';
import type { Deps } from '../src/app.js';

// ponytail: las rutas aún no existen; deps vacíos alcanzan para probar el error handler
const app = buildApp({} as Deps);
app.post('/boom', async () => { throw new AppError('FORBIDDEN', 'You shall not pass'); });
app.post('/zod', async (req) => z.object({ n: z.number() }).parse(req.body));
app.post('/crash', async () => { throw new Error('kaboom'); });

describe('error handling', () => {
  it('unknown route → NOT_FOUND with unified shape', async () => {
    const res = await app.inject({ method: 'GET', url: '/nope' });
    expect(res.statusCode).toBe(404);
    expect(res.json()).toEqual({ error: { code: 'NOT_FOUND', message: 'Route not found' } });
  });

  it('AppError → its code and status', async () => {
    const res = await app.inject({ method: 'POST', url: '/boom' });
    expect(res.statusCode).toBe(403);
    expect(res.json().error.code).toBe('FORBIDDEN');
  });

  it('ZodError → VALIDATION 400', async () => {
    const res = await app.inject({ method: 'POST', url: '/zod', payload: { n: 'nope' } });
    expect(res.statusCode).toBe(400);
    expect(res.json().error.code).toBe('VALIDATION');
  });

  it('unexpected error → INTERNAL 500 without leaking details', async () => {
    const res = await app.inject({ method: 'POST', url: '/crash' });
    expect(res.statusCode).toBe(500);
    expect(res.json()).toEqual({ error: { code: 'INTERNAL', message: 'Internal server error' } });
  });
});
