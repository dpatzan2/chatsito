import { mkdtempSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { join } from 'node:path';
import { beforeAll, afterAll, it, expect } from 'vitest';
import { testDb } from './helpers/db.js';
import { buildApp } from '../src/app.js';
import { tokenService } from '../src/auth/tokens.js';
import { users } from '../src/db/schema.js';
import type { FastifyInstance } from 'fastify';

let ctx: Awaited<ReturnType<typeof testDb>>;
let app: FastifyInstance;
let access: string;

const BOUNDARY = 'testboundary';
const multipartBody = (filename: string, mime: string, data: string): Buffer =>
  Buffer.from(
    `--${BOUNDARY}\r\n` +
    `Content-Disposition: form-data; name="file"; filename="${filename}"\r\n` +
    `Content-Type: ${mime}\r\n\r\n` + data + `\r\n--${BOUNDARY}--\r\n`,
  );
const headers = () => ({
  authorization: `Bearer ${access}`,
  'content-type': `multipart/form-data; boundary=${BOUNDARY}`,
});

beforeAll(async () => {
  ctx = await testDb();
  const tokens = tokenService(ctx.db, 's'.repeat(32));
  app = buildApp({
    db: ctx.db, sms: { send: async () => {} }, tokens,
    uploadsDir: mkdtempSync(join(tmpdir(), 'chatsito-up-')),
  });
  const [u] = await ctx.db.insert(users).values({ phone: '50277777777' }).returning();
  access = await tokens.signAccess(u.id);
});
afterAll(() => ctx.stop());

it('POST /uploads sin token → 401', async () => {
  const res = await app.inject({ method: 'POST', url: '/uploads' });
  expect(res.statusCode).toBe(401);
});

it('sube un archivo y lo sirve', async () => {
  const res = await app.inject({
    method: 'POST', url: '/uploads', headers: headers(),
    payload: multipartBody('foto.png', 'image/png', 'PNGDATA'),
  });
  expect(res.statusCode).toBe(200);
  const j = res.json();
  expect(j.url).toMatch(/^\/uploads\/[0-9a-f-]+\.png$/);
  expect(j.name).toBe('foto.png');
  expect(j.mime).toBe('image/png');
  expect(j.size).toBe(7);

  const got = await app.inject({ method: 'GET', url: j.url });
  expect(got.statusCode).toBe(200);
  expect(got.body).toBe('PNGDATA');
});

it('sin archivo → VALIDATION 400', async () => {
  const res = await app.inject({
    method: 'POST', url: '/uploads', headers: headers(),
    payload: Buffer.from(`--${BOUNDARY}--\r\n`),
  });
  expect(res.statusCode).toBe(400);
});
