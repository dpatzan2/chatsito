import 'package:flutter/material.dart';

/// The conversation currently open in the chat screen (1:1 or a channel).
class ChatTarget {
  final String title, initials, subtitle;
  final Color color;
  const ChatTarget({
    required this.title,
    required this.initials,
    required this.subtitle,
    required this.color,
  });
}
