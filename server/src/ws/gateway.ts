import websocket from '@fastify/websocket';
import { ZodError } from 'zod';
import type { FastifyInstance } from 'fastify';
import { AppError, type ErrorCode } from '../core/errors.js';
import { ClientFrame, serverFrame } from './protocol.js';
import { handlers, type HandlerCtx } from './handlers.js';
import type { Hub } from './hub.js';
import type { Deps } from '../app.js';

export async function registerGateway(app: FastifyInstance, deps: Deps, hub: Hub): Promise<void> {
  await app.register(websocket);

  app.get('/ws', { websocket: true }, async (socket, req) => {
    const { token } = req.query as { token?: string };
    let userId: string;
    try {
      userId = await deps.tokens.verifyAccess(token ?? '');
    } catch {
      socket.close(4001, 'invalid token');
      return;
    }

    hub.add(userId, socket);
    socket.on('close', () => hub.remove(userId, socket));

    socket.on('message', async (raw) => {
      let seq: number | undefined;
      try {
        const frame = ClientFrame.parse(JSON.parse(String(raw)));
        seq = frame.seq;
        const handler = handlers[frame.op];
        if (!handler) throw new AppError('VALIDATION', `unknown op: ${frame.op}`);
        const ctx: HandlerCtx = { deps, hub, userId, seq, socket };
        await handler(ctx, frame.d);
      } catch (e) {
        let code: ErrorCode = 'INTERNAL';
        let message = 'internal error';
        if (e instanceof AppError) { code = e.code; message = e.message; }
        else if (e instanceof ZodError || e instanceof SyntaxError) {
          code = 'VALIDATION'; message = 'malformed frame';
        } else {
          req.log.error(e);
        }
        socket.send(serverFrame('sys.error', { seq, code, message }));
      }
    });
  });
}
