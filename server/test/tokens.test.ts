import { beforeAll, afterAll, it, expect } from 'vitest';
import { testDb } from './helpers/db.js';
import { tokenService } from '../src/auth/tokens.js';
import { users } from '../src/db/schema.js';

const SECRET = 's'.repeat(32);
let ctx: Awaited<ReturnType<typeof testDb>>;
let tokens: ReturnType<typeof tokenService>;
let userId: string;

beforeAll(async () => {
  ctx = await testDb();
  tokens = tokenService(ctx.db, SECRET);
  const [u] = await ctx.db.insert(users).values({ phone: '50299999999' }).returning();
  userId = u.id;
});
afterAll(() => ctx.stop());

it('access token round-trip', async () => {
  const t = await tokens.signAccess(userId);
  expect(await tokens.verifyAccess(t)).toBe(userId);
});

it('garbage access token → AUTH_INVALID', async () => {
  await expect(tokens.verifyAccess('garbage')).rejects.toMatchObject({ code: 'AUTH_INVALID' });
});

it('refresh rotation invalidates the old token', async () => {
  const r1 = await tokens.createRefresh(userId);
  const { userId: uid, refresh: r2 } = await tokens.rotateRefresh(r1);
  expect(uid).toBe(userId);
  await expect(tokens.rotateRefresh(r1)).rejects.toMatchObject({ code: 'AUTH_INVALID' });
  const { refresh: r3 } = await tokens.rotateRefresh(r2);
  expect(r3).not.toBe(r2);
});

it('revoked refresh token stops working', async () => {
  const r = await tokens.createRefresh(userId);
  await tokens.revokeRefresh(r);
  await expect(tokens.rotateRefresh(r)).rejects.toMatchObject({ code: 'AUTH_INVALID' });
});
