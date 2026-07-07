import { SignJWT, jwtVerify, errors as joseErrors } from 'jose';
import { createHash, randomBytes } from 'node:crypto';
import { eq } from 'drizzle-orm';
import { sessions } from '../db/schema.js';
import { AppError } from '../core/errors.js';
import type { Db } from '../db/client.js';

const REFRESH_TTL_MS = 30 * 86_400_000;
const sha256 = (s: string) => createHash('sha256').update(s).digest('hex');

export function tokenService(db: Db, secret: string) {
  const key = new TextEncoder().encode(secret);
  return {
    async signAccess(userId: string): Promise<string> {
      return new SignJWT({})
        .setProtectedHeader({ alg: 'HS256' })
        .setSubject(userId)
        .setIssuedAt()
        .setExpirationTime('15m')
        .sign(key);
    },

    async verifyAccess(token: string): Promise<string> {
      try {
        const { payload } = await jwtVerify(token, key);
        return payload.sub as string;
      } catch (e) {
        if (e instanceof joseErrors.JWTExpired) {
          throw new AppError('AUTH_EXPIRED', 'Access token expired');
        }
        throw new AppError('AUTH_INVALID', 'Invalid access token');
      }
    },

    async createRefresh(userId: string): Promise<string> {
      const token = randomBytes(48).toString('base64url');
      await db.insert(sessions).values({
        userId,
        tokenHash: sha256(token),
        expiresAt: new Date(Date.now() + REFRESH_TTL_MS),
      });
      return token;
    },

    async rotateRefresh(token: string): Promise<{ userId: string; refresh: string }> {
      const [s] = await db.delete(sessions).where(eq(sessions.tokenHash, sha256(token))).returning();
      if (!s || s.expiresAt < new Date()) {
        throw new AppError('AUTH_INVALID', 'Invalid refresh token');
      }
      return { userId: s.userId, refresh: await this.createRefresh(s.userId) };
    },

    async revokeRefresh(token: string): Promise<void> {
      await db.delete(sessions).where(eq(sessions.tokenHash, sha256(token)));
    },
  };
}

export type Tokens = ReturnType<typeof tokenService>;
