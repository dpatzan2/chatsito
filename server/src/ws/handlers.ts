import { z } from 'zod';
import { eq } from 'drizzle-orm';
import type { WebSocket } from 'ws';
import { assertMember, deleteMessage, markRead, sendMessage } from '../chat/service.js';
import { conversations } from '../db/schema.js';
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
};
