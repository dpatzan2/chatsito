import type { channels, communities, messages, roles, users } from '../db/schema.js';

export const publicUser = (u: typeof users.$inferSelect) => ({
  id: u.id,
  phone: u.phone,
  displayName: u.displayName,
  avatarColor: u.avatarColor,
  avatarUrl: u.avatarUrl,
});

export const wireMessage = (m: typeof messages.$inferSelect) => ({
  id: m.id,
  conversationId: m.conversationId,
  channelId: m.channelId,
  authorId: m.authorId,
  type: m.type,
  content: m.content,
  createdAt: m.createdAt.getTime(),
});

export const wireCommunity = (c: typeof communities.$inferSelect) => ({
  id: c.id, name: c.name, ownerId: c.ownerId, createdAt: c.createdAt.getTime(),
});

export const wireChannel = (ch: typeof channels.$inferSelect) => ({
  id: ch.id, communityId: ch.communityId, name: ch.name, type: ch.type, position: ch.position,
});

export const wireRole = (r: typeof roles.$inferSelect) => ({
  id: r.id, communityId: r.communityId, name: r.name, color: r.color,
  position: r.position, permissions: r.permissions.toString(), isEveryone: r.isEveryone,
});
