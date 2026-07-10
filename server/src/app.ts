import { mkdirSync } from 'node:fs';
import { resolve } from 'node:path';
import Fastify, { type FastifyInstance } from 'fastify';
import fastifyStatic from '@fastify/static';
import { ZodError } from 'zod';
import { AppError } from './core/errors.js';
import { uploadRoutes } from './api/uploads.js';
import { authRoutes } from './api/auth.js';
import { meRoutes } from './api/me.js';
import { conversationRoutes } from './api/conversations.js';
import { communityRoutes } from './api/communities.js';
import { voiceWebhookRoutes } from './api/voice-webhook.js';
import { authGuard } from './api/guard.js';
import { registerGateway } from './ws/gateway.js';
import { Hub } from './ws/hub.js';
import { VoiceStates } from './voice/state.js';
import type { LiveKitCfg, RoomApi } from './voice/livekit.js';

declare module 'fastify' {
  interface FastifyInstance {
    hub: Hub;
  }
}
import type { Db } from './db/client.js';
import type { SmsSender } from './auth/sms.js';
import type { Tokens } from './auth/tokens.js';

export interface Deps {
  db: Db;
  sms: SmsSender;
  tokens: Tokens;
  lk?: LiveKitCfg;   // default: DEV_LIVEKIT (modo --dev del compose)
  lkApi?: RoomApi;   // inyectable en tests
  uploadsDir?: string; // default: ./uploads
}

export function buildApp(deps: Deps): FastifyInstance {
  const app = Fastify({ logger: process.env.NODE_ENV !== 'test' });

  app.setErrorHandler((err, req, reply) => {
    if (err instanceof AppError) {
      return reply.status(err.status).send({ error: { code: err.code, message: err.message } });
    }
    if (err instanceof ZodError) {
      const message = err.issues.map((i) => `${i.path.join('.')}: ${i.message}`).join('; ');
      return reply.status(400).send({ error: { code: 'VALIDATION', message } });
    }
    req.log.error(err);
    return reply.status(500).send({ error: { code: 'INTERNAL', message: 'Internal server error' } });
  });

  app.setNotFoundHandler((_req, reply) =>
    reply.status(404).send({ error: { code: 'NOT_FOUND', message: 'Route not found' } }),
  );

  const uploadsDir = resolve(deps.uploadsDir ?? 'uploads');
  mkdirSync(uploadsDir, { recursive: true });
  app.register(fastifyStatic, { root: uploadsDir, prefix: '/uploads/' });

  const hub = new Hub();
  app.decorate('hub', hub);
  const voice = new VoiceStates();
  voiceWebhookRoutes(app, deps, hub, voice); // fuera del scope autenticado: valida la firma de LiveKit

  authRoutes(app, deps);
  app.register(async (scope) => {
    scope.addHook('onRequest', authGuard(deps.tokens));
    await uploadRoutes(scope, uploadsDir);
    meRoutes(scope, deps);
    conversationRoutes(scope, deps);
    communityRoutes(scope, deps, hub);
  });
  app.register(async (scope) => registerGateway(scope, deps, hub, voice));

  return app;
}
