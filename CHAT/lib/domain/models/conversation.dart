import 'package:flutter/material.dart';

class Conversation {
  final String id, name, lastMessage, time, initials;
  final Color color;
  final int unread;
  final bool isGroup;

  const Conversation({
    required this.id,
    required this.name,
    required this.lastMessage,
    required this.time,
    required this.initials,
    required this.color,
    this.unread = 0,
    this.isGroup = false,
  });

  bool get hasUnread => unread > 0;

  Conversation copyWith({String? lastMessage, String? time, int? unread}) => Conversation(
        id: id, name: name, lastMessage: lastMessage ?? this.lastMessage,
        time: time ?? this.time, initials: initials, color: color,
        unread: unread ?? this.unread, isGroup: isGroup,
      );
}
