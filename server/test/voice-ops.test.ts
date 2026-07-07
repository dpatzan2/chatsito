import { beforeAll, afterAll, it, expect } from 'vitest';
import { jwtVerify } from 'jose';
import { testDb } from './helpers/db.js';
import { wsClient } from './helpers/ws.js';
import { buildApp } from '../src/app.js';
import { tokenService } from '../src/auth/tokens.js';
import { channels, users } from '../src/db/schema.js';
import { createCommunity, createInvite, joinByInvite } from '../src/community/service.js';
import { setOverride } from '../src/community/roles.js';
import { PERM } from '../src/core/permissions.js';
import { DEV_LIVEKIT } from '../src/voice/livekit.js';
import type { FastifyInstance } from 'fastify';

let ctx: Awaited<ReturnType<typeof testDb>>;
let app: FastifyInstance;
let base: string;
let owner: { id: string; access: string };
let member: { id: string; access: string };
let comm: Awaited<ReturnType<typeof createCommunity>>;
let voiceId: string;
let textId: string;
const apiCalls: Array<Record<string, unknown>> = [];

beforeAll(async () => {
  ctx = await testDb();
  const tokens = tokenService(ctx.db, 's'.repeat(32));
  app = buildApp({
    db: ctx.db, sms: { send: async () => {} }, tokens,
    lkApi: {
      updateParticipant: async (room, identity, canPublish) => {
        apiCalls.push({ op: 'update', room, identity, canPublish });
      },
      removeParticipant: async (room, identity) => {
        apiCalls.push({ op: 'remove', room, identity });
      },
    },
  });
  await app.listen({ port: 0 });
  base = `ws://127.0.0.1:${(app.server.address() as { port: number }).port}/ws`;
  const rows = await ctx.db.insert(users)
    .values([{ phone: '50211111111' }, { phone: '50222222222' }]).returning();
  owner = { id: rows[0].id, access: await tokens.signAccess(rows[0].id) };
  member = { id: rows[1].id, access: await tokens.signAccess(rows[1].id) };
  comm = await createCommunity(ctx.db, owner.id, 'VozComm');
  textId = comm.channels[0].id;
  const [vc] = await ctx.db.insert(channels)
    .values({ communityId: comm.id, name: 'Sala', type: 'voice' }).returning();
  voiceId = vc.id;
  const inv = await createInvite(ctx.db, comm.id, owner.id);
  await joinByInvite(ctx.db, inv.code, member.id);
});
afterAll(async () => { await app.close(); await ctx.stop(); });

const lkSecret = new TextEncoder().encode(DEV_LIVEKIT.apiSecret);

it('voice.join on a text channel is VALIDATION', async () => {
  const a = wsClient(base, member.access);
  await a.open;
  a.send('voice.join', 1, { channelId: textId });
  const err = await a.next();
  expect(err.op).toBe('sys.error');
  expect(err.d).toMatchObject({ code: 'VALIDATION' });
  a.close();
});

it('voice.join returns voice.ready with a publish token for a normal member', async () => {
  const a = wsClient(base, member.access);
  await a.open;
  a.send('voice.join', 1, { channelId: voiceId });
  expect((await a.next()).op).toBe('sys.ack');
  const ready = await a.next();
  expect(ready.op).toBe('voice.ready');
  const d = ready.d as { channelId: string; token: string; url: string; members: unknown[] };
  expect(d.channelId).toBe(voiceId);
  expect(d.url).toBe(DEV_LIVEKIT.url);
  const { payload } = await jwtVerify(d.token, lkSecret);
  expect(payload.sub).toBe(member.id);
  expect(payload.video).toMatchObject({ room: voiceId, roomJoin: true, canPublish: true });
  a.close();
});

it('deny VOICE_SPEAK → listen-only token; deny VOICE_CONNECT → FORBIDDEN', async () => {
  const everyone = comm.roles[0];
  await setOverride(ctx.db, voiceId, everyone.id, owner.id, 0n, PERM.VOICE_SPEAK);
  const a = wsClient(base, member.access);
  await a.open;
  a.send('voice.join', 1, { channelId: voiceId });
  expect((await a.next()).op).toBe('sys.ack');
  const { payload } = await jwtVerify(
    (await a.next()).d!.token as string, lkSecret,
  );
  expect((payload.video as { canPublish: boolean }).canPublish).toBe(false);

  await setOverride(ctx.db, voiceId, everyone.id, owner.id, 0n,
    PERM.VOICE_SPEAK | PERM.VOICE_CONNECT);
  a.send('voice.join', 2, { channelId: voiceId });
  const err = await a.next();
  expect(err.op).toBe('sys.error');
  expect(err.d).toMatchObject({ code: 'FORBIDDEN' });
  await setOverride(ctx.db, voiceId, everyone.id, owner.id, 0n, 0n); // limpiar
  a.close();
});

it('voice.mute needs VOICE_MUTE_MEMBERS; owner mutes and voice.state fans out', async () => {
  const a = wsClient(base, owner.access);
  const b = wsClient(base, member.access);
  await Promise.all([a.open, b.open]);

  b.send('voice.mute', 1, { channelId: voiceId, userId: owner.id, muted: true });
  const denied = await b.next();
  expect(denied.op).toBe('sys.error');
  expect(denied.d).toMatchObject({ code: 'FORBIDDEN' });

  apiCalls.length = 0;
  a.send('voice.mute', 1, { channelId: voiceId, userId: member.id, muted: true });
  expect((await a.next()).op).toBe('sys.ack');
  expect(apiCalls).toEqual([
    { op: 'update', room: voiceId, identity: member.id, canPublish: false },
  ]);
  for (const ws of [a, b]) {
    const ev = await ws.next();
    expect(ev.op).toBe('voice.state');
    expect(ev.d).toMatchObject({
      channelId: voiceId, members: [{ userId: member.id, muted: true }],
    });
  }

  // unmute restaura canPublish porque member tiene VOICE_SPEAK
  a.send('voice.mute', 2, { channelId: voiceId, userId: member.id, muted: false });
  expect((await a.next()).op).toBe('sys.ack');
  expect(apiCalls[1]).toEqual(
    { op: 'update', room: voiceId, identity: member.id, canPublish: true },
  );
  a.close(); b.close();
});

it('voice.leave acks and calls RemoveParticipant', async () => {
  const a = wsClient(base, member.access);
  await a.open;
  apiCalls.length = 0;
  a.send('voice.leave', 1, { channelId: voiceId });
  expect((await a.next()).op).toBe('sys.ack');
  await new Promise((r) => setTimeout(r, 50)); // la llamada es best-effort tras el ack
  expect(apiCalls).toEqual([{ op: 'remove', room: voiceId, identity: member.id }]);
  a.close();
});
