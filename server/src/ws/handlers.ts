import { z } from 'zod';
import { and, asc, eq, gt, isNull } from 'drizzle-orm';
import type { WebSocket } from 'ws';
import { assertMember, deleteMessage, markRead, sendMessage } from '../chat/service.js';
import { markChannelRead, sendChannelMessage, channelRecipients } from '../community/channel-messages.js';
import { memberPerms, requirePerm } from '../community/service.js';
import { channels, conversations, messages } from '../db/schema.js';
import { AppError } from '../core/errors.js';
import { PERM, can } from '../core/permissions.js';
import { wireMessage } from '../core/wire.js';
import { DEV_LIVEKIT, roomApi, signVoiceToken } from '../voice/livekit.js';
import type { VoiceStates } from '../voice/state.js';
import { serverFrame, MsgSendInput } from './protocol.js';
import type { Hub } from './hub.js';
import type { Deps } from '../app.js';

export interface HandlerCtx {
  deps: Deps;
  hub: Hub;
  voice: VoiceStates;
  userId: string;
  seq: number;
  socket: WebSocket;
}

export const ack = (socket: WebSocket, seq: number, extra: Record<string, unknown> = {}): void => {
  socket.send(serverFrame('sys.ack', { seq, ...extra }));
};

const lkOf = (deps: Deps) => deps.lk ?? DEV_LIVEKIT;
const lkApiOf = (deps: Deps) => deps.lkApi ?? roomApi(lkOf(deps));

async function getVoiceChannel(db: Deps['db'], channelId: string) {
  const [channel] = await db.select().from(channels).where(eq(channels.id, channelId));
  if (!channel) throw new AppError('NOT_FOUND', 'Channel not found');
  if (channel.type !== 'voice') throw new AppError('VALIDATION', 'Not a voice channel');
  return channel;
}

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
    const input = z.object({
      conversationId: z.uuid().optional(),
      channelId: z.uuid().optional(),
      messageId: z.string().min(1),
    }).refine((t) => !t.conversationId !== !t.channelId, 'exactly one target').parse(d);
    if (input.channelId) {
      await markChannelRead(ctx.deps.db, ctx.userId, input.channelId, input.messageId);
    } else {
      await markRead(ctx.deps.db, ctx.userId, input.conversationId!, input.messageId);
    }
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

  'voice.join': async (ctx, d) => {
    const { channelId } = z.object({ channelId: z.uuid() }).parse(d);
    const channel = await getVoiceChannel(ctx.deps.db, channelId);
    const mp = await requirePerm(ctx.deps.db, {
      communityId: channel.communityId, userId: ctx.userId,
      perm: PERM.VOICE_CONNECT, channelId,
    });
    const lk = lkOf(ctx.deps);
    const token = await signVoiceToken(lk, {
      identity: ctx.userId, room: channelId, canPublish: can(mp.perms, PERM.VOICE_SPEAK),
    });
    ack(ctx.socket, ctx.seq);
    ctx.socket.send(serverFrame('voice.ready', {
      channelId, token, url: lk.url, members: ctx.voice.members(channelId),
    }));
    // la presencia real la confirma el webhook participant_joined → voice.state
  },

  'voice.leave': async (ctx, d) => {
    const { channelId } = z.object({ channelId: z.uuid() }).parse(d);
    ack(ctx.socket, ctx.seq);
    // best-effort: si el cliente ya se desconectó del SFU, LiveKit devuelve 404 y da igual;
    // el webhook participant_left es quien actualiza el estado
    await lkApiOf(ctx.deps).removeParticipant(channelId, ctx.userId).catch(() => {});
  },

  'voice.mute': async (ctx, d) => {
    const { channelId, userId, muted } = z.object({
      channelId: z.uuid(), userId: z.uuid(), muted: z.boolean(),
    }).parse(d);
    const channel = await getVoiceChannel(ctx.deps.db, channelId);
    await requirePerm(ctx.deps.db, {
      communityId: channel.communityId, userId: ctx.userId,
      perm: PERM.VOICE_MUTE_MEMBERS, channelId,
    });
    const target = await memberPerms(ctx.deps.db, channel.communityId, userId, channelId);
    if (!target) throw new AppError('NOT_FOUND', 'Member not found');
    // unmute solo restaura publish si el target tiene VOICE_SPEAK efectivo
    const canPublish = !muted && can(target.perms, PERM.VOICE_SPEAK);
    await lkApiOf(ctx.deps).updateParticipant(channelId, userId, canPublish);
    ctx.voice.setMuted(channelId, userId, muted);
    ack(ctx.socket, ctx.seq);
    const { userIds } = await channelRecipients(ctx.deps.db, channelId);
    ctx.hub.sendTo(userIds, 'voice.state', {
      channelId, members: ctx.voice.members(channelId),
    });
  },
};
