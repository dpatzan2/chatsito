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

class Member {
  final String id, name;
  final Color color;
  const Member({required this.id, required this.name, required this.color});
}

class Community {
  final String id, name, ownerId;
  final List<Channel> channels;
  final List<Member> members;
  const Community({
    required this.id,
    required this.name,
    required this.ownerId,
    required this.channels,
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
