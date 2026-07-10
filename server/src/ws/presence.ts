import { eq, inArray, or } from 'drizzle-orm';
import { communityMembers, conversations } from '../db/schema.js';
import type { Db } from '../db/client.js';

/** Usuarios que comparten una conversación 1:1 o una comunidad con [userId]. */
export async function presencePeers(db: Db, userId: string): Promise<string[]> {
  const convs = await db.select().from(conversations)
    .where(or(eq(conversations.userA, userId), eq(conversations.userB, userId)));
  const partners = convs.map((c) => (c.userA === userId ? c.userB : c.userA));
  const mine = await db.select({ id: communityMembers.communityId }).from(communityMembers)
    .where(eq(communityMembers.userId, userId));
  const co = mine.length
    ? await db.select({ userId: communityMembers.userId }).from(communityMembers)
        .where(inArray(communityMembers.communityId, mine.map((m) => m.id)))
    : [];
  return [...new Set([...partners, ...co.map((r) => r.userId)])].filter((id) => id !== userId);
}
