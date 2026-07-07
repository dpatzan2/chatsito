import { beforeAll, afterAll, it, expect } from 'vitest';
import { testDb } from './helpers/db.js';
import { users } from '../src/db/schema.js';

let ctx: Awaited<ReturnType<typeof testDb>>;
beforeAll(async () => { ctx = await testDb(); });
afterAll(() => ctx.stop());

it('migrates schema and round-trips a user', async () => {
  const [u] = await ctx.db.insert(users).values({ phone: '50212345678' }).returning();
  expect(u.id).toMatch(/^[0-9a-f-]{36}$/);
  expect(u.phone).toBe('50212345678');
  expect(u.displayName).toBeNull();
  expect(u.createdAt).toBeInstanceOf(Date);
});

it('enforces unique phone', async () => {
  await expect(
    ctx.db.insert(users).values({ phone: '50212345678' }),
  ).rejects.toMatchObject({ cause: { code: '23505' } });
});
