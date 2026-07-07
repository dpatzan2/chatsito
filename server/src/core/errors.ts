export type ErrorCode =
  | 'AUTH_EXPIRED' | 'AUTH_INVALID' | 'FORBIDDEN' | 'NOT_FOUND' | 'VALIDATION'
  | 'RATE_LIMITED' | 'CONFLICT' | 'OTP_INVALID' | 'OTP_EXPIRED' | 'INTERNAL';

const STATUS: Record<ErrorCode, number> = {
  AUTH_EXPIRED: 401, AUTH_INVALID: 401, FORBIDDEN: 403, NOT_FOUND: 404,
  VALIDATION: 400, RATE_LIMITED: 429, CONFLICT: 409,
  OTP_INVALID: 400, OTP_EXPIRED: 400, INTERNAL: 500,
};

export class AppError extends Error {
  constructor(public readonly code: ErrorCode, message: string) {
    super(message);
  }
  get status(): number {
    return STATUS[this.code];
  }
}
