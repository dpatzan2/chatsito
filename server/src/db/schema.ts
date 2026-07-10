import {
  pgTable, uuid, text, timestamp, integer, jsonb, index, uniqueIndex, primaryKey,
  bigint, boolean, check,
} from 'drizzle-orm/pg-core';
import { sql } from 'drizzle-orm';

export const users = pgTable('users', {
  id: uuid('id').primaryKey().defaultRandom(),
  phone: text('phone').notNull().unique(),
  displayName: text('display_name'),
  avatarColor: text('avatar_color'),
  avatarUrl: text('avatar_url'),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
});

export const otpCodes = pgTable('otp_codes', {
  id: uuid('id').primaryKey().defaultRandom(),
  phone: text('phone').notNull(),
  codeHash: text('code_hash').notNull(),
  attempts: integer('attempts').notNull().default(0),
  expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
});

export const sessions = pgTable('sessions', {
  id: uuid('id').primaryKey().defaultRandom(),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  tokenHash: text('token_hash').notNull().unique(),
  expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
});

export const conversations = pgTable('conversations', {
  id: uuid('id').primaryKey().defaultRandom(),
  userA: uuid('user_a').notNull().references(() => users.id, { onDelete: 'cascade' }),
  userB: uuid('user_b').notNull().references(() => users.id, { onDelete: 'cascade' }),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
}, (t) => [uniqueIndex('conversations_pair_idx').on(t.userA, t.userB)]);

export const messages = pgTable('messages', {
  id: text('id').primaryKey(), // ULID: ordenable → paginación keyset
  conversationId: uuid('conversation_id')
    .references(() => conversations.id, { onDelete: 'cascade' }),
  channelId: uuid('channel_id')
    .references(() => channels.id, { onDelete: 'cascade' }),
  authorId: uuid('author_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  type: text('type', { enum: ['text', 'image', 'video', 'doc', 'sticker'] }).notNull(),
  content: jsonb('content').notNull().$type<Record<string, unknown>>(),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
  deletedAt: timestamp('deleted_at', { withTimezone: true }),
}, (t) => [
  index('messages_conversation_idx').on(t.conversationId, t.id),
  index('messages_channel_idx').on(t.channelId, t.id),
  check('messages_target_check', sql`num_nonnulls(conversation_id, channel_id) = 1`),
]);

export const readStates = pgTable('read_states', {
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  conversationId: uuid('conversation_id').notNull()
    .references(() => conversations.id, { onDelete: 'cascade' }),
  lastReadMessageId: text('last_read_message_id').notNull(),
}, (t) => [primaryKey({ columns: [t.userId, t.conversationId] })]);

export const channelReadStates = pgTable('channel_read_states', {
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  channelId: uuid('channel_id').notNull()
    .references(() => channels.id, { onDelete: 'cascade' }),
  lastReadMessageId: text('last_read_message_id').notNull(),
}, (t) => [primaryKey({ columns: [t.userId, t.channelId] })]);

export const communities = pgTable('communities', {
  id: uuid('id').primaryKey().defaultRandom(),
  name: text('name').notNull(),
  ownerId: uuid('owner_id').notNull().references(() => users.id),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
});

export const communityMembers = pgTable('community_members', {
  communityId: uuid('community_id').notNull()
    .references(() => communities.id, { onDelete: 'cascade' }),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
  joinedAt: timestamp('joined_at', { withTimezone: true }).notNull().defaultNow(),
}, (t) => [primaryKey({ columns: [t.communityId, t.userId] })]);

export const roles = pgTable('roles', {
  id: uuid('id').primaryKey().defaultRandom(),
  communityId: uuid('community_id').notNull()
    .references(() => communities.id, { onDelete: 'cascade' }),
  name: text('name').notNull(),
  color: text('color'),
  position: integer('position').notNull().default(1),
  permissions: bigint('permissions', { mode: 'bigint' }).notNull().default(sql`0`),
  isEveryone: boolean('is_everyone').notNull().default(false),
});

export const memberRoles = pgTable('member_roles', {
  roleId: uuid('role_id').notNull().references(() => roles.id, { onDelete: 'cascade' }),
  userId: uuid('user_id').notNull().references(() => users.id, { onDelete: 'cascade' }),
}, (t) => [primaryKey({ columns: [t.roleId, t.userId] })]);

export const channels = pgTable('channels', {
  id: uuid('id').primaryKey().defaultRandom(),
  communityId: uuid('community_id').notNull()
    .references(() => communities.id, { onDelete: 'cascade' }),
  name: text('name').notNull(),
  type: text('type', { enum: ['text', 'voice'] }).notNull().default('text'),
  position: integer('position').notNull().default(0),
  createdAt: timestamp('created_at', { withTimezone: true }).notNull().defaultNow(),
});

export const channelOverrides = pgTable('channel_overrides', {
  channelId: uuid('channel_id').notNull().references(() => channels.id, { onDelete: 'cascade' }),
  roleId: uuid('role_id').notNull().references(() => roles.id, { onDelete: 'cascade' }),
  allow: bigint('allow', { mode: 'bigint' }).notNull().default(sql`0`),
  deny: bigint('deny', { mode: 'bigint' }).notNull().default(sql`0`),
}, (t) => [primaryKey({ columns: [t.channelId, t.roleId] })]);

export const invites = pgTable('invites', {
  code: text('code').primaryKey(),
  communityId: uuid('community_id').notNull()
    .references(() => communities.id, { onDelete: 'cascade' }),
  createdBy: uuid('created_by').notNull().references(() => users.id),
  expiresAt: timestamp('expires_at', { withTimezone: true }).notNull(),
  uses: integer('uses').notNull().default(0),
});
