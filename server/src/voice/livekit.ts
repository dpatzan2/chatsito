import { createHash } from 'node:crypto';
import { SignJWT, jwtVerify } from 'jose';
import { AppError } from '../core/errors.js';

export interface LiveKitCfg {
  url: string;
  apiKey: string;
  apiSecret: string;
}

// valores del modo --dev del compose
export const DEV_LIVEKIT: LiveKitCfg = {
  url: 'ws://localhost:7880', apiKey: 'devkey', apiSecret: 'secret',
};

const key = (cfg: LiveKitCfg) => new TextEncoder().encode(cfg.apiSecret);

function signGrant(
  cfg: LiveKitCfg, identity: string, video: Record<string, unknown>, ttlSec: number,
): Promise<string> {
  return new SignJWT({ video })
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuer(cfg.apiKey)
    .setSubject(identity)
    .setJti(identity)
    .setIssuedAt()
    .setExpirationTime(`${ttlSec}s`)
    .sign(key(cfg));
}

export function signVoiceToken(
  cfg: LiveKitCfg,
  opts: { identity: string; room: string; canPublish: boolean; ttlSec?: number },
): Promise<string> {
  return signGrant(cfg, opts.identity, {
    room: opts.room, roomJoin: true, canPublish: opts.canPublish, canSubscribe: true,
  }, opts.ttlSec ?? 600);
}

export interface WebhookEvent {
  event: string;
  room?: { name: string };
  participant?: { identity: string };
}

export async function verifyWebhook(
  cfg: LiveKitCfg, rawBody: string, authHeader: string,
): Promise<WebhookEvent> {
  let sha256: unknown;
  try {
    ({ payload: { sha256 } } = await jwtVerify(authHeader, key(cfg), { issuer: cfg.apiKey }));
  } catch {
    throw new AppError('AUTH_INVALID', 'Bad webhook signature');
  }
  const digest = createHash('sha256').update(rawBody).digest('base64');
  if (sha256 !== digest) throw new AppError('AUTH_INVALID', 'Webhook body hash mismatch');
  return JSON.parse(rawBody) as WebhookEvent;
}

export interface RoomApi {
  updateParticipant(room: string, identity: string, canPublish: boolean): Promise<void>;
  removeParticipant(room: string, identity: string): Promise<void>;
}

// ponytail: cliente Twirp mínimo con fetch; livekit-server-sdk si crecen las llamadas
export function roomApi(cfg: LiveKitCfg): RoomApi {
  const httpUrl = cfg.url.replace(/^ws/, 'http');
  const call = async (method: string, body: Record<string, unknown>): Promise<void> => {
    const token = await signGrant(cfg, 'server', { roomAdmin: true, room: String(body.room) }, 60);
    const res = await fetch(`${httpUrl}/twirp/livekit.RoomService/${method}`, {
      method: 'POST',
      headers: { authorization: `Bearer ${token}`, 'content-type': 'application/json' },
      body: JSON.stringify(body),
    });
    if (!res.ok) throw new Error(`livekit ${method} ${res.status}: ${await res.text()}`);
  };
  return {
    updateParticipant: (room, identity, canPublish) =>
      call('UpdateParticipant', {
        room, identity,
        permission: { canSubscribe: true, canPublish, canPublishData: true },
      }),
    removeParticipant: (room, identity) => call('RemoveParticipant', { room, identity }),
  };
}
