import 'package:chatsito/data/api/wire.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  setUpAll(() => wireLanguageOverride = 'es'); // no depender del locale de la máquina

  test('formatTime: hoy, ayer, día de semana, fecha', () {
    final now = DateTime(2026, 7, 7, 10, 0); // martes
    expect(formatTime(DateTime(2026, 7, 7, 9, 5), now: now), '9:05');
    expect(formatTime(DateTime(2026, 7, 6, 22, 0), now: now), 'Ayer');
    expect(formatTime(DateTime(2026, 7, 3, 8, 0), now: now), 'Vie');
    expect(formatTime(DateTime(2026, 5, 1), now: now), '1/5');
  });

  test('initialsOf takes first letters of two words', () {
    expect(initialsOf('Laura Méndez'), 'LM');
    expect(initialsOf('ana'), 'A');
    expect(initialsOf(''), '?');
  });

  test('messageFromWire maps author and content', () {
    final m = messageFromWire({
      'id': '01A', 'authorId': 'u1', 'type': 'text',
      'content': {'text': 'hola'},
      'createdAt': DateTime.now().millisecondsSinceEpoch,
    }, 'u1');
    expect(m.id, '01A');
    expect(m.isMine, true);
    expect(m.text, 'hola');
  });

  test('conversationFromWire maps other user and unread', () {
    final c = conversationFromWire({
      'id': 'c1',
      'other': {'id': 'u2', 'phone': '600111222', 'displayName': 'Ana', 'avatarColor': '#457B9D'},
      'lastMessage': {
        'id': '01B', 'authorId': 'u2', 'type': 'text', 'content': {'text': 'hey'},
        'createdAt': DateTime.now().millisecondsSinceEpoch,
      },
      'unread': 2,
    }, 'u1');
    expect(c.name, 'Ana');
    expect(c.initials, 'A');
    expect(c.lastMessage, 'hey');
    expect(c.unread, 2);
  });

  test('communityFromWire maps channels and members', () {
    final k = communityFromWire({
      'id': 'g1', 'name': 'Equipo', 'ownerId': 'u1',
      'channels': [
        {'id': 'ch1', 'communityId': 'g1', 'name': 'general', 'type': 'text', 'position': 0},
        {'id': 'ch2', 'communityId': 'g1', 'name': 'Sala', 'type': 'voice', 'position': 1},
      ],
      'members': [
        {'id': 'u1', 'phone': '6', 'displayName': 'Ana', 'avatarColor': '#457B9D', 'roleIds': []},
      ],
    });
    expect(k.textChannels.single.name, 'general');
    expect(k.voiceChannels.single.isVoice, true);
    expect(k.member('u1')!.name, 'Ana');
  });

  test('communityFromWire mapea online', () {
    final c = communityFromWire({
      'id': 'c1', 'name': 'X', 'ownerId': 'u1',
      'members': [
        {'id': 'u1', 'phone': '50211111111', 'online': true},
        {'id': 'u2', 'phone': '50222222222'},
      ],
    });
    expect(c.members[0].online, true);
    expect(c.members[1].online, false);
  });
}
