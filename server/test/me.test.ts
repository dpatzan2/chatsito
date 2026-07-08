import { beforeAll, afterAll, it, expect } from 'vitest';
import { testDb } from './helpers/db.js';
import { buildApp } from '../src/app.js';
import { tokenService } from '../src/auth/tokens.js';
import { users } from '../src/db/schema.js';
import type { FastifyInstance } from 'fastify';

let ctx: Awaited<ReturnType<typeof testDb>>;
let app: FastifyInstance;
let access: string;
let userId: string;

beforeAll(async () => {
  ctx = await testDb();
  const tokens = tokenService(ctx.db, 's'.repeat(32));
  app = buildApp({ db: ctx.db, sms: { send: async () => {} }, tokens });
  const [u] = await ctx.db.insert(users).values({ phone: '50288888888' }).returning();
  userId = u.id;
  access = await tokens.signAccess(userId);
});
afterAll(() => ctx.stop());

it('GET /me without token → AUTH_INVALID 401', async () => {
  const res = await app.inject({ method: 'GET', url: '/me' });
  expect(res.statusCode).toBe(401);
  expect(res.json().error.code).toBe('AUTH_INVALID');
});

it('GET /me returns the user', async () => {
  const res = await app.inject({
    method: 'GET', url: '/me', headers: { authorization: `Bearer ${access}` },
  });
  expect(res.statusCode).toBe(200);
  expect(res.json().id).toBe(userId);
});

it('PATCH /me updates display name and avatar color', async () => {
  const res = await app.inject({
    method: 'PATCH', url: '/me',
    headers: { authorization: `Bearer ${access}` },
    payload: { displayName: 'Diego', avatarColor: '#ff8800' },
  });
  expect(res.statusCode).toBe(200);
  expect(res.json().displayName).toBe('Diego');
  expect(res.json().avatarColor).toBe('#ff8800');
});

it('PATCH /me rejects bad color → VALIDATION', async () => {
  const res = await app.inject({
    method: 'PATCH', url: '/me',
    headers: { authorization: `Bearer ${access}` },
    payload: { avatarColor: 'rojo' },
  });
  expect(res.statusCode).toBe(400);
});

it('GET /users/lookup finds a user by phone', async () => {
  const res = await app.inject({
    method: 'GET', url: '/users/lookup?phone=50288888888',
    headers: { authorization: `Bearer ${access}` },
  });
  expect(res.statusCode).toBe(200);
  expect(res.json().id).toBe(userId);
});

it('GET /users/lookup unknown phone → NOT_FOUND', async () => {
  const res = await app.inject({
    method: 'GET', url: '/users/lookup?phone=50200000000',
    headers: { authorization: `Bearer ${access}` },
  });
  expect(res.statusCode).toBe(404);
});
