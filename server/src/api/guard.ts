import type { FastifyRequest } from 'fastify';
import { AppError } from '../core/errors.js';
import type { Tokens } from '../auth/tokens.js';

declare module 'fastify' {
  interface FastifyRequest {
    userId: string;
  }
}

export function authGuard(tokens: Tokens) {
  return async (req: FastifyRequest): Promise<void> => {
    const header = req.headers.authorization;
    if (!header?.startsWith('Bearer ')) {
      throw new AppError('AUTH_INVALID', 'Missing bearer token');
    }
    req.userId = await tokens.verifyAccess(header.slice(7));
  };
}
