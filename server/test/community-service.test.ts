import { beforeAll, afterAll, it, expect } from 'vitest';
import { testDb } from './helpers/db.js';
import {
  createCommunity, getCommunity, memberPerms, requirePerm,
  createInvite, joinByInvite, removeMember, communityMemberIds,
} from '../src/community/service.js';
import { invites, memberRoles, roles, users } from '../src/db/schema.js';
import { PERM, ALL_PERMS, can } from '../src/core/permissions.js';
import { eq } from 'drizzle-orm';

let ctx: Awaited<ReturnType<typeof testDb>>;
let owner: string, member: string, outsider: string;

beforeAll(async () => {
  ctx = await testDb();
  const rows = await ctx.db.insert(users).values([
    { phone: '50211111111', displayName: 'Owner' },
    { phone: '50222222222', displayName: 'Member' },
    { phone: '50233333333', displayName: 'Outsider' },
  ]).returning();
  [owner, member, outsider] = rows.map((r) => r.id);
});
afterAll(() => ctx.stop());

it('createCommunity seeds @everyone, owner membership and #general', async () => {
  const c = await createCommunity(ctx.db, owner, 'Los Cuates');
  expect(c.name).toBe('Los Cuates');
  expect(c.roles).toHaveLength(1);
  expect(c.roles[0].isEveryone).toBe(true);
  expect(c.roles[0].position).toBe(0);
  expect(c.channels.map((ch) => ch.name)).toEqual(['general']);
  expect(c.members.map((m) => m.id)).toEqual([owner]);
});

it('owner has ALL perms; plain member has @everyone perms; outsider has none', async () => {
  const c = await createCommunity(ctx.db, owner, 'Perms');
  const inv = await createInvite(ctx.db, c.id, owner);
  await joinByInvite(ctx.db, inv.code, member);

  expect((await memberPerms(ctx.db, c.id, owner))!.perms).toBe(ALL_PERMS);
  const m = (await memberPerms(ctx.db, c.id, member))!;
  expect(can(m.perms, PERM.SEND_MESSAGES)).toBe(true);
  expect(can(m.perms, PERM.KICK_MEMBERS)).toBe(false);
  expect(await memberPerms(ctx.db, c.id, outsider)).toBeNull();
  await expect(requirePerm(ctx.db, { communityId: c.id, userId: member, perm: PERM.KICK_MEMBERS }))
    .rejects.toMatchObject({ code: 'FORBIDDEN' });
});

it('invites expire and unknown codes fail', async () => {
  const c = await createCommunity(ctx.db, owner, 'Inv');
  const inv = await createInvite(ctx.db, c.id, owner);
  await ctx.db.update(invites).set({ expiresAt: new Date(Date.now() - 1000) })
    .where(eq(invites.code, inv.code));
  await expect(joinByInvite(ctx.db, inv.code, member)).rejects.toMatchObject({ code: 'NOT_FOUND' });
  await expect(joinByInvite(ctx.db, 'NOPE1234', member)).rejects.toMatchObject({ code: 'NOT_FOUND' });
});

it('member can leave; owner cannot; kick requires perms and hierarchy', async () => {
  const c = await createCommunity(ctx.db, owner, 'Kick');
  const inv = await createInvite(ctx.db, c.id, owner);
  await joinByInvite(ctx.db, inv.code, member);
  await joinByInvite(ctx.db, inv.code, outsider);

  // member (sin KICK_MEMBERS) no puede expulsar
  await expect(removeMember(ctx.db, c.id, member, outsider))
    .rejects.toMatchObject({ code: 'FORBIDDEN' });
  // owner no puede salir ni ser expulsado
  await expect(removeMember(ctx.db, c.id, owner, owner))
    .rejects.toMatchObject({ code: 'VALIDATION' });
  // el owner expulsa a outsider; y member sale solo
  await removeMember(ctx.db, c.id, owner, outsider);
  await removeMember(ctx.db, c.id, member, member);
  expect(await communityMemberIds(ctx.db, c.id)).toEqual([owner]);
});

it('kick cleans up the member roles of that community', async () => {
  const c = await createCommunity(ctx.db, owner, 'Cleanup');
  const inv = await createInvite(ctx.db, c.id, owner);
  await joinByInvite(ctx.db, inv.code, member);
  const [role] = await ctx.db.insert(roles)
    .values({ communityId: c.id, name: 'Mod', position: 1, permissions: PERM.KICK_MEMBERS }).returning();
  await ctx.db.insert(memberRoles).values({ roleId: role.id, userId: member });
  await removeMember(ctx.db, c.id, owner, member);
  const left = await ctx.db.select().from(memberRoles).where(eq(memberRoles.userId, member));
  expect(left).toHaveLength(0);
});

it('getCommunity is NOT_FOUND for non-members', async () => {
  const c = await createCommunity(ctx.db, owner, 'Priv');
  await expect(getCommunity(ctx.db, c.id, outsider)).rejects.toMatchObject({ code: 'NOT_FOUND' });
});
