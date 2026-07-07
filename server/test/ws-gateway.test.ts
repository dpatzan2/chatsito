import { beforeAll, afterAll, it, expect } from 'vitest';
import { testDb } from './helpers/db.js';
import { wsClient } from './helpers/ws.js';
import { buildApp } from '../src/app.js';
import { tokenService } from '../src/auth/tokens.js';
import { users } from '../src/db/schema.js';
import { getOrCreateConversation } from '../src/chat/service.js';
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
  const addr = app.server.address() as { port: number };
  base = `ws://127.0.0.1:${addr.port}/ws`;
  const rows = await ctx.db.insert(users)
    .values([{ phone: '50211111111' }, { phone: '50222222222' }]).returning();
  alice = { id: rows[0].id, access: await tokens.signAccess(rows[0].id) };
  bob = { id: rows[1].id, access: await tokens.signAccess(rows[1].id) };
  convId = (await getOrCreateConversation(ctx.db, alice.id, bob.id)).id;
});
afterAll(async () => { await app.close(); await ctx.stop(); });

it('rejects connection with bad token (close 4001)', async () => {
  const c = wsClient(`${base}?token=garbage`);
  expect(await c.closed).toBe(4001);
});

it('sys.ping → sys.ack with same seq', async () => {
  const c = wsClient(`${base}?token=${alice.access}`);
  await c.open;
  c.send('sys.ping', 7);
  const f = await c.next();
  expect(f).toMatchObject({ op: 'sys.ack', d: { seq: 7 } });
  c.close();
});

it('unknown op → sys.error VALIDATION with seq', async () => {
  const c = wsClient(`${base}?token=${alice.access}`);
  await c.open;
  c.send('nope.nope', 3);
  const f = await c.next();
  expect(f).toMatchObject({ op: 'sys.error', d: { seq: 3, code: 'VALIDATION' } });
  c.close();
});

it('msg.send: author gets ack, both members get msg.new', async () => {
  const a = wsClient(`${base}?token=${alice.access}`);
  const b = wsClient(`${base}?token=${bob.access}`);
  await Promise.all([a.open, b.open]);

  a.send('msg.send', 1, { conversationId: convId, type: 'text', content: { text: 'hola bob' } });

  const ack = await a.next();
  expect(ack.op).toBe('sys.ack');
  expect((ack.d as { seq: number }).seq).toBe(1);
  expect((ack.d as { id: string }).id).toBeTruthy();

  const evA = await a.next();   // el autor también recibe msg.new (multi-dispositivo)
  const evB = await b.next();
  for (const ev of [evA, evB]) {
    expect(ev.op).toBe('msg.new');
    expect(ev.d).toMatchObject({
      conversationId: convId, authorId: alice.id, type: 'text', content: { text: 'hola bob' },
    });
  }
  a.close(); b.close();
});

it('msg.send to a conversation you are not in → sys.error NOT_FOUND', async () => {
  const rows = await ctx.db.insert(users).values([{ phone: '50233333333' }]).returning();
  const tokens = tokenService(ctx.db, 's'.repeat(32));
  const eve = wsClient(`${base}?token=${await tokens.signAccess(rows[0].id)}`);
  await eve.open;
  eve.send('msg.send', 1, { conversationId: convId, type: 'text', content: { text: 'spy' } });
  const f = await eve.next();
  expect(f).toMatchObject({ op: 'sys.error', d: { seq: 1, code: 'NOT_FOUND' } });
  eve.close();
});

it('malformed frame → sys.error VALIDATION', async () => {
  const c = wsClient(`${base}?token=${alice.access}`);
  await c.open;
  c.ws.send('not json at all');
  const f = await c.next();
  expect(f).toMatchObject({ op: 'sys.error', d: { code: 'VALIDATION' } });
  c.close();
});
