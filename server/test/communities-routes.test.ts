import { beforeAll, afterAll, it, expect } from 'vitest';
import { testDb } from './helpers/db.js';
import { wsClient } from './helpers/ws.js';
import { buildApp } from '../src/app.js';
import { tokenService } from '../src/auth/tokens.js';
import { users } from '../src/db/schema.js';
import { PERM } from '../src/core/permissions.js';
import type { FastifyInstance } from 'fastify';

let ctx: Awaited<ReturnType<typeof testDb>>;
let app: FastifyInstance;
let base: string;
let owner: { id: string; access: string };
let member: { id: string; access: string };

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
});
afterAll(async () => { await app.close(); await ctx.stop(); });

const auth = (u: { access: string }) => ({ authorization: `Bearer ${u.access}` });

async function makeCommunity(name: string) {
  const res = await app.inject({
    method: 'POST', url: '/communities', headers: auth(owner), payload: { name },
  });
  expect(res.statusCode).toBe(200);
  return res.json() as {
    id: string;
    channels: Array<{ id: string; name: string }>;
    roles: Array<{ id: string; isEveryone: boolean; permissions: string }>;
  };
}

async function join(commId: string, who: { access: string }) {
  const inv = (await app.inject({
    method: 'POST', url: `/communities/${commId}/invites`, headers: auth(owner),
  })).json() as { code: string };
  const res = await app.inject({
    method: 'POST', url: `/invites/${inv.code}/join`, headers: auth(who),
  });
  expect(res.statusCode).toBe(200);
}

it('full lifecycle: create → invite → join → seen in GET', async () => {
  const c = await makeCommunity('Cuates');
  await join(c.id, member);
  const got = (await app.inject({
    method: 'GET', url: `/communities/${c.id}`, headers: auth(member),
  })).json();
  expect(got.members).toHaveLength(2);
  expect(got.channels[0].name).toBe('general');
});

it('GET /communities lists mine', async () => {
  const res = await app.inject({ method: 'GET', url: '/communities', headers: auth(owner) });
  expect(res.statusCode).toBe(200);
  expect(res.json().length).toBeGreaterThan(0);
});

it('channel create broadcasts channel.created to connected members', async () => {
  const c = await makeCommunity('Eventos');
  await join(c.id, member);
  const ws = wsClient(base, member.access);
  await ws.open;
  const res = await app.inject({
    method: 'POST', url: `/communities/${c.id}/channels`,
    headers: auth(owner), payload: { name: 'anuncios' },
  });
  expect(res.statusCode).toBe(200);
  const ev = await ws.next();
  expect(ev.op).toBe('channel.created');
  expect(ev.d).toMatchObject({ name: 'anuncios', communityId: c.id });
  ws.close();
});

it('role management via REST enforces permission rules', async () => {
  const c = await makeCommunity('Reglas');
  await join(c.id, member);
  // member sin MANAGE_ROLES no puede crear roles
  const denied = await app.inject({
    method: 'POST', url: `/communities/${c.id}/roles`,
    headers: auth(member), payload: { name: 'Hax', permissions: '0' },
  });
  expect(denied.statusCode).toBe(403);
  // owner crea rol y lo asigna
  const role = (await app.inject({
    method: 'POST', url: `/communities/${c.id}/roles`,
    headers: auth(owner),
    payload: { name: 'Mod', permissions: PERM.KICK_MEMBERS.toString(), position: 3 },
  })).json();
  expect(role.permissions).toBe(PERM.KICK_MEMBERS.toString());
  const assign = await app.inject({
    method: 'PUT', url: `/communities/${c.id}/members/${member.id}/roles/${role.id}`,
    headers: auth(owner),
  });
  expect(assign.statusCode).toBe(204);
});

it('override PUT and kick DELETE work end to end', async () => {
  const c = await makeCommunity('Override');
  await join(c.id, member);
  const everyone = c.roles.find((r) => r.isEveryone)!;
  const over = await app.inject({
    method: 'PUT', url: `/channels/${c.channels[0].id}/overrides/${everyone.id}`,
    headers: auth(owner), payload: { allow: '0', deny: PERM.SEND_MESSAGES.toString() },
  });
  expect(over.statusCode).toBe(200);
  expect(over.json().deny).toBe(PERM.SEND_MESSAGES.toString());

  const kick = await app.inject({
    method: 'DELETE', url: `/communities/${c.id}/members/${member.id}`, headers: auth(owner),
  });
  expect(kick.statusCode).toBe(204);
  const gone = await app.inject({
    method: 'GET', url: `/communities/${c.id}`, headers: auth(member),
  });
  expect(gone.statusCode).toBe(404);
});

it('cannot mutate channels of another community via mismatched ids (IDOR)', async () => {
  const mine = await makeCommunity('Mia');
  // comunidad ajena: member es owner (tiene MANAGE_CHANNELS en la suya, no en la de owner)
  const foreign = (await app.inject({
    method: 'POST', url: '/communities', headers: auth(member), payload: { name: 'Ajena' },
  })).json() as { id: string; channels: Array<{ id: string }> };
  const foreignChannel = foreign.channels[0].id;

  // owner tiene perms en `mine` pero el canal es de `foreign`: debe ser 404 sin mutar
  const patched = await app.inject({
    method: 'PATCH', url: `/communities/${mine.id}/channels/${foreignChannel}`,
    headers: auth(owner), payload: { name: 'pwned' },
  });
  expect(patched.statusCode).toBe(404);
  const deleted = await app.inject({
    method: 'DELETE', url: `/communities/${mine.id}/channels/${foreignChannel}`,
    headers: auth(owner),
  });
  expect(deleted.statusCode).toBe(404);
  // el canal ajeno sigue intacto
  const still = (await app.inject({
    method: 'GET', url: `/communities/${foreign.id}`, headers: auth(member),
  })).json() as { channels: Array<{ id: string; name: string }> };
  expect(still.channels[0]).toMatchObject({ id: foreignChannel, name: 'general' });
});

it('DELETE community is owner-only', async () => {
  const c = await makeCommunity('Borrable');
  await join(c.id, member);
  const denied = await app.inject({
    method: 'DELETE', url: `/communities/${c.id}`, headers: auth(member),
  });
  expect(denied.statusCode).toBe(403);
  const ok = await app.inject({
    method: 'DELETE', url: `/communities/${c.id}`, headers: auth(owner),
  });
  expect(ok.statusCode).toBe(204);
});
