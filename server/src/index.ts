import { migrate } from 'drizzle-orm/postgres-js/migrator';
import { loadConfig } from './core/config.js';
import { createDb } from './db/client.js';
import { devSms, twilioSms } from './auth/sms.js';
import { tokenService } from './auth/tokens.js';
import { buildApp } from './app.js';

const config = loadConfig();
const { db } = createDb(config.DATABASE_URL);
await migrate(db, { migrationsFolder: 'src/db/migrations' });

const sms =
  config.TWILIO_ACCOUNT_SID && config.TWILIO_AUTH_TOKEN && config.TWILIO_FROM
    ? twilioSms(config.TWILIO_ACCOUNT_SID, config.TWILIO_AUTH_TOKEN, config.TWILIO_FROM)
    : devSms(console.log);

const app = buildApp({ db, sms, tokens: tokenService(db, config.JWT_SECRET) });
await app.listen({ port: config.PORT, host: '0.0.0.0' });
