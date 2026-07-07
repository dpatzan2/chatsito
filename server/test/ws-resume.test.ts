import { beforeAll, afterAll, it, expect } from 'vitest';
import { testDb } from './helpers/db.js';
import { wsClient } from './helpers/ws.js';
import { buildApp } from '../src/app.js';
import { tokenService } from '../src/auth/tokens.js';
import { users } from '../src/db/schema.js';
import { getOrCreateConversation, sendMessage, deleteMessage } from '../src/chat/service.js';
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

it('sys.resume returns messages missed while offline, skipping deleted ones', async () => {
  // bob "estaba conectado" hasta m0, luego se desconecta
  const { msg: m0 } = await sendMessage(ctx.db, {
    conversationId: convId, authorId: alice.id, type: 'text', content: { text: 'm0' },
  });
  // llegan 3 mensajes mientras bob está offline; uno se borra
  const { msg: m1 } = await sendMessage(ctx.db, {
    conversationId: convId, authorId: alice.id, type: 'text', content: { text: 'm1' },
  });
  const { msg: m2 } = await sendMessage(ctx.db, {
    conversationId: convId, authorId: alice.id, type: 'text', content: { text: 'm2' },
  });
  await sendMessage(ctx.db, {
    conversationId: convId, authorId: alice.id, type: 'text', content: { text: 'm3' },
  });
  await deleteMessage(ctx.db, m2.id, alice.id);

  const b = wsClient(base, bob.access);
  await b.open;
  b.send('sys.resume', 1, { targets: [{ conversationId: convId, lastMsgId: m0.id }] });
  expect((await b.next()).op).toBe('sys.ack');
  const resumed = await b.next();
  expect(resumed.op).toBe('sys.resumed');
  const target = (resumed.d as { targets: Array<{ conversationId: string; messages: Array<{ id: string; content: { text: string } }> }> }).targets[0];
  expect(target.conversationId).toBe(convId);
  expect(target.messages.map((m) => m.content.text)).toEqual(['m1', 'm3']);
  expect(target.messages[0].id).toBe(m1.id);
  b.close();
});

it('sys.resume rejects conversations you are not a member of', async () => {
  const rows = await ctx.db.insert(users).values([{ phone: '50233333333' }]).returning();
  const tokens = tokenService(ctx.db, 's'.repeat(32));
  const eve = wsClient(base, await tokens.signAccess(rows[0].id));
  await eve.open;
  eve.send('sys.resume', 1, { targets: [{ conversationId: convId, lastMsgId: '0' }] });
  const f = await eve.next();
  expect(f).toMatchObject({ op: 'sys.error', d: { seq: 1, code: 'NOT_FOUND' } });
  eve.close();
});
