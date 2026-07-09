import { randomBytes } from 'node:crypto';
import { and, asc, eq, gt, inArray, isNull, ne, sql } from 'drizzle-orm';
import {
  channelOverrides, channelReadStates, channels, communities, communityMembers,
  invites, memberRoles, messages, roles, users,
} from '../db/schema.js';
import { AppError } from '../core/errors.js';
import { computePermissions, DEFAULT_EVERYONE, PERM, can } from '../core/permissions.js';
import { publicUser, wireChannel, wireCommunity, wireRole } from '../core/wire.js';
import type { Db } from '../db/client.js';

export interface MemberPerms {
  perms: bigint;
  highest: number;
  isOwner: boolean;
}

const INVITE_TTL_MS = 7 * 86_400_000;

export async function memberPerms(
  db: Db, communityId: string, userId: string, channelId?: string,
): Promise<MemberPerms | null> {
  const [community] = await db.select().from(communities).where(eq(communities.id, communityId));
  if (!community) return null;
  const [membership] = await db.select().from(communityMembers)
    .where(and(eq(communityMembers.communityId, communityId), eq(communityMembers.userId, userId)));
  if (!membership) return null;

  const isOwner = community.ownerId === userId;
  const allRoles = await db.select().from(roles).where(eq(roles.communityId, communityId));
  const everyone = allRoles.find((r) => r.isEveryone)!;
  const mine = await db.select().from(memberRoles).where(and(
    inArray(memberRoles.roleId, allRoles.map((r) => r.id)),
    eq(memberRoles.userId, userId),
  ));
  const myRoleIds = new Set([everyone.id, ...mine.map((m) => m.roleId)]);
  const myRoles = allRoles.filter((r) => myRoleIds.has(r.id));

  let overrides: Array<{ allow: bigint; deny: bigint }> | undefined;
  if (channelId) {
    overrides = await db.select().from(channelOverrides).where(and(
      eq(channelOverrides.channelId, channelId),
      inArray(channelOverrides.roleId, [...myRoleIds]),
    ));
  }

  return {
    perms: computePermissions({ isOwner, rolePerms: myRoles.map((r) => r.permissions), overrides }),
    highest: isOwner ? Number.MAX_SAFE_INTEGER : Math.max(...myRoles.map((r) => r.position)),
    isOwner,
  };
}

export async function requireMember(db: Db, communityId: string, userId: string): Promise<MemberPerms> {
  const mp = await memberPerms(db, communityId, userId);
  if (!mp) throw new AppError('NOT_FOUND', 'Community not found');
  return mp;
}

export async function requirePerm(
  db: Db,
  opts: { communityId: string; userId: string; perm: bigint; channelId?: string },
): Promise<MemberPerms> {
  const [mp, mpChannel] = [
    await requireMember(db, opts.communityId, opts.userId),
    opts.channelId ? await memberPerms(db, opts.communityId, opts.userId, opts.channelId) : null,
  ];
  const effective = mpChannel ?? mp;
  if (!can(effective.perms, opts.perm)) {
    throw new AppError('FORBIDDEN', 'Missing permission');
  }
  return effective;
}

export async function createCommunity(db: Db, ownerId: string, name: string) {
  const [community] = await db.insert(communities).values({ name, ownerId }).returning();
  await db.insert(roles).values({
    communityId: community.id, name: '@everyone', position: 0,
    permissions: DEFAULT_EVERYONE, isEveryone: true,
  });
  await db.insert(communityMembers).values({ communityId: community.id, userId: ownerId });
  await db.insert(channels).values({ communityId: community.id, name: 'general', type: 'text' });
  return getCommunity(db, community.id, ownerId);
}

// ponytail: un count por canal de texto; pasar a un solo GROUP BY si las comunidades crecen
export async function channelUnreads(
  db: Db, communityId: string, userId: string,
): Promise<Map<string, number>> {
  const chans = await db.select().from(channels).where(eq(channels.communityId, communityId));
  const out = new Map<string, number>();
  for (const ch of chans) {
    if (ch.type !== 'text') continue;
    const [rs] = await db.select().from(channelReadStates)
      .where(and(eq(channelReadStates.userId, userId), eq(channelReadStates.channelId, ch.id)));
    const [{ count }] = await db.select({ count: sql<number>`count(*)::int` }).from(messages)
      .where(and(
        eq(messages.channelId, ch.id), isNull(messages.deletedAt), ne(messages.authorId, userId),
        ...(rs ? [gt(messages.id, rs.lastReadMessageId)] : []),
      ));
    out.set(ch.id, count);
  }
  return out;
}

