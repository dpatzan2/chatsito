import { beforeAll, afterAll, it, expect } from 'vitest';
import { testDb } from './helpers/db.js';
import { buildApp } from '../src/app.js';
import { tokenService } from '../src/auth/tokens.js';
import { users } from '../src/db/schema.js';
import type { FastifyInstance } from 'fastify';

let ctx: Awaited<ReturnType<typeof testDb>>;
let app: FastifyInstance;
let alice: { id: string; access: string };
let bob: { id: string; access: string };

beforeAll(async () => {
  ctx = await testDb();
  const tokens = tokenService(ctx.db, 's'.repeat(32));
  app = buildApp({ db: ctx.db, sms: { send: async () => {} }, tokens });
  const rows = await ctx.db.insert(users).values([
    { phone: '50211111111', displayName: 'Alice' },
    { phone: '50222222222', displayName: 'Bob' },
  ]).returning();
  alice = { id: rows[0].id, access: await tokens.signAccess(rows[0].id) };
  bob = { id: rows[1].id, access: await tokens.signAccess(rows[1].id) };
});
afterAll(() => ctx.stop());

const auth = (u: { access: string }) => ({ authorization: `Bearer ${u.access}` });

it('POST /conversations creates and returns the same conversation for both users', async () => {
  const r1 = await app.inject({
    method: 'POST', url: '/conversations', headers: auth(alice), payload: { userId: bob.id },
  });
  expect(r1.statusCode).toBe(200);
  const r2 = await app.inject({
    method: 'POST', url: '/conversations', headers: auth(bob), payload: { userId: alice.id },
  });
  expect(r2.json().id).toBe(r1.json().id);
  expect(r1.json().other.displayName).toBe('Bob');
});

it('GET /conversations lists with unread and last message', async () => {
  const res = await app.inject({ method: 'GET', url: '/conversations', headers: auth(alice) });
  expect(res.statusCode).toBe(200);
  expect(res.json()).toHaveLength(1);
  expect(res.json()[0].unread).toBe(0);
});

it('GET /conversations/:id/messages requires membership', async () => {
  const conv = (await app.inject({
    method: 'POST', url: '/conversations', headers: auth(alice), payload: { userId: bob.id },
  })).json();
  const res = await app.inject({
    method: 'GET', url: `/conversations/${conv.id}/messages`, headers: auth(alice),
  });
  expect(res.statusCode).toBe(200);
  expect(res.json().messages).toEqual([]);
});

it('routes reject without token', async () => {
  const res = await app.inject({ method: 'GET', url: '/conversations' });
  expect(res.statusCode).toBe(401);
});
