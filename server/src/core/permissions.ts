export const PERM = {
  VIEW_CHANNEL: 1n << 0n,
  SEND_MESSAGES: 1n << 1n,
  MANAGE_MESSAGES: 1n << 2n,
  MANAGE_CHANNELS: 1n << 3n,
  MANAGE_ROLES: 1n << 4n,
  KICK_MEMBERS: 1n << 5n,
  MANAGE_INVITES: 1n << 6n,
  VOICE_CONNECT: 1n << 7n,
  VOICE_SPEAK: 1n << 8n,
  VOICE_MUTE_MEMBERS: 1n << 9n,
  ADMIN: 1n << 10n,
} as const;

export const ALL_PERMS = Object.values(PERM).reduce((a, b) => a | b, 0n);

export const DEFAULT_EVERYONE =
  PERM.VIEW_CHANNEL | PERM.SEND_MESSAGES | PERM.VOICE_CONNECT | PERM.VOICE_SPEAK;

export function computePermissions(input: {
  isOwner: boolean;
  rolePerms: bigint[];
  overrides?: Array<{ allow: bigint; deny: bigint }>;
}): bigint {
  if (input.isOwner) return ALL_PERMS;
  const base = input.rolePerms.reduce((a, b) => a | b, 0n);
  if (base & PERM.ADMIN) return ALL_PERMS;
  const allow = (input.overrides ?? []).reduce((a, o) => a | o.allow, 0n);
  const deny = (input.overrides ?? []).reduce((a, o) => a | o.deny, 0n);
  return (base | allow) & ~deny;
}

export const can = (perms: bigint, mask: bigint): boolean => (perms & mask) === mask;