export async function getCommunity(db: Db, communityId: string, userId: string) {
  await requireMember(db, communityId, userId);
  const [community] = await db.select().from(communities).where(eq(communities.id, communityId));
  const unreads = await channelUnreads(db, communityId, userId);
  const chans = await db.select().from(channels)
    .where(eq(channels.communityId, communityId)).orderBy(asc(channels.position), asc(channels.createdAt));
  const rls = await db.select().from(roles)
    .where(eq(roles.communityId, communityId)).orderBy(asc(roles.position));
  const membs = await db.select({ user: users, joinedAt: communityMembers.joinedAt })
    .from(communityMembers)
    .innerJoin(users, eq(users.id, communityMembers.userId))
    .where(eq(communityMembers.communityId, communityId));
  const assignments = rls.length
    ? await db.select().from(memberRoles).where(inArray(memberRoles.roleId, rls.map((r) => r.id)))
    : [];
  const rolesByUser = new Map<string, string[]>();
  for (const a of assignments) {
    rolesByUser.set(a.userId, [...(rolesByUser.get(a.userId) ?? []), a.roleId]);
  }
  return {
    ...wireCommunity(community),
    channels: chans.map((ch) => ({ ...wireChannel(ch), unread: unreads.get(ch.id) ?? 0 })),
    roles: rls.map(wireRole),
    members: membs.map((m) => ({ ...publicUser(m.user), roleIds: rolesByUser.get(m.user.id) ?? [] })),
  };
}

export async function communityMemberIds(db: Db, communityId: string): Promise<string[]> {
  const rows = await db.select({ userId: communityMembers.userId }).from(communityMembers)
    .where(eq(communityMembers.communityId, communityId));
  return rows.map((r) => r.userId);
}

export async function createInvite(db: Db, communityId: string, actorId: string) {
  await requirePerm(db, { communityId, userId: actorId, perm: PERM.MANAGE_INVITES });
  const code = randomBytes(6).toString('base64url').slice(0, 8);
  const [invite] = await db.insert(invites).values({
    code, communityId, createdBy: actorId, expiresAt: new Date(Date.now() + INVITE_TTL_MS),
  }).returning();
  return invite;
}

export async function joinByInvite(db: Db, code: string, userId: string) {
  const [invite] = await db.select().from(invites).where(eq(invites.code, code));
  if (!invite || invite.expiresAt < new Date()) {
    throw new AppError('NOT_FOUND', 'Invite not found or expired');
  }
  await db.insert(communityMembers)
    .values({ communityId: invite.communityId, userId })
    .onConflictDoNothing();
  await db.update(invites).set({ uses: invite.uses + 1 }).where(eq(invites.code, code));
  const [community] = await db.select().from(communities)
    .where(eq(communities.id, invite.communityId));
  return community;
}

export async function removeMember(db: Db, communityId: string, actorId: string, targetId: string) {
  const [community] = await db.select().from(communities).where(eq(communities.id, communityId));
  if (!community) throw new AppError('NOT_FOUND', 'Community not found');
  if (targetId === community.ownerId) {
    throw new AppError('VALIDATION', 'The owner cannot leave or be kicked');
  }
  const target = await memberPerms(db, communityId, targetId);
  if (!target) throw new AppError('NOT_FOUND', 'Member not found');
  if (actorId !== targetId) {
    const actor = await requirePerm(db, { communityId, userId: actorId, perm: PERM.KICK_MEMBERS });
    if (target.highest >= actor.highest) {
      throw new AppError('FORBIDDEN', 'Cannot kick a member with an equal or higher role');
    }
  }
  const communityRoleIds = db.select({ id: roles.id }).from(roles)
    .where(eq(roles.communityId, communityId));
  await db.delete(memberRoles).where(and(
    eq(memberRoles.userId, targetId),
    inArray(memberRoles.roleId, communityRoleIds),
  ));
  await db.delete(communityMembers).where(and(
    eq(communityMembers.communityId, communityId),
    eq(communityMembers.userId, targetId),
  ));
}
