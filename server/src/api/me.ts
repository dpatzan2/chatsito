import { z } from 'zod';
import { eq } from 'drizzle-orm';
import type { FastifyInstance } from 'fastify';
import { users } from '../db/schema.js';
import { AppError } from '../core/errors.js';
import { publicUser } from '../core/wire.js';
import type { Deps } from '../app.js';

export function meRoutes(app: FastifyInstance, deps: Deps): void {
  app.get('/me', async (req) => {
    const [u] = await deps.db.select().from(users).where(eq(users.id, req.userId));
    if (!u) throw new AppError('NOT_FOUND', 'User not found');
    return publicUser(u);
  });

  app.get('/users/lookup', async (req) => {
    const { phone } = z.object({ phone: z.string().regex(/^\d{8,15}$/) }).parse(req.query);
    const [u] = await deps.db.select().from(users).where(eq(users.phone, phone));
    if (!u) throw new AppError('NOT_FOUND', 'User not found');
    return publicUser(u);
  });

  app.patch('/me', async (req) => {
    const body = z.object({
      displayName: z.string().min(1).max(50).optional(),
      avatarColor: z.string().regex(/^#[0-9a-fA-F]{6}$/).optional(),
    }).parse(req.body);
    const [u] = await deps.db.update(users).set(body).where(eq(users.id, req.userId)).returning();
    if (!u) throw new AppError('NOT_FOUND', 'User not found');
    return publicUser(u);
  });
}
