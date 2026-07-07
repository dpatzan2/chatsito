import { ulid } from 'ulid';
import { and, desc, eq, inArray, isNull, lt } from 'drizzle-orm';
import {
  channelOverrides, channels, communities, communityMembers, memberRoles, messages, roles,
} from '../db/schema.js';
import { AppError } from '../core/errors.js';
import { computePermissions, PERM, can } from '../core/permissions.js';
import { requirePerm } from './service.js';
import type { Db } from '../db/client.js';

type Message = typeof messages.$inferSelect;
type MessageType = Message['type'];

const MAX_PAGE = 100;

async function getChannel(db: Db, channelId: string) {
  const [channel] = await db.select().from(channels).where(eq(channels.id, channelId));
  if (!channel) throw new AppError('NOT_FOUND', 'Channel not found');
  return channel;
}

export async function sendChannelMessage(
  db: Db,
  input: { channelId: string; authorId: string; type: MessageType; content: Record<string, unknown> },
): Promise<Message> {
  const channel = await getChannel(db, input.channelId);
  await requirePerm(db, {
    communityId: channel.communityId, userId: input.authorId,
    perm: PERM.VIEW_CHANNEL | PERM.SEND_MESSAGES, channelId: channel.id,
  });
  const [msg] = await db.insert(messages).values({ id: ulid(), ...input }).returning();
  return msg;
}

export async function getChannelMessages(
  db: Db, channelId: string, userId: string, opts: { before?: string; limit?: number },
): Promise<Message[]> {
  const channel = await getChannel(db, channelId);
  await requirePerm(db, {
    communityId: channel.communityId, userId, perm: PERM.VIEW_CHANNEL, channelId,
  });
  const limit = Math.min(opts.limit ?? 50, MAX_PAGE);
  return db.select().from(messages)
    .where(and(
      eq(messages.channelId, channelId),
      isNull(messages.deletedAt),
      ...(opts.before ? [lt(messages.id, opts.before)] : []),
    ))
    .orderBy(desc(messages.id))
    .limit(limit);
}

export async function channelRecipients(
  db: Db, channelId: string,
): Promise<{ channel: typeof channels.$inferSelect; userIds: string[] }> {
  const channel = await getChannel(db, channelId);
  const [community] = await db.select().from(communities)
    .where(eq(communities.id, channel.communityId));
  const members = await db.select().from(communityMembers)
    .where(eq(communityMembers.communityId, channel.communityId));
  const allRoles = await db.select().from(roles)
    .where(eq(roles.communityId, channel.communityId));
  const everyone = allRoles.find((r) => r.isEveryone)!;
  const assignments = allRoles.length
    ? await db.select().from(memberRoles)
        .where(inArray(memberRoles.roleId, allRoles.map((r) => r.id)))
    : [];
  const overrides = await db.select().from(channelOverrides)
    .where(eq(channelOverrides.channelId, channelId));

  const rolesByUser = new Map<string, string[]>();
  for (const a of assignments) {
    rolesByUser.set(a.userId, [...(rolesByUser.get(a.userId) ?? []), a.roleId]);
  }

  // ponytail: escaneo de permisos por mensaje; cachear por canal si hay cientos de miembros
  const userIds = members.filter((m) => {
    const myIds = new Set([everyone.id, ...(rolesByUser.get(m.userId) ?? [])]);
    const perms = computePermissions({
      isOwner: community.ownerId === m.userId,
      rolePerms: allRoles.filter((r) => myIds.has(r.id)).map((r) => r.permissions),
      overrides: overrides.filter((o) => myIds.has(o.roleId)),
    });
    return can(perms, PERM.VIEW_CHANNEL);
  }).map((m) => m.userId);

  return { channel, userIds };
}
