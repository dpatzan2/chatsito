import { beforeAll, afterAll, it, expect } from 'vitest';
import { ulid } from 'ulid';
import { testDb } from './helpers/db.js';
import { conversations, messages, readStates, users } from '../src/db/schema.js';

let ctx: Awaited<ReturnType<typeof testDb>>;
let alice: string, bob: string;

beforeAll(async () => {
  ctx = await testDb();
  const rows = await ctx.db.insert(users)
    .values([{ phone: '50211111111' }, { phone: '50222222222' }]).returning();
  [alice, bob] = rows.map((r) => r.id).sort();
});
afterAll(() => ctx.stop());

it('stores a conversation and enforces unique pair', async () => {
  const [c] = await ctx.db.insert(conversations)
    .values({ userA: alice, userB: bob }).returning();
  expect(c.id).toBeTruthy();
  await expect(
    ctx.db.insert(conversations).values({ userA: alice, userB: bob }),
  ).rejects.toMatchObject({ cause: { code: '23505' } });
});

it('stores a ULID message with jsonb content', async () => {
  const [c] = await ctx.db.select().from(conversations).limit(1);
  const id = ulid();
  const [m] = await ctx.db.insert(messages).values({
    id, conversationId: c.id, authorId: alice, type: 'text', content: { text: 'hola' },
  }).returning();
  expect(m.id).toBe(id);
  expect(m.content).toEqual({ text: 'hola' });
  expect(m.deletedAt).toBeNull();
});

it('read state upserts on composite PK', async () => {
  const [c] = await ctx.db.select().from(conversations).limit(1);
  await ctx.db.insert(readStates)
    .values({ userId: alice, conversationId: c.id, lastReadMessageId: '01A' });
  await ctx.db.insert(readStates)
    .values({ userId: alice, conversationId: c.id, lastReadMessageId: '01B' })
    .onConflictDoUpdate({
      target: [readStates.userId, readStates.conversationId],
      set: { lastReadMessageId: '01B' },
    });
  const rows = await ctx.db.select().from(readStates);
  expect(rows).toHaveLength(1);
  expect(rows[0].lastReadMessageId).toBe('01B');
});
