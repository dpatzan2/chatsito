import { beforeAll, afterAll, beforeEach, it, expect } from 'vitest';
import { testDb } from './helpers/db.js';
import { buildApp } from '../src/app.js';
import { tokenService } from '../src/auth/tokens.js';
import { otpCodes, users } from '../src/db/schema.js';
import type { SmsSender } from '../src/auth/sms.js';
import type { FastifyInstance } from 'fastify';

let ctx: Awaited<ReturnType<typeof testDb>>;
let app: FastifyInstance;
let sent: string[] = [];
const PHONE = '50212345678';
const codeFrom = (body: string) => body.match(/\d{6}/)![0];

beforeAll(async () => {
  ctx = await testDb();
  const sms: SmsSender = { async send(_p, body) { sent.push(body); } };
  app = buildApp({ db: ctx.db, sms, tokens: tokenService(ctx.db, 's'.repeat(32)) });
});
afterAll(() => ctx.stop());
beforeEach(async () => {
  sent = [];
  await ctx.db.delete(otpCodes);
  await ctx.db.delete(users);
});

async function login() {
  await app.inject({ method: 'POST', url: '/auth/otp', payload: { phone: PHONE } });
  const res = await app.inject({
    method: 'POST', url: '/auth/verify',
    payload: { phone: PHONE, code: codeFrom(sent[0]) },
  });
  return res.json() as { access: string; refresh: string; user: { id: string; phone: string } };
}

it('POST /auth/otp returns 204 and sends the code', async () => {
  const res = await app.inject({ method: 'POST', url: '/auth/otp', payload: { phone: PHONE } });
  expect(res.statusCode).toBe(204);
  expect(sent).toHaveLength(1);
});

it('invalid phone → VALIDATION 400', async () => {
  const res = await app.inject({ method: 'POST', url: '/auth/otp', payload: { phone: 'abc' } });
  expect(res.statusCode).toBe(400);
  expect(res.json().error.code).toBe('VALIDATION');
});

it('verify returns tokens and user', async () => {
  const { access, refresh, user } = await login();
  expect(access).toBeTruthy();
  expect(refresh).toBeTruthy();
  expect(user.phone).toBe(PHONE);
});

it('wrong code → OTP_INVALID 400', async () => {
  await app.inject({ method: 'POST', url: '/auth/otp', payload: { phone: PHONE } });
  const right = codeFrom(sent[0]);
  const wrong = right === '000000' ? '000001' : '000000';
  const res = await app.inject({
    method: 'POST', url: '/auth/verify', payload: { phone: PHONE, code: wrong },
  });
  expect(res.statusCode).toBe(400);
  expect(res.json().error.code).toBe('OTP_INVALID');
});

it('refresh rotates the pair and old refresh dies', async () => {
  const { refresh } = await login();
  const r1 = await app.inject({ method: 'POST', url: '/auth/refresh', payload: { refresh } });
  expect(r1.statusCode).toBe(200);
  expect(r1.json().access).toBeTruthy();
  const r2 = await app.inject({ method: 'POST', url: '/auth/refresh', payload: { refresh } });
  expect(r2.statusCode).toBe(401);
  expect(r2.json().error.code).toBe('AUTH_INVALID');
});

it('logout revokes the refresh token', async () => {
  const { refresh } = await login();
  const out = await app.inject({ method: 'POST', url: '/auth/logout', payload: { refresh } });
  expect(out.statusCode).toBe(204);
  const r = await app.inject({ method: 'POST', url: '/auth/refresh', payload: { refresh } });
  expect(r.statusCode).toBe(401);
});
