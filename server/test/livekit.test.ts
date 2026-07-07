import { createHash } from 'node:crypto';
import { describe, it, expect } from 'vitest';
import { SignJWT, jwtVerify } from 'jose';
import { DEV_LIVEKIT, signVoiceToken, verifyWebhook } from '../src/voice/livekit.js';

const secret = new TextEncoder().encode(DEV_LIVEKIT.apiSecret);

// firma un header de webhook como lo hace LiveKit: JWT con sha256 (base64) del body
async function webhookAuth(body: string, apiSecret = DEV_LIVEKIT.apiSecret): Promise<string> {
  return new SignJWT({ sha256: createHash('sha256').update(body).digest('base64') })
    .setProtectedHeader({ alg: 'HS256' })
    .setIssuer(DEV_LIVEKIT.apiKey)
    .setIssuedAt()
    .setExpirationTime('1m')
    .sign(new TextEncoder().encode(apiSecret));
}

describe('signVoiceToken', () => {
  it('signs a LiveKit JWT with the right grants', async () => {
    const token = await signVoiceToken(DEV_LIVEKIT, {
      identity: 'user-1', room: 'chan-1', canPublish: true,
    });
    const { payload } = await jwtVerify(token, secret);
    expect(payload.iss).toBe('devkey');
    expect(payload.sub).toBe('user-1');
    expect(payload.video).toMatchObject({
      room: 'chan-1', roomJoin: true, canPublish: true, canSubscribe: true,
    });
    expect(payload.exp! - Math.floor(Date.now() / 1000)).toBeLessThanOrEqual(600);
  });

  it('listen-only token when canPublish is false', async () => {
    const token = await signVoiceToken(DEV_LIVEKIT, {
      identity: 'user-2', room: 'chan-1', canPublish: false,
    });
    const { payload } = await jwtVerify(token, secret);
    expect((payload.video as { canPublish: boolean }).canPublish).toBe(false);
  });
});

describe('verifyWebhook', () => {
  const body = JSON.stringify({
    event: 'participant_joined',
    room: { name: 'chan-1' },
    participant: { identity: 'user-1' },
  });

  it('accepts a correctly signed webhook and parses it', async () => {
    const ev = await verifyWebhook(DEV_LIVEKIT, body, await webhookAuth(body));
    expect(ev.event).toBe('participant_joined');
    expect(ev.room?.name).toBe('chan-1');
    expect(ev.participant?.identity).toBe('user-1');
  });

  it('rejects a tampered body', async () => {
    const auth = await webhookAuth(body);
    const tampered = body.replace('user-1', 'user-9');
    await expect(verifyWebhook(DEV_LIVEKIT, tampered, auth))
      .rejects.toMatchObject({ code: 'AUTH_INVALID' });
  });

  it('rejects a header signed with the wrong secret', async () => {
    const auth = await webhookAuth(body, 'wrong-secret');
    await expect(verifyWebhook(DEV_LIVEKIT, body, auth))
      .rejects.toMatchObject({ code: 'AUTH_INVALID' });
  });
});
