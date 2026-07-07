import { createHash } from 'node:crypto';
import { beforeAll, afterAll, it, expect } from 'vitest';
import { SignJWT } from 'jose';
import { testDb } from './helpers/db.js';
import { wsClient } from './helpers/ws.js';
import { buildApp } from '../src/app.js';
import { tokenService } from '../src/auth/tokens.js';
import { channels, users } from '../src/db/schema.js';
import { createCommunity, createInvite, joinByInvite } from '../src/community/service.js';
import { DEV_LIVEKIT } from '../src/voice/livekit.js';
import type { FastifyInstance } from 'fastify';

let ctx: Awaited<ReturnType<typeof testDb>>;
let app: FastifyInstance;
let base: string;
let owner: { id: string; access: string };
let member: { id: string; access: string };
let voiceId: string;

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
  const comm = await createCommunity(ctx.db, owner.id, 'HookComm');
  const [vc] = await ctx.db.insert(channels)
    .values({ communityId: comm.id, name: 'Sala', type: 'voice' }).returning();
  voiceId = vc.id;
  const inv = await createInvite(ctx.db, comm.id, owner.id);
  await joinByInvite(ctx.db, inv.code, member.id);
});
afterAll(async () => { await app.close(); await ctx.stop(); });

async function postWebhook(event: Record<string, unknown>, secret = DEV_LIVEKIT.apiSecret) {
  const body = JSON.stringify(event);
  const auth = await new SignJWT({ sha256: createHash('sha256').update(body).digest('base64') })
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuer(DEV_LIVEKIT.apiKey)
    .setIssuedAt()
    .setExpirationTime('1m')
    .sign(new TextEncoder().encode(secret));
  return app.inject({
    method: 'POST', url: '/livekit/webhook',
    headers: { authorization: auth, 'content-type': 'application/webhook+json' },
    payload: body,
  });
}

it('participant_joined broadcasts voice.state to channel members', async () => {
  const b = wsClient(base, member.access);
  await b.open;
  const res = await postWebhook({
    event: 'participant_joined', room: { name: voiceId },
    participant: { identity: owner.id },
  });
  expect(res.statusCode).toBe(200);
  const ev = await b.next();
  expect(ev.op).toBe('voice.state');
  expect(ev.d).toMatchObject({
    channelId: voiceId, members: [{ userId: owner.id, muted: false }],
  });
  b.close();
});

it('participant_left empties the room in the next voice.state', async () => {
  const b = wsClient(base, member.access);
  await b.open;
  await postWebhook({
    event: 'participant_left', room: { name: voiceId },
    participant: { identity: owner.id },
  });
  const ev = await b.next();
  expect(ev.op).toBe('voice.state');
  expect(ev.d).toMatchObject({ channelId: voiceId, members: [] });
  b.close();
});

it('room_finished clears state; unknown events are 200 no-ops', async () => {
  await postWebhook({
    event: 'participant_joined', room: { name: voiceId },
    participant: { identity: owner.id },
  });
  const done = await postWebhook({ event: 'room_finished', room: { name: voiceId } });
  expect(done.statusCode).toBe(200);
  const noop = await postWebhook({ event: 'track_published', room: { name: voiceId } });
  expect(noop.statusCode).toBe(200);
});

it('a webhook with a bad signature is rejected with 401', async () => {
  const res = await postWebhook(
    { event: 'participant_joined', room: { name: voiceId } }, 'wrong-secret-wrong',
  );
  expect(res.statusCode).toBe(401);
});
