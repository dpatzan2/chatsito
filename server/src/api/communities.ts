import { z } from 'zod';
import { eq } from 'drizzle-orm';
import type { FastifyInstance } from 'fastify';
import { channels, communities, communityMembers } from '../db/schema.js';
import {
  createCommunity, getCommunity, communityMemberIds, createInvite, joinByInvite,
  removeMember, requireMember, requirePerm,
} from '../community/service.js';
import {
  createRole, updateRole, deleteRole, assignRole, unassignRole, setOverride,
} from '../community/roles.js';
import { PERM } from '../core/permissions.js';
import { AppError } from '../core/errors.js';
import { wireChannel, wireCommunity, wireRole } from '../core/wire.js';
import type { Hub } from '../ws/hub.js';
import type { Deps } from '../app.js';

const PermString = z.string().regex(/^\d+$/).transform(BigInt);
const Name = z.string().min(1).max(50);

export function communityRoutes(app: FastifyInstance, deps: Deps, hub: Hub): void {
  const broadcast = async (communityId: string, op: string, d: unknown) => {
    hub.sendTo(await communityMemberIds(deps.db, communityId), op, d);
  };

  app.post('/communities', async (req) => {
    const { name } = z.object({ name: Name }).parse(req.body);
    return createCommunity(deps.db, req.userId, name);
  });

  app.get('/communities', async (req) => {
    const rows = await deps.db.select({ community: communities }).from(communityMembers)
      .innerJoin(communities, eq(communities.id, communityMembers.communityId))
      .where(eq(communityMembers.userId, req.userId));
    return rows.map((r) => wireCommunity(r.community));
  });

  app.get('/communities/:id', async (req) => {
    const { id } = z.object({ id: z.uuid() }).parse(req.params);
    return getCommunity(deps.db, id, req.userId);
  });

  app.patch('/communities/:id', async (req) => {
    const { id } = z.object({ id: z.uuid() }).parse(req.params);
    const { name } = z.object({ name: Name }).parse(req.body);
    await requirePerm(deps.db, { communityId: id, userId: req.userId, perm: PERM.ADMIN });
    const [updated] = await deps.db.update(communities).set({ name })
      .where(eq(communities.id, id)).returning();
    await broadcast(id, 'community.updated', wireCommunity(updated));
    return wireCommunity(updated);
  });

  app.delete('/communities/:id', async (req, reply) => {
    const { id } = z.object({ id: z.uuid() }).parse(req.params);
    const [community] = await deps.db.select().from(communities).where(eq(communities.id, id));
    if (!community) throw new AppError('NOT_FOUND', 'Community not found');
    await requireMember(deps.db, id, req.userId);
    if (community.ownerId !== req.userId) {
      throw new AppError('FORBIDDEN', 'Only the owner can delete the community');
    }
    const memberIds = await communityMemberIds(deps.db, id);
    await deps.db.delete(communities).where(eq(communities.id, id));
    hub.sendTo(memberIds, 'community.deleted', { id });
    return reply.status(204).send();
  });

  app.post('/communities/:id/invites', async (req) => {
    const { id } = z.object({ id: z.uuid() }).parse(req.params);
    const invite = await createInvite(deps.db, id, req.userId);
    return { code: invite.code, expiresAt: invite.expiresAt.getTime() };
  });

  app.post('/invites/:code/join', async (req) => {
    const { code } = z.object({ code: z.string().min(1) }).parse(req.params);
    const community = await joinByInvite(deps.db, code, req.userId);
    await broadcast(community.id, 'member.joined', { communityId: community.id, userId: req.userId });
    return getCommunity(deps.db, community.id, req.userId);
  });

  app.post('/communities/:id/channels', async (req) => {
    const { id } = z.object({ id: z.uuid() }).parse(req.params);
    const body = z.object({
      name: Name, type: z.enum(['text', 'voice']).default('text'),
      position: z.number().int().min(0).default(0),
    }).parse(req.body);
    await requirePerm(deps.db, { communityId: id, userId: req.userId, perm: PERM.MANAGE_CHANNELS });
    const [channel] = await deps.db.insert(channels).values({ communityId: id, ...body }).returning();
    await broadcast(id, 'channel.created', wireChannel(channel));
    return wireChannel(channel);
  });

  app.patch('/communities/:id/channels/:chId', async (req) => {
    const { id, chId } = z.object({ id: z.uuid(), chId: z.uuid() }).parse(req.params);
    const patch = z.object({
      name: Name.optional(), position: z.number().int().min(0).optional(),
    }).parse(req.body);
    await requirePerm(deps.db, { communityId: id, userId: req.userId, perm: PERM.MANAGE_CHANNELS });
    const [channel] = await deps.db.update(channels).set(patch)
      .where(eq(channels.id, chId)).returning();
    if (!channel || channel.communityId !== id) throw new AppError('NOT_FOUND', 'Channel not found');
    await broadcast(id, 'channel.updated', wireChannel(channel));
    return wireChannel(channel);
  });

  app.delete('/communities/:id/channels/:chId', async (req, reply) => {
    const { id, chId } = z.object({ id: z.uuid(), chId: z.uuid() }).parse(req.params);
    await requirePerm(deps.db, { communityId: id, userId: req.userId, perm: PERM.MANAGE_CHANNELS });
    const [channel] = await deps.db.delete(channels).where(eq(channels.id, chId)).returning();
    if (!channel || channel.communityId !== id) throw new AppError('NOT_FOUND', 'Channel not found');
    await broadcast(id, 'channel.deleted', { id: chId, communityId: id });
    return reply.status(204).send();
  });

  app.post('/communities/:id/roles', async (req) => {
    const { id } = z.object({ id: z.uuid() }).parse(req.params);
    const body = z.object({
      name: Name, color: z.string().regex(/^#[0-9a-fA-F]{6}$/).optional(),
      permissions: PermString, position: z.number().int().min(1).optional(),
    }).parse(req.body);
    const role = await createRole(deps.db, id, req.userId, body);
    await broadcast(id, 'role.created', wireRole(role));
    return wireRole(role);
  });

  app.patch('/communities/:id/roles/:roleId', async (req) => {
    const { roleId } = z.object({ id: z.uuid(), roleId: z.uuid() }).parse(req.params);
    const patch = z.object({
      name: Name.optional(), color: z.string().regex(/^#[0-9a-fA-F]{6}$/).optional(),
      permissions: PermString.optional(), position: z.number().int().min(1).optional(),
    }).parse(req.body);
    const role = await updateRole(deps.db, roleId, req.userId, patch);
    await broadcast(role.communityId, 'role.updated', wireRole(role));
    return wireRole(role);
  });

  app.delete('/communities/:id/roles/:roleId', async (req, reply) => {
    const { id, roleId } = z.object({ id: z.uuid(), roleId: z.uuid() }).parse(req.params);
    await deleteRole(deps.db, roleId, req.userId);
    await broadcast(id, 'role.deleted', { id: roleId, communityId: id });
    return reply.status(204).send();
  });

  app.put('/communities/:id/members/:userId/roles/:roleId', async (req, reply) => {
    const p = z.object({ id: z.uuid(), userId: z.uuid(), roleId: z.uuid() }).parse(req.params);
    await assignRole(deps.db, p.id, req.userId, p.userId, p.roleId);
    await broadcast(p.id, 'member.updated', { communityId: p.id, userId: p.userId });
    return reply.status(204).send();
  });

  app.delete('/communities/:id/members/:userId/roles/:roleId', async (req, reply) => {
    const p = z.object({ id: z.uuid(), userId: z.uuid(), roleId: z.uuid() }).parse(req.params);
    await unassignRole(deps.db, p.id, req.userId, p.userId, p.roleId);
    await broadcast(p.id, 'member.updated', { communityId: p.id, userId: p.userId });
    return reply.status(204).send();
  });

  app.delete('/communities/:id/members/:userId', async (req, reply) => {
    const p = z.object({ id: z.uuid(), userId: z.uuid() }).parse(req.params);
    const memberIds = await communityMemberIds(deps.db, p.id);
    await removeMember(deps.db, p.id, req.userId, p.userId);
    hub.sendTo(memberIds, 'member.left', { communityId: p.id, userId: p.userId });
    return reply.status(204).send();
  });

  app.put('/channels/:id/overrides/:roleId', async (req) => {
    const p = z.object({ id: z.uuid(), roleId: z.uuid() }).parse(req.params);
    const body = z.object({ allow: PermString, deny: PermString }).parse(req.body);
    const override = await setOverride(deps.db, p.id, p.roleId, req.userId, body.allow, body.deny);
    const [channel] = await deps.db.select().from(channels).where(eq(channels.id, p.id));
    await broadcast(channel.communityId, 'override.updated', {
      channelId: p.id, roleId: p.roleId,
      allow: override.allow.toString(), deny: override.deny.toString(),
    });
    return {
      channelId: override.channelId, roleId: override.roleId,
      allow: override.allow.toString(), deny: override.deny.toString(),
    };
  });
}
