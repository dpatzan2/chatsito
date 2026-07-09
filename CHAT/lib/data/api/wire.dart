import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/community.dart';
import '../../domain/models/conversation.dart';
import '../../domain/models/message.dart';

/// Mapeo entre el JSON del servidor y los modelos de dominio.

Color colorFromHex(String hex) => Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);

String initialsOf(String name) {
  final words = name.trim().split(RegExp(r'\s+')).where((w) => w.isNotEmpty);
  if (words.isEmpty) return '?';
  return words.map((w) => w[0]).take(2).join().toUpperCase();
}

/// "9:41" hoy, "Ayer", día de semana esta semana, "d/M" más allá.
String formatTime(DateTime t, {DateTime? now}) {
  now ??= DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final day = DateTime(t.year, t.month, t.day);
  final diff = today.difference(day).inDays;
  if (diff <= 0) return '${t.hour}:${t.minute.toString().padLeft(2, '0')}';
  if (diff == 1) return 'Ayer';
  if (diff < 7) return const ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'][t.weekday - 1];
  return '${t.day}/${t.month}';
}

Message messageFromWire(Map<String, dynamic> m, String myUserId) {
  final sender = m['authorId'] == myUserId ? Sender.me : Sender.them;
  final id = m['id'] as String;
  final time = formatTime(DateTime.fromMillisecondsSinceEpoch(m['createdAt'] as int));
  final c = (m['content'] as Map).cast<String, dynamic>();
  return switch (m['type'] as String) {
    'text' => Message.text(sender, c['text'] as String? ?? '', id: id, time: time),
    'sticker' => Message.sticker(sender, c['sticker'] as String? ?? '', id: id, time: time),
    'image' => Message.image(sender, id: id, time: time),
    'video' => Message.video(sender, id: id, time: time),
    'doc' => Message.doc(sender,
        docName: c['name'] as String?, docSize: c['size'] as String?, id: id, time: time),
    _ => Message.text(sender, '(mensaje)', id: id, time: time),
  };
}

/// Content JSON para msg.send a partir de un mensaje local.
Map<String, dynamic> wireContent(Message m) => switch (m.type) {
      MessageType.text => {'text': m.text ?? ''},
      MessageType.sticker => {'sticker': m.sticker ?? ''},
      MessageType.doc => {'name': m.docName ?? 'documento', 'size': m.docSize ?? ''},
      MessageType.image || MessageType.video => {},
    };

/// Texto corto para la lista de chats.
String previewOf(Map<String, dynamic> m) {
  final c = (m['content'] as Map).cast<String, dynamic>();
  return switch (m['type']) {
    'text' => c['text'] as String? ?? '',
    'sticker' => c['sticker'] as String? ?? '',
    'image' => '📷 Foto',
    'video' => '🎬 Vídeo',
    'doc' => '📄 ${c['name'] ?? 'Documento'}',
    _ => '',
  };
}

Conversation conversationFromWire(Map<String, dynamic> c, String myUserId) {
  final other = (c['other'] as Map).cast<String, dynamic>();
  final lastRaw = c['lastMessage'];
  final last = lastRaw == null ? null : (lastRaw as Map).cast<String, dynamic>();
  final name = (other['displayName'] as String?) ?? formatPhone(other['phone'] as String);
  return Conversation(
    id: c['id'] as String,
    name: name,
    lastMessage: last == null ? '' : previewOf(last),
    time: last == null
        ? ''
        : formatTime(DateTime.fromMillisecondsSinceEpoch(last['createdAt'] as int)),
    initials: initialsOf(name),
    color: colorFromHex((other['avatarColor'] as String?) ?? '#7C5CFF'),
    unread: (c['unread'] as int?) ?? 0,
  );
}

Community communityFromWire(Map<String, dynamic> j) {
  return Community(
    id: j['id'] as String,
    name: j['name'] as String,
    ownerId: (j['ownerId'] as String?) ?? '',
    channels: [
      for (final ch in (j['channels'] as List? ?? const []))
        Channel(
          id: ch['id'] as String,
          communityId: ch['communityId'] as String,
          name: ch['name'] as String,
          type: ch['type'] as String,
          unread: (ch['unread'] as int?) ?? 0,
        ),
    ],
    members: [
      for (final m in (j['members'] as List? ?? const []))
        Member(
          id: m['id'] as String,
          name: (m['displayName'] as String?) ?? formatPhone(m['phone'] as String),
          color: colorFromHex((m['avatarColor'] as String?) ?? '#7C5CFF'),
        ),
    ],
  );
}
