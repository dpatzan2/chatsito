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
}
