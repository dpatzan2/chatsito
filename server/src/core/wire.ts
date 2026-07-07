import type { messages, users } from '../db/schema.js';

export const publicUser = (u: typeof users.$inferSelect) => ({
  id: u.id,
  phone: u.phone,
  displayName: u.displayName,
  avatarColor: u.avatarColor,
});

export const wireMessage = (m: typeof messages.$inferSelect) => ({
  id: m.id,
  conversationId: m.conversationId,
  authorId: m.authorId,
  type: m.type,
  content: m.content,
  createdAt: m.createdAt.getTime(),
});
