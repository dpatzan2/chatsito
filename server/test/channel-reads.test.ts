import { beforeAll, afterAll, it, expect } from 'vitest';
import { testDb } from './helpers/db.js';
import {
  createCommunity, createInvite, joinByInvite, channelUnreads, getCommunity,
} from '../src/community/service.js';
import { sendChannelMessage, markChannelRead } from '../src/community/channel-messages.js';
import { users } from '../src/db/schema.js';

let ctx: Awaited<ReturnType<typeof testDb>>;
let owner: string, member: string;
let communityId: string, channelId: string;

beforeAll(async () => {
  ctx = await testDb();
  const rows = await ctx.db.insert(users).values([
    { phone: '50211111111', displayName: 'Owner' },
    { phone: '50222222222', displayName: 'Member' },
  ]).returning();
  [owner, member] = rows.map((r) => r.id);
  const c = await createCommunity(ctx.db, owner, 'Reads');
  communityId = c.id;
  channelId = c.channels[0].id;
  const inv = await createInvite(ctx.db, communityId, owner);
  await joinByInvite(ctx.db, inv.code, member);
});
afterAll(() => ctx.stop());

it('counts channel messages from others as unread until markChannelRead', async () => {
  const msg = await sendChannelMessage(ctx.db, {
    channelId, authorId: owner, type: 'text', content: { text: 'hola' },
  });
  expect((await channelUnreads(ctx.db, communityId, member)).get(channelId)).toBe(1);
  expect((await channelUnreads(ctx.db, communityId, owner)).get(channelId)).toBe(0);

  await markChannelRead(ctx.db, member, channelId, msg.id);
  expect((await channelUnreads(ctx.db, communityId, member)).get(channelId)).toBe(0);

  const c = await getCommunity(ctx.db, communityId, member);
  expect(c.channels[0].unread).toBe(0);
});

it('markChannelRead requires membership', async () => {
  const [out] = await ctx.db.insert(users).values({ phone: '50233333333' }).returning();
  await expect(markChannelRead(ctx.db, out.id, channelId, 'X'))
    .rejects.toMatchObject({ code: 'NOT_FOUND' });
});
