import { beforeAll, afterAll, it, expect } from 'vitest';
import { testDb } from './helpers/db.js';
import { wsClient } from './helpers/ws.js';
import { buildApp } from '../src/app.js';
import { tokenService } from '../src/auth/tokens.js';
import { users, readStates } from '../src/db/schema.js';
import { getOrCreateConversation, sendMessage } from '../src/chat/service.js';
import { eq } from 'drizzle-orm';
import type { FastifyInstance } from 'fastify';

let ctx: Awaited<ReturnType<typeof testDb>>;
let app: FastifyInstance;
let base: string;
let alice: { id: string; access: string };
let bob: { id: string; access: string };
let convId: string;

beforeAll(async () => {
  ctx = await testDb();
  const tokens = tokenService(ctx.db, 's'.repeat(32));
  app = buildApp({ db: ctx.db, sms: { send: async () => {} }, tokens });
  await app.listen({ port: 0 });
  base = `ws://127.0.0.1:${(app.server.address() as { port: number }).port}/ws`;
  const rows = await ctx.db.insert(users)
    .values([{ phone: '50211111111' }, { phone: '50222222222' }]).returning();
  alice = { id: rows[0].id, access: await tokens.signAccess(rows[0].id) };
  bob = { id: rows[1].id, access: await tokens.signAccess(rows[1].id) };
  convId = (await getOrCreateConversation(ctx.db, alice.id, bob.id)).id;
});
afterAll(async () => { await app.close(); await ctx.stop(); });

it('msg.delete broadcasts msg.deleted to both members', async () => {
  const { msg } = await sendMessage(ctx.db, {
    conversationId: convId, authorId: alice.id, type: 'text', content: { text: 'bye' },
  });
  const a = wsClient(base, alice.access);
  const b = wsClient(base, bob.access);
  await Promise.all([a.open, b.open]);

  a.send('msg.delete', 1, { id: msg.id });
  expect((await a.next()).op).toBe('sys.ack');
  const evA = await a.next();
  const evB = await b.next();
  for (const ev of [evA, evB]) {
    expect(ev).toMatchObject({ op: 'msg.deleted', d: { id: msg.id, conversationId: convId } });
  }
  a.close(); b.close();
});

it('typing.start reaches only the other member', async () => {
  const a = wsClient(base, alice.access);
  const b = wsClient(base, bob.access);
  await Promise.all([a.open, b.open]);

  a.send('typing.start', 2, { conversationId: convId });
  expect((await a.next()).op).toBe('sys.ack');       // ack para alice
  const ev = await b.next();                          // typing para bob
  expect(ev).toMatchObject({ op: 'typing', d: { conversationId: convId, userId: alice.id } });
  // alice no recibe el typing: su siguiente frame no llega (solo tuvo el ack)
  a.send('sys.ping', 3);
  expect((await a.next()).d).toMatchObject({ seq: 3 });
  a.close(); b.close();
});

it('read.mark persists the read state', async () => {
  const { msg } = await sendMessage(ctx.db, {
    conversationId: convId, authorId: bob.id, type: 'text', content: { text: 'leeme' },
  });
  const a = wsClient(base, alice.access);
  await a.open;
  a.send('read.mark', 1, { conversationId: convId, messageId: msg.id });
  expect((await a.next()).op).toBe('sys.ack');
  const [rs] = await ctx.db.select().from(readStates).where(eq(readStates.userId, alice.id));
  expect(rs.lastReadMessageId).toBe(msg.id);
  a.close();
});
