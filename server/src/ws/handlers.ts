import { z } from 'zod';
import { and, asc, eq, gt, isNull } from 'drizzle-orm';
import type { WebSocket } from 'ws';
import { assertMember, deleteMessage, markRead, sendMessage } from '../chat/service.js';
import { sendChannelMessage, channelRecipients } from '../community/channel-messages.js';
import { requirePerm } from '../community/service.js';
import { channels, conversations, messages } from '../db/schema.js';
import { AppError } from '../core/errors.js';
import { PERM } from '../core/permissions.js';
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
    if (input.channelId) {
      const msg = await sendChannelMessage(ctx.deps.db, {
        channelId: input.channelId, authorId: ctx.userId, type: input.type, content: input.content,
      });
      ack(ctx.socket, ctx.seq, { id: msg.id });
      const { userIds } = await channelRecipients(ctx.deps.db, input.channelId);
      ctx.hub.sendTo(userIds, 'msg.new', wireMessage(msg));
      return;
    }
    const { msg, conv } = await sendMessage(ctx.deps.db, {
      conversationId: input.conversationId!, authorId: ctx.userId,
      type: input.type, content: input.content,
    });
    ack(ctx.socket, ctx.seq, { id: msg.id });
    ctx.hub.sendTo([conv.userA, conv.userB], 'msg.new', wireMessage(msg));
  },

  'msg.delete': async (ctx, d) => {
    const { id } = z.object({ id: z.string().min(1) }).parse(d);
    const msg = await deleteMessage(ctx.deps.db, id, ctx.userId);
    ack(ctx.socket, ctx.seq);
    if (msg.channelId) {
      const { userIds } = await channelRecipients(ctx.deps.db, msg.channelId);
      ctx.hub.sendTo(userIds, 'msg.deleted', { id: msg.id, channelId: msg.channelId });
    } else {
      const [conv] = await ctx.deps.db.select().from(conversations)
        .where(eq(conversations.id, msg.conversationId!));
      ctx.hub.sendTo([conv.userA, conv.userB], 'msg.deleted', {
        id: msg.id, conversationId: msg.conversationId,
      });
    }
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
      targets: z.array(
        z.object({
          conversationId: z.uuid().optional(),
          channelId: z.uuid().optional(),
          lastMsgId: z.string().min(1),
        }).refine((t) => !t.conversationId !== !t.channelId, 'exactly one target'),
      ).max(100),
    }).parse(d);
    const out = [];
    for (const t of targets) {
      let targetCol;
      if (t.channelId) {
        const [channel] = await ctx.deps.db.select().from(channels)
          .where(eq(channels.id, t.channelId));
        if (!channel) throw new AppError('NOT_FOUND', 'Channel not found');
        await requirePerm(ctx.deps.db, {
          communityId: channel.communityId, userId: ctx.userId,
          perm: PERM.VIEW_CHANNEL, channelId: t.channelId,
        });
        targetCol = eq(messages.channelId, t.channelId);
      } else {
        await assertMember(ctx.deps.db, t.conversationId!, ctx.userId);
        targetCol = eq(messages.conversationId, t.conversationId!);
      }
      const rows = await ctx.deps.db.select().from(messages)
        .where(and(targetCol, gt(messages.id, t.lastMsgId), isNull(messages.deletedAt)))
        .orderBy(asc(messages.id))
        .limit(500); // ponytail: si faltan >500, el cliente repagina con historial REST
      out.push({
        ...(t.channelId ? { channelId: t.channelId } : { conversationId: t.conversationId }),
        messages: rows.map(wireMessage),
      });
    }
    ack(ctx.socket, ctx.seq);
    ctx.socket.send(serverFrame('sys.resumed', { targets: out }));
  },
};
