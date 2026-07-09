import 'package:flutter/material.dart';

class Channel {
  final String id, communityId, name, type; // 'text' | 'voice'
  final int unread;
  const Channel({
    required this.id, required this.communityId, required this.name, required this.type,
    this.unread = 0,
  });
  bool get isVoice => type == 'voice';
}

/// Bits de permisos — espejo de server/src/core/permissions.ts.
abstract final class Perm {
  static final viewChannel = BigInt.one << 0;
  static final sendMessages = BigInt.one << 1;
  static final manageMessages = BigInt.one << 2;
  static final manageChannels = BigInt.one << 3;
  static final manageRoles = BigInt.one << 4;
  static final kickMembers = BigInt.one << 5;
  static final manageInvites = BigInt.one << 6;
  static final voiceConnect = BigInt.one << 7;
  static final voiceSpeak = BigInt.one << 8;
  static final voiceMuteMembers = BigInt.one << 9;
  static final admin = BigInt.one << 10;
  static final all = (BigInt.one << 11) - BigInt.one;

  static final labels = <(BigInt, String)>[
    (viewChannel, 'Ver canales'),
    (sendMessages, 'Enviar mensajes'),
    (manageMessages, 'Gestionar mensajes'),
    (manageChannels, 'Gestionar canales'),
    (manageRoles, 'Gestionar roles'),
    (kickMembers, 'Expulsar miembros'),
    (manageInvites, 'Crear invitaciones'),
    (voiceConnect, 'Conectarse a voz'),
    (voiceSpeak, 'Hablar en voz'),
    (voiceMuteMembers, 'Silenciar a otros'),
    (admin, 'Administrador'),
  ];
}

class Role {
  final String id, name;
  final Color? color;
  final int position;
  final BigInt permissions;
  final bool isEveryone;
  const Role({
    required this.id, required this.name, this.color,
    required this.position, required this.permissions, this.isEveryone = false,
  });
}

class Member {
  final String id, name;
  final Color color;
  final List<String> roleIds;
  const Member({required this.id, required this.name, required this.color, this.roleIds = const []});
}

class Community {
  final String id, name, ownerId;
  final List<Channel> channels;
  final List<Role> roles;
  final List<Member> members;
  const Community({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.channels,
    required this.roles,
    required this.members,
  });

  List<Channel> get textChannels => [for (final c in channels) if (!c.isVoice) c];
  List<Channel> get voiceChannels => [for (final c in channels) if (c.isVoice) c];

  Member? member(String id) {
    for (final m in members) {
      if (m.id == id) return m;
    }
    return null;
  }

  BigInt permsOf(String userId) {
    if (userId == ownerId) return Perm.all;
    final m = member(userId);
    var p = BigInt.zero;
    for (final r in roles) {
      if (r.isEveryone || (m?.roleIds.contains(r.id) ?? false)) p |= r.permissions;
    }
    return p;
  }

  bool can(String userId, BigInt perm) {
    final p = permsOf(userId);
    if (p & Perm.admin == Perm.admin) return true;
    return p & perm == perm;
  }
}

/// Ocupante de un canal de voz según el servidor (voice.state).
class VoiceUser {
  final String userId;
  final bool muted;
  const VoiceUser(this.userId, {this.muted = false});
}

/// Credencial de LiveKit devuelta por voice.join.
class VoiceTicket {
  final String token, url;
  const VoiceTicket(this.token, this.url);
}
