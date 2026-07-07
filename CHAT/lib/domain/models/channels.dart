import 'package:flutter/material.dart';

class VoiceMember {
  final String name, initials;
  final Color color;
  final bool speaking, muted;
  const VoiceMember({
    required this.name,
    required this.initials,
    required this.color,
    this.speaking = false,
    this.muted = false,
  });

  VoiceMember copyWith({bool? speaking, bool? muted}) => VoiceMember(
        name: name, initials: initials, color: color,
        speaking: speaking ?? this.speaking, muted: muted ?? this.muted,
      );
}

class TextChannel {
  final String name;
  final int badge;
  final bool active;
  const TextChannel(this.name, {this.badge = 0, this.active = false});
  bool get hasBadge => badge > 0;
}

class VoiceChannel {
  final String name;
  final List<VoiceMember> members;
  const VoiceChannel(this.name, this.members);
  bool get isEmpty => members.isEmpty;
}
