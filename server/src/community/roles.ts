import { and, eq } from 'drizzle-orm';
import { channelOverrides, channels, communityMembers, memberRoles, roles } from '../db/schema.js';
import { AppError } from '../core/errors.js';
import { PERM } from '../core/permissions.js';
import { requirePerm, type MemberPerms } from './service.js';
import type { Db } from '../db/client.js';

function ensureSubset(granted: bigint, actor: MemberPerms): void {
  if ((granted & ~actor.perms) !== 0n) {
    throw new AppError('FORBIDDEN', 'Cannot grant permissions you do not have');
  }
}

function ensureAbove(actor: MemberPerms, position: number): void {
  if (position >= actor.highest) {
    throw new AppError('FORBIDDEN', 'Role position is at or above your highest role');
  }
}

async function getRole(db: Db, roleId: string) {
  const [role] = await db.select().from(roles).where(eq(roles.id, roleId));
  if (!role) throw new AppError('NOT_FOUND', 'Role not found');
  return role;
}

export async function createRole(
  db: Db, communityId: string, actorId: string,
  input: { name: string; color?: string; permissions: bigint; position?: number },
) {
  const actor = await requirePerm(db, { communityId, userId: actorId, perm: PERM.MANAGE_ROLES });
  ensureSubset(input.permissions, actor);
  const position = input.position ?? 1;
  ensureAbove(actor, position);
  const [role] = await db.insert(roles).values({
    communityId, name: input.name, color: input.color, permissions: input.permissions, position,
  }).returning();
  return role;
}

export async function updateRole(
  db: Db, roleId: string, actorId: string,
  patch: { name?: string; color?: string; permissions?: bigint; position?: number },
) {
  const role = await getRole(db, roleId);
  const actor = await requirePerm(db, {
    communityId: role.communityId, userId: actorId, perm: PERM.MANAGE_ROLES,
  });
  ensureAbove(actor, role.position);
  if (role.isEveryone &&
      (patch.name !== undefined || patch.color !== undefined || patch.position !== undefined)) {
    throw new AppError('VALIDATION', '@everyone only allows permission changes');
  }
  if (patch.permissions !== undefined) ensureSubset(patch.permissions, actor);
  if (patch.position !== undefined) ensureAbove(actor, patch.position);
  const [updated] = await db.update(roles).set(patch).where(eq(roles.id, roleId)).returning();
  return updated;
}

export async function deleteRole(db: Db, roleId: string, actorId: string): Promise<void> {
  const role = await getRole(db, roleId);
  if (role.isEveryone) throw new AppError('VALIDATION', '@everyone cannot be deleted');
  const actor = await requirePerm(db, {
    communityId: role.communityId, userId: actorId, perm: PERM.MANAGE_ROLES,
  });
  ensureAbove(actor, role.position);
  await db.delete(roles).where(eq(roles.id, roleId));
}

async function assignmentChecks(
  db: Db, communityId: string, actorId: string, targetUserId: string, roleId: string,
) {
  const role = await getRole(db, roleId);
  if (role.communityId !== communityId) throw new AppError('NOT_FOUND', 'Role not found');
  if (role.isEveryone) throw new AppError('VALIDATION', '@everyone cannot be assigned');
  const actor = await requirePerm(db, { communityId, userId: actorId, perm: PERM.MANAGE_ROLES });
  ensureAbove(actor, role.position);
  const [membership] = await db.select().from(communityMembers).where(and(
    eq(communityMembers.communityId, communityId),
    eq(communityMembers.userId, targetUserId),
  ));
  if (!membership) throw new AppError('NOT_FOUND', 'Member not found');
  return role;
}

export async function assignRole(
  db: Db, communityId: string, actorId: string, targetUserId: string, roleId: string,
): Promise<void> {
  await assignmentChecks(db, communityId, actorId, targetUserId, roleId);
  await db.insert(memberRoles).values({ roleId, userId: targetUserId }).onConflictDoNothing();
}

export async function unassignRole(
  db: Db, communityId: string, actorId: string, targetUserId: string, roleId: string,
): Promise<void> {
  await assignmentChecks(db, communityId, actorId, targetUserId, roleId);
  await db.delete(memberRoles).where(and(
    eq(memberRoles.roleId, roleId), eq(memberRoles.userId, targetUserId),
  ));
}

export async function setOverride(
  db: Db, channelId: string, roleId: string, actorId: string, allow: bigint, deny: bigint,
) {
  const [channel] = await db.select().from(channels).where(eq(channels.id, channelId));
  if (!channel) throw new AppError('NOT_FOUND', 'Channel not found');
  const role = await getRole(db, roleId);
  if (role.communityId !== channel.communityId) {
    throw new AppError('VALIDATION', 'Role belongs to another community');
  }
  const actor = await requirePerm(db, {
    communityId: channel.communityId, userId: actorId, perm: PERM.MANAGE_ROLES,
  });
  ensureSubset(allow | deny, actor);
  const [override] = await db.insert(channelOverrides)
    .values({ channelId, roleId, allow, deny })
    .onConflictDoUpdate({
      target: [channelOverrides.channelId, channelOverrides.roleId],
      set: { allow, deny },
    }).returning();
  return override;
}
