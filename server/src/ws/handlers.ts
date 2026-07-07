import { z } from 'zod';
import { and, asc, eq, gt, isNull } from 'drizzle-orm';
import type { WebSocket } from 'ws';
import { assertMember, deleteMessage, markRead, sendMessage } from '../chat/service.js';
import { conversations, messages } from '../db/schema.js';
import { wireMessage } from '../core/wire.js';
import { serverFrame, MsgSendInput } from './protocol.js';
import type { Hub } from './hub.js';
import type { Deps } from '../app.js';

export interface HandlerCtx {
  deps: Deps;
  hub: Hub;
  userId: string;
  seq: number;
  socket: WebSocket;
}

export const ack = (socket: WebSocket, seq: number, extra: Record<string, unknown> = {}): void => {
  socket.send(serverFrame('sys.ack', { seq, ...extra }));
};

type Handler = (ctx: HandlerCtx, d: unknown) => Promise<void>;

export const handlers: Record<string, Handler> = {
  'sys.ping': async (ctx) => ack(ctx.socket, ctx.seq),

  'msg.send': async (ctx, d) => {
    const input = MsgSendInput.parse(d);
    const { msg, conv } = await sendMessage(ctx.deps.db, { ...input, authorId: ctx.userId });
    ack(ctx.socket, ctx.seq, { id: msg.id });
    ctx.hub.sendTo([conv.userA, conv.userB], 'msg.new', wireMessage(msg));
  },

  'msg.delete': async (ctx, d) => {
    const { id } = z.object({ id: z.string().min(1) }).parse(d);
    const msg = await deleteMessage(ctx.deps.db, id, ctx.userId);
    ack(ctx.socket, ctx.seq);
    const [conv] = await ctx.deps.db.select().from(conversations)
      .where(eq(conversations.id, msg.conversationId));
    ctx.hub.sendTo([conv.userA, conv.userB], 'msg.deleted', {
      id: msg.id, conversationId: msg.conversationId,
    });
  },

  'typing.start': async (ctx, d) => {
    const { conversationId } = z.object({ conversationId: z.uuid() }).parse(d);
    const conv = await assertMember(ctx.deps.db, conversationId, ctx.userId);
    ack(ctx.socket, ctx.seq);
    const other = conv.userA === ctx.userId ? conv.userB : conv.userA;
    ctx.hub.sendTo([other], 'typing', { conversationId, userId: ctx.userId });
  },

  'read.mark': async (ctx, d) => {
    const { conversationId, messageId } = z.object({
      conversationId: z.uuid(), messageId: z.string().min(1),
    }).parse(d);
    await markRead(ctx.deps.db, ctx.userId, conversationId, messageId);
    ack(ctx.socket, ctx.seq);
  },

  'sys.resume': async (ctx, d) => {
    const { targets } = z.object({
      targets: z.array(z.object({
        conversationId: z.uuid(),
        lastMsgId: z.string().min(1),
      })).max(100),
    }).parse(d);
    const out = [];
    for (const t of targets) {
      await assertMember(ctx.deps.db, t.conversationId, ctx.userId);
      const rows = await ctx.deps.db.select().from(messages)
        .where(and(
          eq(messages.conversationId, t.conversationId),
          gt(messages.id, t.lastMsgId),
          isNull(messages.deletedAt),
        ))
        .orderBy(asc(messages.id))
        .limit(500); // ponytail: si faltan >500, el cliente repagina con historial REST
      out.push({ conversationId: t.conversationId, messages: rows.map(wireMessage) });
    }
    ack(ctx.socket, ctx.seq);
    ctx.socket.send(serverFrame('sys.resumed', { targets: out }));
  },
};
