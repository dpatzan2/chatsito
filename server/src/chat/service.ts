import { ulid } from 'ulid';
import { and, desc, eq, gt, isNull, lt, ne, or, sql } from 'drizzle-orm';
import { channels, conversations, messages, readStates, users } from '../db/schema.js';
import { AppError } from '../core/errors.js';
import { PERM } from '../core/permissions.js';
import { publicUser } from '../core/wire.js';
import { requirePerm } from '../community/service.js';
import type { Db } from '../db/client.js';

type Conversation = typeof conversations.$inferSelect;
type Message = typeof messages.$inferSelect;
type MessageType = Message['type'];

const MAX_PAGE = 100;

export async function getOrCreateConversation(db: Db, meId: string, otherId: string): Promise<Conversation> {
  if (meId === otherId) throw new AppError('VALIDATION', 'Cannot start a conversation with yourself');
  const [other] = await db.select({ id: users.id }).from(users).where(eq(users.id, otherId));
  if (!other) throw new AppError('NOT_FOUND', 'User not found');
  const [a, b] = meId < otherId ? [meId, otherId] : [otherId, meId];
  const [created] = await db.insert(conversations).values({ userA: a, userB: b })
    .onConflictDoNothing().returning();
  if (created) return created;
  const [existing] = await db.select().from(conversations)
    .where(and(eq(conversations.userA, a), eq(conversations.userB, b)));
  return existing;
}

export async function assertMember(db: Db, conversationId: string, userId: string): Promise<Conversation> {
  const [conv] = await db.select().from(conversations).where(eq(conversations.id, conversationId));
  if (!conv || (conv.userA !== userId && conv.userB !== userId)) {
    throw new AppError('NOT_FOUND', 'Conversation not found');
  }
  return conv;
}

export async function sendMessage(
  db: Db,
  input: { conversationId: string; authorId: string; type: MessageType; content: Record<string, unknown> },
): Promise<{ msg: Message; conv: Conversation }> {
  const conv = await assertMember(db, input.conversationId, input.authorId);
  const [msg] = await db.insert(messages).values({ id: ulid(), ...input }).returning();
  return { msg, conv };
}

export async function getMessages(
  db: Db, conversationId: string, userId: string,
  opts: { before?: string; limit?: number },
): Promise<Message[]> {
  await assertMember(db, conversationId, userId);
  const limit = Math.min(opts.limit ?? 50, MAX_PAGE);
  return db.select().from(messages)
    .where(and(
      eq(messages.conversationId, conversationId),
      isNull(messages.deletedAt),
      ...(opts.before ? [lt(messages.id, opts.before)] : []),
    ))
    .orderBy(desc(messages.id))
    .limit(limit);
}

export async function deleteMessage(db: Db, messageId: string, userId: string): Promise<Message> {
  const [existing] = await db.select().from(messages)
    .where(and(eq(messages.id, messageId), isNull(messages.deletedAt)));
  if (!existing) throw new AppError('NOT_FOUND', 'Message not found');
  if (existing.authorId !== userId) {
    if (!existing.channelId) throw new AppError('NOT_FOUND', 'Message not found');
    const [channel] = await db.select().from(channels).where(eq(channels.id, existing.channelId));
    await requirePerm(db, {
      communityId: channel.communityId, userId,
      perm: PERM.MANAGE_MESSAGES, channelId: existing.channelId,
    });
  }
  const [msg] = await db.update(messages).set({ deletedAt: new Date() })
    .where(eq(messages.id, messageId)).returning();
  return msg;
}

export async function markRead(db: Db, userId: string, conversationId: string, messageId: string): Promise<void> {
  await assertMember(db, conversationId, userId);
  await db.insert(readStates).values({ userId, conversationId, lastReadMessageId: messageId })
    .onConflictDoUpdate({
      target: [readStates.userId, readStates.conversationId],
      set: { lastReadMessageId: messageId },
    });
}

export async function listConversations(db: Db, userId: string) {
  const convs = await db.select().from(conversations)
    .where(or(eq(conversations.userA, userId), eq(conversations.userB, userId)));
  // ponytail: N+1 por conversación; lateral join si las listas crecen de decenas
  return Promise.all(convs.map(async (c) => {
    const otherId = c.userA === userId ? c.userB : c.userA;
    const [other] = await db.select().from(users).where(eq(users.id, otherId));
    const [last] = await db.select().from(messages)
      .where(and(eq(messages.conversationId, c.id), isNull(messages.deletedAt)))
      .orderBy(desc(messages.id)).limit(1);
    const [rs] = await db.select().from(readStates)
      .where(and(eq(readStates.userId, userId), eq(readStates.conversationId, c.id)));
    const unreadWhere = [
      eq(messages.conversationId, c.id),
      isNull(messages.deletedAt),
      ne(messages.authorId, userId),
      ...(rs ? [gt(messages.id, rs.lastReadMessageId)] : []),
    ];
    const [{ count }] = await db.select({ count: sql<number>`count(*)::int` })
      .from(messages).where(and(...unreadWhere));
    return { id: c.id, other: publicUser(other), lastMessage: last ?? null, unread: count };
  }));
}
