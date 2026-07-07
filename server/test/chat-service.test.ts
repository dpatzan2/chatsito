import { beforeAll, afterAll, beforeEach, it, expect } from 'vitest';
import { testDb } from './helpers/db.js';
import {
  getOrCreateConversation, assertMember, sendMessage, getMessages,
  deleteMessage, markRead, listConversations,
} from '../src/chat/service.js';
import { conversations, messages, readStates, users } from '../src/db/schema.js';

let ctx: Awaited<ReturnType<typeof testDb>>;
let alice: string, bob: string, eve: string;

beforeAll(async () => {
  ctx = await testDb();
  const rows = await ctx.db.insert(users).values([
    { phone: '50211111111', displayName: 'Alice' },
    { phone: '50222222222', displayName: 'Bob' },
    { phone: '50233333333', displayName: 'Eve' },
  ]).returning();
  [alice, bob, eve] = rows.map((r) => r.id);
});
afterAll(() => ctx.stop());
beforeEach(async () => {
  await ctx.db.delete(readStates);
  await ctx.db.delete(messages);
  await ctx.db.delete(conversations);
});

it('getOrCreateConversation is idempotent regardless of argument order', async () => {
  const c1 = await getOrCreateConversation(ctx.db, alice, bob);
  const c2 = await getOrCreateConversation(ctx.db, bob, alice);
  expect(c2.id).toBe(c1.id);
});

it('rejects self-conversation and unknown users', async () => {
  await expect(getOrCreateConversation(ctx.db, alice, alice))
    .rejects.toMatchObject({ code: 'VALIDATION' });
  await expect(getOrCreateConversation(ctx.db, alice, '00000000-0000-0000-0000-000000000000'))
    .rejects.toMatchObject({ code: 'NOT_FOUND' });
});

it('non-members cannot access the conversation', async () => {
  const c = await getOrCreateConversation(ctx.db, alice, bob);
  await expect(assertMember(ctx.db, c.id, eve)).rejects.toMatchObject({ code: 'NOT_FOUND' });
});

it('sendMessage persists and getMessages paginates by keyset descending', async () => {
  const c = await getOrCreateConversation(ctx.db, alice, bob);
  for (let i = 0; i < 5; i++) {
    await sendMessage(ctx.db, {
      conversationId: c.id, authorId: alice, type: 'text', content: { text: `m${i}` },
    });
  }
  const page1 = await getMessages(ctx.db, c.id, bob, { limit: 2 });
  expect(page1.map((m) => (m.content as { text: string }).text)).toEqual(['m4', 'm3']);
  const page2 = await getMessages(ctx.db, c.id, bob, { before: page1[1].id, limit: 2 });
  expect(page2.map((m) => (m.content as { text: string }).text)).toEqual(['m2', 'm1']);
});

it('deleteMessage soft-deletes, only for the author, and hides from history', async () => {
  const c = await getOrCreateConversation(ctx.db, alice, bob);
  const { msg } = await sendMessage(ctx.db, {
    conversationId: c.id, authorId: alice, type: 'text', content: { text: 'oops' },
  });
  await expect(deleteMessage(ctx.db, msg.id, bob)).rejects.toMatchObject({ code: 'NOT_FOUND' });
  await deleteMessage(ctx.db, msg.id, alice);
  const rows = await getMessages(ctx.db, c.id, alice, {});
  expect(rows).toHaveLength(0);
});

it('listConversations returns other user, last message and unread count', async () => {
  const c = await getOrCreateConversation(ctx.db, alice, bob);
  const { msg: m1 } = await sendMessage(ctx.db, {
    conversationId: c.id, authorId: bob, type: 'text', content: { text: 'hola' },
  });
  await sendMessage(ctx.db, {
    conversationId: c.id, authorId: bob, type: 'text', content: { text: 'estás?' },
  });
  let list = await listConversations(ctx.db, alice);
  expect(list).toHaveLength(1);
  expect(list[0].other.displayName).toBe('Bob');
  expect((list[0].lastMessage!.content as { text: string }).text).toBe('estás?');
  expect(list[0].unread).toBe(2);

  await markRead(ctx.db, alice, c.id, m1.id);
  list = await listConversations(ctx.db, alice);
  expect(list[0].unread).toBe(1);

  // los mensajes propios no cuentan como no-leídos
  const listBob = await listConversations(ctx.db, bob);
  expect(listBob[0].unread).toBe(0);
});
