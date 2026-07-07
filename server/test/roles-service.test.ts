import { beforeAll, afterAll, it, expect } from 'vitest';
import { testDb } from './helpers/db.js';
import { createCommunity, createInvite, joinByInvite, memberPerms } from '../src/community/service.js';
import { createRole, updateRole, deleteRole, assignRole, unassignRole, setOverride } from '../src/community/roles.js';
import { users } from '../src/db/schema.js';
import { PERM, DEFAULT_EVERYONE, can } from '../src/core/permissions.js';

let ctx: Awaited<ReturnType<typeof testDb>>;
let owner: string, mod: string, pleb: string;
let comm: Awaited<ReturnType<typeof createCommunity>>;
let everyoneId: string;

beforeAll(async () => {
  ctx = await testDb();
  const rows = await ctx.db.insert(users).values([
    { phone: '50211111111' }, { phone: '50222222222' }, { phone: '50233333333' },
  ]).returning();
  [owner, mod, pleb] = rows.map((r) => r.id);
  comm = await createCommunity(ctx.db, owner, 'Roles');
  everyoneId = comm.roles[0].id;
  const inv = await createInvite(ctx.db, comm.id, owner);
  await joinByInvite(ctx.db, inv.code, mod);
  await joinByInvite(ctx.db, inv.code, pleb);
});
afterAll(() => ctx.stop());

it('owner creates a role and assigns it; the member gains its perms', async () => {
  const role = await createRole(ctx.db, comm.id, owner, {
    name: 'Mod', color: '#ff0000',
    permissions: PERM.KICK_MEMBERS | PERM.MANAGE_ROLES | PERM.MANAGE_MESSAGES,
    position: 5,
  });
  await assignRole(ctx.db, comm.id, owner, mod, role.id);
  const mp = (await memberPerms(ctx.db, comm.id, mod))!;
  expect(can(mp.perms, PERM.KICK_MEMBERS)).toBe(true);
  expect(mp.highest).toBe(5);
});

it('cannot grant permissions you do not have', async () => {
  // mod tiene MANAGE_ROLES pero no ADMIN
  await expect(createRole(ctx.db, comm.id, mod, {
    name: 'Sneaky', permissions: PERM.ADMIN, position: 1,
  })).rejects.toMatchObject({ code: 'FORBIDDEN' });
});

it('cannot create or touch roles at or above your highest position', async () => {
  await expect(createRole(ctx.db, comm.id, mod, {
    name: 'Uppity', permissions: 0n, position: 5,
  })).rejects.toMatchObject({ code: 'FORBIDDEN' });

  const high = await createRole(ctx.db, comm.id, owner, {
    name: 'High', permissions: 0n, position: 9,
  });
  await expect(updateRole(ctx.db, high.id, mod, { name: 'Pwned' }))
    .rejects.toMatchObject({ code: 'FORBIDDEN' });
  await expect(deleteRole(ctx.db, high.id, mod)).rejects.toMatchObject({ code: 'FORBIDDEN' });
  await expect(assignRole(ctx.db, comm.id, mod, pleb, high.id))
    .rejects.toMatchObject({ code: 'FORBIDDEN' });
});

it('@everyone only allows permission edits; no delete, rename or assign', async () => {
  const updated = await updateRole(ctx.db, everyoneId, owner, {
    permissions: DEFAULT_EVERYONE & ~PERM.SEND_MESSAGES,
  });
  expect(can(BigInt(updated.permissions.toString()), PERM.SEND_MESSAGES)).toBe(false);
  await expect(updateRole(ctx.db, everyoneId, owner, { name: 'todos' }))
    .rejects.toMatchObject({ code: 'VALIDATION' });
  await expect(deleteRole(ctx.db, everyoneId, owner)).rejects.toMatchObject({ code: 'VALIDATION' });
  await expect(assignRole(ctx.db, comm.id, owner, pleb, everyoneId))
    .rejects.toMatchObject({ code: 'VALIDATION' });
  // restaurar para el resto de tests
  await updateRole(ctx.db, everyoneId, owner, { permissions: DEFAULT_EVERYONE });
});

it('channel override: deny beats base; allow rescues a specific role', async () => {
  const channelId = comm.channels[0].id;
  // denegar SEND_MESSAGES a @everyone en #general
  await setOverride(ctx.db, channelId, everyoneId, owner, 0n, PERM.SEND_MESSAGES);
  const plebPerms = (await memberPerms(ctx.db, comm.id, pleb, channelId))!;
  expect(can(plebPerms.perms, PERM.SEND_MESSAGES)).toBe(false);

  // rol Vocero con allow en ese canal
  const vocero = await createRole(ctx.db, comm.id, owner, {
    name: 'Vocero', permissions: 0n, position: 2,
  });
  await setOverride(ctx.db, channelId, vocero.id, owner, PERM.SEND_MESSAGES, 0n);
  await assignRole(ctx.db, comm.id, owner, pleb, vocero.id);
  const rescued = (await memberPerms(ctx.db, comm.id, pleb, channelId))!;
  // deny de @everyone y allow de Vocero: deny gana según nuestra regla
  expect(can(rescued.perms, PERM.SEND_MESSAGES)).toBe(false);

  // quitando el deny de @everyone, el allow actúa
  await setOverride(ctx.db, channelId, everyoneId, owner, 0n, 0n);
  const now = (await memberPerms(ctx.db, comm.id, pleb, channelId))!;
  expect(can(now.perms, PERM.SEND_MESSAGES)).toBe(true);
  await unassignRole(ctx.db, comm.id, owner, pleb, vocero.id);
});

it('setOverride cannot grant bits the actor lacks and validates the role community', async () => {
  const other = await createCommunity(ctx.db, owner, 'Other');
  await expect(setOverride(ctx.db, comm.channels[0].id, other.roles[0].id, owner, 0n, 0n))
    .rejects.toMatchObject({ code: 'VALIDATION' });
  await expect(setOverride(ctx.db, comm.channels[0].id, everyoneId, mod, PERM.ADMIN, 0n))
    .rejects.toMatchObject({ code: 'FORBIDDEN' });
});
