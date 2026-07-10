import 'dart:ui' show PlatformDispatcher;

import 'package:flutter/material.dart';
import '../../core/utils/formatters.dart';
import '../../domain/models/community.dart';
import '../../domain/models/conversation.dart';
import '../../domain/models/message.dart';

/// Mapeo entre el JSON del servidor y los modelos de dominio.

/// ponytail: la capa de datos no tiene BuildContext — tabla propia por idioma;
/// si crece, inyectar el l10n generado a los repos.
class WireStrings {
  final String yesterday, photo, video, docFallback, msgFallback,
      community, online, channel, you, newCommunity;
  final List<String> weekdays; // Lun..Dom
  const WireStrings({
    required this.yesterday,
    required this.weekdays,
    required this.photo,
    required this.video,
    required this.docFallback,
    required this.msgFallback,
    required this.community,
    required this.online,
    required this.channel,
    required this.you,
    required this.newCommunity,
  });
}

const _wire = <String, WireStrings>{
  'es': WireStrings(
    yesterday: 'Ayer',
    weekdays: ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'],
    photo: 'Foto', video: 'Vídeo', docFallback: 'Documento',
    msgFallback: '(mensaje)', community: 'Comunidad', online: 'en línea',
    channel: 'canal', you: 'Tú', newCommunity: 'Nueva comunidad',
  ),
  'en': WireStrings(
    yesterday: 'Yesterday',
    weekdays: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
    photo: 'Photo', video: 'Video', docFallback: 'Document',
    msgFallback: '(message)', community: 'Community', online: 'online',
    channel: 'channel', you: 'You', newCommunity: 'New community',
  ),
  'pt': WireStrings(
    yesterday: 'Ontem',
    weekdays: ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'],
    photo: 'Foto', video: 'Vídeo', docFallback: 'Documento',
    msgFallback: '(mensagem)', community: 'Comunidade', online: 'online',
    channel: 'canal', you: 'Você', newCommunity: 'Nova comunidade',
  ),
  'fr': WireStrings(
    yesterday: 'Hier',
    weekdays: ['Lun', 'Mar', 'Mer', 'Jeu', 'Ven', 'Sam', 'Dim'],
    photo: 'Photo', video: 'Vidéo', docFallback: 'Document',
    msgFallback: '(message)', community: 'Communauté', online: 'en ligne',
    channel: 'canal', you: 'Toi', newCommunity: 'Nouvelle communauté',
  ),
};

/// Fijado en tests para no depender del locale de la máquina.
String? wireLanguageOverride;

WireStrings get wireStrings =>
    _wire[wireLanguageOverride ??
        PlatformDispatcher.instance.locale.languageCode] ??
    _wire['es']!;

Color colorFromHex(String hex) => Color(int.parse(hex.substring(1), radix: 16) | 0xFF000000);

String hexOf(Color c) => '#${(c.toARGB32() & 0xFFFFFF).toRadixString(16).padLeft(6, '0')}';

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
  if (diff == 1) return wireStrings.yesterday;
  if (diff < 7) return wireStrings.weekdays[t.weekday - 1];
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
    _ => Message.text(sender, wireStrings.msgFallback, id: id, time: time),
  };
}

/// Content JSON para msg.send a partir de un mensaje local.
Map<String, dynamic> wireContent(Message m) => switch (m.type) {
      MessageType.text => {'text': m.text ?? ''},
      MessageType.sticker => {'sticker': m.sticker ?? ''},
      MessageType.doc => {'name': m.docName ?? wireStrings.docFallback, 'size': m.docSize ?? ''},
      MessageType.image || MessageType.video => {},
    };

/// Texto corto para la lista de chats.
String previewOf(Map<String, dynamic> m) {
  final c = (m['content'] as Map).cast<String, dynamic>();
  return switch (m['type']) {
    'text' => c['text'] as String? ?? '',
    'sticker' => c['sticker'] as String? ?? '',
    'image' => '📷 ${wireStrings.photo}',
    'video' => '🎬 ${wireStrings.video}',
    'doc' => '📄 ${c['name'] ?? wireStrings.docFallback}',
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
    roles: [
      for (final r in (j['roles'] as List? ?? const []))
        Role(
          id: r['id'] as String,
          name: r['name'] as String,
          color: r['color'] == null ? null : colorFromHex(r['color'] as String),
          position: (r['position'] as int?) ?? 1,
          permissions: BigInt.parse(r['permissions'] as String),
          isEveryone: (r['isEveryone'] as bool?) ?? false,
        ),
    ],
    members: [
      for (final m in (j['members'] as List? ?? const []))
        Member(
          id: m['id'] as String,
          name: (m['displayName'] as String?) ?? formatPhone(m['phone'] as String),
          color: colorFromHex((m['avatarColor'] as String?) ?? '#7C5CFF'),
          roleIds: [for (final id in (m['roleIds'] as List? ?? const [])) id as String],
          online: (m['online'] as bool?) ?? false,
        ),
    ],
  );
}
