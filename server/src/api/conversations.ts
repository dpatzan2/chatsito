import { z } from 'zod';
import type { FastifyInstance } from 'fastify';
import { getOrCreateConversation, getMessages, listConversations } from '../chat/service.js';
import { publicUser, wireMessage } from '../core/wire.js';
import { users } from '../db/schema.js';
import { eq } from 'drizzle-orm';
import type { Deps } from '../app.js';

export function conversationRoutes(app: FastifyInstance, deps: Deps): void {
  app.get('/conversations', async (req) => {
    const list = await listConversations(deps.db, req.userId);
    return list.map((c) => ({ ...c, lastMessage: c.lastMessage ? wireMessage(c.lastMessage) : null }));
  });

  app.post('/conversations', async (req) => {
    const { userId } = z.object({ userId: z.uuid() }).parse(req.body);
    const conv = await getOrCreateConversation(deps.db, req.userId, userId);
    const otherId = conv.userA === req.userId ? conv.userB : conv.userA;
    const [other] = await deps.db.select().from(users).where(eq(users.id, otherId));
    return { id: conv.id, other: publicUser(other) };
  });

  app.get('/conversations/:id/messages', async (req) => {
    const { id } = z.object({ id: z.uuid() }).parse(req.params);
    const { before, limit } = z.object({
      before: z.string().optional(),
      limit: z.coerce.number().int().positive().optional(),
    }).parse(req.query);
    const rows = await getMessages(deps.db, id, req.userId, { before, limit });
    return { messages: rows.map(wireMessage) };
  });
}
