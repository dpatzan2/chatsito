import { z } from 'zod';
import type { FastifyInstance } from 'fastify';
import { requestOtp, verifyOtp } from '../auth/otp.js';
import type { Deps } from '../app.js';

const Phone = z.string().regex(/^\d{8,15}$/, 'digits only, 8-15 chars');

export function authRoutes(app: FastifyInstance, deps: Deps): void {
  app.post('/auth/otp', async (req, reply) => {
    const { phone } = z.object({ phone: Phone }).parse(req.body);
    await requestOtp(deps.db, deps.sms, phone);
    return reply.status(204).send();
  });

  app.post('/auth/verify', async (req) => {
    const { phone, code } = z
      .object({ phone: Phone, code: z.string().length(6) })
      .parse(req.body);
    const user = await verifyOtp(deps.db, phone, code);
    return {
      access: await deps.tokens.signAccess(user.id),
      refresh: await deps.tokens.createRefresh(user.id),
      user: {
        id: user.id,
        phone: user.phone,
        displayName: user.displayName,
        avatarColor: user.avatarColor,
      },
    };
  });

  app.post('/auth/refresh', async (req) => {
    const { refresh } = z.object({ refresh: z.string() }).parse(req.body);
    const { userId, refresh: next } = await deps.tokens.rotateRefresh(refresh);
    return { access: await deps.tokens.signAccess(userId), refresh: next };
  });

  app.post('/auth/logout', async (req, reply) => {
    const { refresh } = z.object({ refresh: z.string() }).parse(req.body);
    await deps.tokens.revokeRefresh(refresh);
    return reply.status(204).send();
  });
}
