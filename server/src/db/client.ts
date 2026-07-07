import postgres from 'postgres';
import { drizzle } from 'drizzle-orm/postgres-js';
import * as schema from './schema.js';

export function createDb(url: string) {
  const sql = postgres(url);
  const db = drizzle(sql, { schema });
  return { db, sql };
}

export type Db = ReturnType<typeof createDb>['db'];
