import { PostgreSqlContainer } from '@testcontainers/postgresql';
import { migrate } from 'drizzle-orm/postgres-js/migrator';
import { createDb } from '../../src/db/client.js';

export async function testDb() {
  const container = await new PostgreSqlContainer('postgres:17-alpine').start();
  const { db, sql } = createDb(container.getConnectionUri());
  await migrate(db, { migrationsFolder: 'src/db/migrations' });
  return {
    db,
    sql,
    stop: async () => {
      await sql.end();
      await container.stop();
    },
  };
}
