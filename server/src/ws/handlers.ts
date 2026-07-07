import type { WebSocket } from 'ws';
import { sendMessage } from '../chat/service.js';
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
};
