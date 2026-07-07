import { beforeAll, afterAll, beforeEach, it, expect } from 'vitest';
import { testDb } from './helpers/db.js';
import { requestOtp, verifyOtp } from '../src/auth/otp.js';
import { otpCodes, users } from '../src/db/schema.js';
import type { SmsSender } from '../src/auth/sms.js';

let ctx: Awaited<ReturnType<typeof testDb>>;
let sent: string[] = [];
const sms: SmsSender = { async send(_phone, body) { sent.push(body); } };
const PHONE = '50211111111';

const codeFrom = (body: string) => body.match(/\d{6}/)![0];
const wrongCode = (right: string) => (right === '000000' ? '000001' : '000000');

beforeAll(async () => { ctx = await testDb(); });
afterAll(() => ctx.stop());
beforeEach(async () => {
  sent = [];
  await ctx.db.delete(otpCodes);
  await ctx.db.delete(users);
});

it('sends a 6-digit code and verifies it, creating the user', async () => {
  await requestOtp(ctx.db, sms, PHONE);
  expect(sent).toHaveLength(1);
  const user = await verifyOtp(ctx.db, PHONE, codeFrom(sent[0]));
  expect(user.phone).toBe(PHONE);
});

it('verifying twice with the same code fails (code is consumed)', async () => {
  await requestOtp(ctx.db, sms, PHONE);
  const code = codeFrom(sent[0]);
  await verifyOtp(ctx.db, PHONE, code);
  await expect(verifyOtp(ctx.db, PHONE, code)).rejects.toMatchObject({ code: 'OTP_EXPIRED' });
});

it('same phone verified twice keeps one user', async () => {
  await requestOtp(ctx.db, sms, PHONE);
  const u1 = await verifyOtp(ctx.db, PHONE, codeFrom(sent[0]));
  await requestOtp(ctx.db, sms, PHONE);
  const u2 = await verifyOtp(ctx.db, PHONE, codeFrom(sent[1]));
  expect(u2.id).toBe(u1.id);
});

it('wrong code → OTP_INVALID, and locks after 5 attempts', async () => {
  await requestOtp(ctx.db, sms, PHONE);
  const right = codeFrom(sent[0]);
  for (let i = 0; i < 5; i++) {
    await expect(verifyOtp(ctx.db, PHONE, wrongCode(right))).rejects.toMatchObject({ code: 'OTP_INVALID' });
  }
  await expect(verifyOtp(ctx.db, PHONE, right)).rejects.toMatchObject({ code: 'OTP_INVALID' });
});

it('rate limits after 3 requests in an hour', async () => {
  for (let i = 0; i < 3; i++) await requestOtp(ctx.db, sms, PHONE);
  await expect(requestOtp(ctx.db, sms, PHONE)).rejects.toMatchObject({ code: 'RATE_LIMITED' });
});

it('expired code → OTP_EXPIRED', async () => {
  await ctx.db.insert(otpCodes).values({
    phone: PHONE,
    codeHash: 'x',
    expiresAt: new Date(Date.now() - 1000),
  });
  await expect(verifyOtp(ctx.db, PHONE, '123456')).rejects.toMatchObject({ code: 'OTP_EXPIRED' });
});
