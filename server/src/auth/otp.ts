import { createHash, randomInt } from 'node:crypto';
import { and, desc, eq, gt } from 'drizzle-orm';
import { otpCodes, users } from '../db/schema.js';
import { AppError } from '../core/errors.js';
import type { Db } from '../db/client.js';
import type { SmsSender } from './sms.js';

const OTP_TTL_MS = 5 * 60_000;
const MAX_ATTEMPTS = 5;
const MAX_PER_HOUR = 3;

const sha256 = (s: string) => createHash('sha256').update(s).digest('hex');

export async function requestOtp(db: Db, sms: SmsSender, phone: string): Promise<void> {
  const hourAgo = new Date(Date.now() - 3600_000);
  const recent = await db.select({ id: otpCodes.id }).from(otpCodes)
    .where(and(eq(otpCodes.phone, phone), gt(otpCodes.createdAt, hourAgo)));
  if (recent.length >= MAX_PER_HOUR) {
    throw new AppError('RATE_LIMITED', 'Too many codes requested, try again later');
  }
  const code = randomInt(0, 1_000_000).toString().padStart(6, '0');
  await db.insert(otpCodes).values({
    phone,
    codeHash: sha256(code),
    expiresAt: new Date(Date.now() + OTP_TTL_MS),
  });
  await sms.send(phone, `Tu código de Chatsito es ${code}`);
}

export async function verifyOtp(db: Db, phone: string, code: string) {
  const [otp] = await db.select().from(otpCodes)
    .where(and(eq(otpCodes.phone, phone), gt(otpCodes.expiresAt, new Date())))
    .orderBy(desc(otpCodes.createdAt))
    .limit(1);
  if (!otp) throw new AppError('OTP_EXPIRED', 'Code expired or never requested');
  if (otp.attempts >= MAX_ATTEMPTS) {
    throw new AppError('OTP_INVALID', 'Too many attempts, request a new code');
  }
  if (otp.codeHash !== sha256(code)) {
    await db.update(otpCodes).set({ attempts: otp.attempts + 1 }).where(eq(otpCodes.id, otp.id));
    throw new AppError('OTP_INVALID', 'Incorrect code');
  }
  await db.delete(otpCodes).where(eq(otpCodes.phone, phone));
  const [user] = await db.insert(users).values({ phone })
    .onConflictDoUpdate({ target: users.phone, set: { phone } })
    .returning();
  return user;
}
