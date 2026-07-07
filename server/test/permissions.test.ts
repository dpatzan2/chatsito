import { describe, it, expect } from 'vitest';
import { PERM, ALL_PERMS, DEFAULT_EVERYONE, computePermissions, can } from '../src/core/permissions.js';

const P = PERM;

describe('computePermissions', () => {
  it('owner gets everything, ignoring roles and overrides', () => {
    expect(computePermissions({
      isOwner: true, rolePerms: [0n],
      overrides: [{ allow: 0n, deny: ALL_PERMS }],
    })).toBe(ALL_PERMS);
  });

  it('ADMIN grants everything', () => {
    expect(computePermissions({ isOwner: false, rolePerms: [P.ADMIN] })).toBe(ALL_PERMS);
  });

  it('base is the OR of all role permissions', () => {
    const got = computePermissions({
      isOwner: false, rolePerms: [P.VIEW_CHANNEL, P.SEND_MESSAGES | P.KICK_MEMBERS],
    });
    expect(can(got, P.VIEW_CHANNEL | P.SEND_MESSAGES | P.KICK_MEMBERS)).toBe(true);
    expect(can(got, P.MANAGE_ROLES)).toBe(false);
  });

  it('override allow adds on top of base', () => {
    const got = computePermissions({
      isOwner: false, rolePerms: [P.VIEW_CHANNEL],
      overrides: [{ allow: P.SEND_MESSAGES, deny: 0n }],
    });
    expect(can(got, P.SEND_MESSAGES)).toBe(true);
  });

  it('override deny wins over base and over allow', () => {
    const got = computePermissions({
      isOwner: false, rolePerms: [DEFAULT_EVERYONE],
      overrides: [
        { allow: P.SEND_MESSAGES, deny: 0n },
        { allow: 0n, deny: P.SEND_MESSAGES | P.VIEW_CHANNEL },
      ],
    });
    expect(can(got, P.SEND_MESSAGES)).toBe(false);
    expect(can(got, P.VIEW_CHANNEL)).toBe(false);
    expect(can(got, P.VOICE_CONNECT)).toBe(true); // no tocado por overrides
  });

  it('can() requires every bit of the mask', () => {
    expect(can(P.VIEW_CHANNEL, P.VIEW_CHANNEL | P.SEND_MESSAGES)).toBe(false);
  });

  it('all 11 bits are distinct', () => {
    const values = Object.values(PERM);
    expect(new Set(values.map(String)).size).toBe(11);
    expect(values.reduce((a, b) => a | b, 0n)).toBe(ALL_PERMS);
  });
});
