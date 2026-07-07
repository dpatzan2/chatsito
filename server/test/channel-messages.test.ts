import { beforeAll, afterAll, it, expect } from 'vitest';
import { testDb } from './helpers/db.js';
import { wsClient } from './helpers/ws.js';
import { buildApp } from '../src/app.js';
import { tokenService } from '../src/auth/tokens.js';
import { users } from '../src/db/schema.js';
import { createCommunity, createInvite, joinByInvite } from '../src/community/service.js';
import { setOverride } from '../src/community/roles.js';
import { sendChannelMessage, channelRecipients } from '../src/community/channel-messages.js';
import { deleteMessage } from '../src/chat/service.js';
import { PERM } from '../src/core/permissions.js';
import type { FastifyInstance } from 'fastify';

let ctx: Awaited<ReturnType<typeof testDb>>;
let app: FastifyInstance;
let base: string;
let owner: { id: string; access: string };
let member: { id: string; access: string };
let comm: Awaited<ReturnType<typeof createCommunity>>;
let channelId: string;

beforeAll(async () => {
  ctx = await testDb();
  const tokens = tokenService(ctx.db, 's'.repeat(32));
  app = buildApp({ db: ctx.db, sms: { send: async () => {} }, tokens });
  await app.listen({ port: 0 });
  base = `ws://127.0.0.1:${(app.server.address() as { port: number }).port}/ws`;
  const rows = await ctx.db.insert(users)
    .values([{ phone: '50211111111' }, { phone: '50222222222' }]).returning();
  owner = { id: rows[0].id, access: await tokens.signAccess(rows[0].id) };
  member = { id: rows[1].id, access: await tokens.signAccess(rows[1].id) };
  comm = await createCommunity(ctx.db, owner.id, 'MsgComm');
  channelId = comm.channels[0].id;
  const inv = await createInvite(ctx.db, comm.id, owner.id);
  await joinByInvite(ctx.db, inv.code, member.id);
});
afterAll(async () => { await app.close(); await ctx.stop(); });

const auth = (u: { access: string }) => ({ authorization: `Bearer ${u.access}` });

it('msg.send to a channel fans out to members with VIEW_CHANNEL', async () => {
  const a = wsClient(base, owner.access);
  const b = wsClient(base, member.access);
  await Promise.all([a.open, b.open]);
  a.send('msg.send', 1, { channelId, type: 'text', content: { text: 'hola canal' } });
  expect((await a.next()).op).toBe('sys.ack');
  const evA = await a.next();
  const evB = await b.next();
  for (const ev of [evA, evB]) {
    expect(ev.op).toBe('msg.new');
    expect(ev.d).toMatchObject({ channelId, content: { text: 'hola canal' } });
  }
  a.close(); b.close();
});

it('deny SEND_MESSAGES blocks sending; deny VIEW_CHANNEL excludes from recipients', async () => {
  const everyone = comm.roles[0];
  await setOverride(ctx.db, channelId, everyone.id, owner.id, 0n, PERM.SEND_MESSAGES);
  await expect(sendChannelMessage(ctx.db, {
    channelId, authorId: member.id, type: 'text', content: { text: 'nope' },
  })).rejects.toMatchObject({ code: 'FORBIDDEN' });

  await setOverride(ctx.db, channelId, everyone.id, owner.id, 0n, PERM.VIEW_CHANNEL);
  const { userIds } = await channelRecipients(ctx.db, channelId);
  expect(userIds).toEqual([owner.id]); // owner siempre ve; member no
  await setOverride(ctx.db, channelId, everyone.id, owner.id, 0n, 0n); // limpiar
});

it('GET /channels/:id/messages returns history with keyset', async () => {
  for (const t of ['c1', 'c2', 'c3']) {
    await sendChannelMessage(ctx.db, {
      channelId, authorId: owner.id, type: 'text', content: { text: t },
    });
  }
  const res = await app.inject({
    method: 'GET', url: `/channels/${channelId}/messages?limit=2`, headers: auth(member),
  });
  expect(res.statusCode).toBe(200);
  const { messages } = res.json() as { messages: Array<{ id: string; content: { text: string } }> };
  expect(messages.map((m) => m.content.text)).toEqual(['c3', 'c2']);
  const res2 = await app.inject({
    method: 'GET',
    url: `/channels/${channelId}/messages?limit=2&before=${messages[1].id}`,
    headers: auth(member),
  });
  // 'hola canal' es del primer test (mismo canal, ULID anterior a c1)
  expect(res2.json().messages.map((m: { content: { text: string } }) => m.content.text))
    .toEqual(['c1', 'hola canal']);
});

it('moderator with MANAGE_MESSAGES can delete another member message in a channel', async () => {
  const msg = await sendChannelMessage(ctx.db, {
    channelId, authorId: member.id, type: 'text', content: { text: 'borrame' },
  });
  // member no puede borrar mensajes del owner
  const own = await sendChannelMessage(ctx.db, {
    channelId, authorId: owner.id, type: 'text', content: { text: 'intocable' },
  });
  await expect(deleteMessage(ctx.db, own.id, member.id)).rejects.toMatchObject({ code: 'FORBIDDEN' });
  // owner (ALL perms) borra el mensaje de member
  await deleteMessage(ctx.db, msg.id, owner.id);
});

it('sys.resume works with channel targets', async () => {
  const m1 = await sendChannelMessage(ctx.db, {
    channelId, authorId: owner.id, type: 'text', content: { text: 'r1' },
  });
  await sendChannelMessage(ctx.db, {
    channelId, authorId: owner.id, type: 'text', content: { text: 'r2' },
  });
  const b = wsClient(base, member.access);
  await b.open;
  b.send('sys.resume', 1, { targets: [{ channelId, lastMsgId: m1.id }] });
  expect((await b.next()).op).toBe('sys.ack');
  const resumed = await b.next();
  const target = (resumed.d as { targets: Array<{ channelId: string; messages: Array<{ content: { text: string } }> }> }).targets[0];
  expect(target.channelId).toBe(channelId);
  expect(target.messages.map((m) => m.content.text)).toEqual(['r2']);
  b.close();
});
