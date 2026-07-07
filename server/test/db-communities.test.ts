import { beforeAll, afterAll, it, expect } from 'vitest';
import { ulid } from 'ulid';
import { testDb } from './helpers/db.js';
import { channels, communities, communityMembers, messages, roles, users } from '../src/db/schema.js';
import { DEFAULT_EVERYONE } from '../src/core/permissions.js';

let ctx: Awaited<ReturnType<typeof testDb>>;
let owner: string;

beforeAll(async () => {
  ctx = await testDb();
  const [u] = await ctx.db.insert(users).values({ phone: '50211111111' }).returning();
  owner = u.id;
});
afterAll(() => ctx.stop());

it('stores community, member, everyone role with bigint permissions', async () => {
  const [c] = await ctx.db.insert(communities).values({ name: 'Los Cuates', ownerId: owner }).returning();
  await ctx.db.insert(communityMembers).values({ communityId: c.id, userId: owner });
  const [r] = await ctx.db.insert(roles).values({
    communityId: c.id, name: '@everyone', position: 0,
    permissions: DEFAULT_EVERYONE, isEveryone: true,
  }).returning();
  expect(r.permissions).toBe(DEFAULT_EVERYONE);
  expect(typeof r.permissions).toBe('bigint');
});

it('channel messages persist; conversation XOR channel is enforced', async () => {
  const [c] = await ctx.db.select().from(communities).limit(1);
  const [ch] = await ctx.db.insert(channels).values({ communityId: c.id, name: 'general' }).returning();
  const [m] = await ctx.db.insert(messages).values({
    id: ulid(), channelId: ch.id, authorId: owner, type: 'text', content: { text: 'hola canal' },
  }).returning();
  expect(m.channelId).toBe(ch.id);
  expect(m.conversationId).toBeNull();
  // ni ambos ni ninguno
  await expect(ctx.db.insert(messages).values({
    id: ulid(), authorId: owner, type: 'text', content: { text: 'sin destino' },
  })).rejects.toMatchObject({ cause: { code: '23514' } });
});
