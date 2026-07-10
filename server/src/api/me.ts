import { z } from 'zod';
import { eq } from 'drizzle-orm';
import type { FastifyInstance } from 'fastify';
import { users } from '../db/schema.js';
import { AppError } from '../core/errors.js';
import { publicUser } from '../core/wire.js';
import type { Deps } from '../app.js';

// ponytail: límite en memoria por proceso — mover a Redis si algún día hay varios nodos
const lookupHits = new Map<string, { count: number; resetAt: number }>();
const LOOKUP_LIMIT = 30;
const LOOKUP_WINDOW_MS = 60_000;

function assertLookupAllowed(userId: string): void {
  const now = Date.now();
  const hit = lookupHits.get(userId);
  if (!hit || hit.resetAt <= now) {
    lookupHits.set(userId, { count: 1, resetAt: now + LOOKUP_WINDOW_MS });
    return;
  }
  hit.count += 1;
  if (hit.count > LOOKUP_LIMIT) throw new AppError('RATE_LIMITED', 'Too many lookups, retry later');
}

export function meRoutes(app: FastifyInstance, deps: Deps): void {
  app.get('/me', async (req) => {
    const [u] = await deps.db.select().from(users).where(eq(users.id, req.userId));
    if (!u) throw new AppError('NOT_FOUND', 'User not found');
    return publicUser(u);
  });

  // descubrimiento por teléfono estilo WhatsApp — un usuario autenticado puede confirmar
  // si un número tiene cuenta; la enumeración masiva se mitiga con 30 consultas/min por usuario
  app.get('/users/lookup', async (req) => {
    assertLookupAllowed(req.userId);
    const { phone } = z.object({ phone: z.string().regex(/^\d{8,15}$/) }).parse(req.query);
    const [u] = await deps.db.select().from(users).where(eq(users.phone, phone));
    if (!u) throw new AppError('NOT_FOUND', 'User not found');
    return publicUser(u);
  });

  app.patch('/me', async (req) => {
    const body = z.object({
      displayName: z.string().min(1).max(50).optional(),
      avatarColor: z.string().regex(/^#[0-9a-fA-F]{6}$/).optional(),
      // solo rutas de nuestro propio /uploads: evita URLs externas o javascript: en el avatar
      avatarUrl: z.string().regex(/^\/uploads\/[\w.-]+$/).max(300).optional(),
    }).parse(req.body);
    const [u] = await deps.db.update(users).set(body).where(eq(users.id, req.userId)).returning();
    if (!u) throw new AppError('NOT_FOUND', 'User not found');
    return publicUser(u);
  });

  app.delete('/me', async (req, reply) => {
    await deps.db.delete(users).where(eq(users.id, req.userId));
    app.hub.closeAll(req.userId);
    return reply.status(204).send();
  });
}
