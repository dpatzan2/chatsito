import { beforeAll, afterAll, it, expect } from 'vitest';
import { testDb } from './helpers/db.js';
import { buildApp } from '../src/app.js';
import { tokenService } from '../src/auth/tokens.js';
import { users, conversations, communities, communityMembers, roles } from '../src/db/schema.js';
import { DEFAULT_EVERYONE } from '../src/core/permissions.js';
import { presencePeers } from '../src/ws/presence.js';
import { Hub } from '../src/ws/hub.js';
import type { WebSocket } from 'ws';
import type { FastifyInstance } from 'fastify';

let ctx: Awaited<ReturnType<typeof testDb>>;
let app: FastifyInstance;
let access: string;
let me: string, partner: string, comrade: string, stranger: string;
let communityId: string;

beforeAll(async () => {
  ctx = await testDb();
  const tokens = tokenService(ctx.db, 's'.repeat(32));
  app = buildApp({ db: ctx.db, sms: { send: async () => {} }, tokens });
  const rows = await ctx.db.insert(users).values([
    { phone: '50211111111' }, { phone: '50222222222' },
    { phone: '50233333333' }, { phone: '50244444444' },
  ]).returning();
  [me, partner, comrade, stranger] = rows.map((r) => r.id);
  access = await tokens.signAccess(me);
  await ctx.db.insert(conversations).values({ userA: me, userB: partner });
  const [c] = await ctx.db.insert(communities).values({ name: 'X', ownerId: me }).returning();
  communityId = c.id;
  await ctx.db.insert(roles).values({
    communityId, name: '@everyone', position: 0, permissions: DEFAULT_EVERYONE, isEveryone: true,
  });
  await ctx.db.insert(communityMembers).values([
    { communityId, userId: me }, { communityId, userId: comrade },
  ]);
});
afterAll(() => ctx.stop());

it('presencePeers = pareja 1:1 + co-miembros, sin extraños ni yo', async () => {
  const peers = await presencePeers(ctx.db, me);
  expect(peers.sort()).toEqual([partner, comrade].sort());
  expect(peers).not.toContain(stranger);
  expect(peers).not.toContain(me);
});

it('Hub.isOnline refleja sockets vivos', () => {
  const hub = new Hub();
  const fake = { send() {} } as unknown as WebSocket;
  expect(hub.isOnline('u1')).toBe(false);
  hub.add('u1', fake);
  expect(hub.isOnline('u1')).toBe(true);
  hub.remove('u1', fake);
  expect(hub.isOnline('u1')).toBe(false);
});

it('GET /communities/:id marca online a los conectados', async () => {
  const fake = { send() {} } as unknown as WebSocket;
  app.hub.add(comrade, fake);
  const res = await app.inject({
    method: 'GET', url: `/communities/${communityId}`,
    headers: { authorization: `Bearer ${access}` },
  });
  expect(res.statusCode).toBe(200);
  const byId = new Map(res.json().members.map((m: { id: string; online: boolean }) => [m.id, m.online]));
  expect(byId.get(comrade)).toBe(true);
  expect(byId.get(me)).toBe(false);
  app.hub.remove(comrade, fake);
});
