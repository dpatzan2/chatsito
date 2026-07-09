// Smoke end-to-end contra el backend real usando los clientes de la app.
// Uso: dart run tool/smoke.dart <ruta-al-log-del-server>
// Requiere: docker compose up -d + npm run dev en server/ (OTP dev en el log).
import 'dart:io';

import 'package:chatsito/data/api/api_client.dart';
import 'package:chatsito/data/api/ws_client.dart';

late final String logPath;

Future<String> otpFor(ApiClient api, String phone) async {
  await api.send('POST', '/auth/otp', body: {'phone': phone});
  await Future.delayed(const Duration(milliseconds: 300));
  final log = await File(logPath).readAsString();
  final re = RegExp('\\[DEV SMS\\] to \\+$phone: Tu código de Chatsito es (\\d{6})');
  final m = re.allMatches(log).last;
  return m.group(1)!;
}

Future<(ApiClient, WsClient, String)> login(String phone, String name) async {
  final api = ApiClient('http://localhost:3000');
  final code = await otpFor(api, phone);
  final r = await api.send('POST', '/auth/verify', body: {'phone': phone, 'code': code}) as Map;
  api.access = r['access'] as String;
  api.refresh = r['refresh'] as String;
  await api.send('PATCH', '/me', body: {'displayName': name});
  final ws = WsClient('ws://localhost:3000', () => api.access ?? '');
  await ws.connect();
  return (api, ws, (r['user'] as Map)['id'] as String);
}

Future<void> main(List<String> args) async {
  logPath = args.first;
  var checks = 0;
  void ok(String what) => stdout.writeln('  ✔ ${++checks}. $what');

  final (apiA, wsA, idA) = await login('50211111111', 'Ana Smoke');
  final (apiB, wsB, idB) = await login('50222222222', 'Beto Smoke');
  ok('OTP + verify + PATCH /me para dos usuarios');

  // 1:1 por lookup
  final found = await apiA.send('GET', '/users/lookup', query: {'phone': '50222222222'}) as Map;
  if (found['id'] != idB) throw 'lookup devolvió otro usuario';
  final conv = await apiA.send('POST', '/conversations', body: {'userId': idB}) as Map;
  ok('lookup por teléfono + crear conversación');

  final gotDm = wsB.events.firstWhere((e) => e.op == 'msg.new').timeout(const Duration(seconds: 5));
  await wsA.request('msg.send', {
    'conversationId': conv['id'], 'type': 'text', 'content': {'text': 'hola desde el smoke'},
  });
  final dm = await gotDm;
  if (dm.d['content']['text'] != 'hola desde el smoke') throw 'msg.new no llegó bien';
  ok('mensaje 1:1 por WS llega al otro usuario');

  // comunidad + invitación + canal
  final comm = await apiA.send('POST', '/communities', body: {'name': 'Smoke Team'}) as Map;
  final invite = await apiA.send('POST', '/communities/${comm['id']}/invites') as Map;
  final joined = await apiB.send('POST', '/invites/${invite['code']}/join') as Map;
  if (joined['id'] != comm['id']) throw 'join por código falló';
  ok('crear comunidad + unirse por código');

  final general = (comm['channels'] as List).first as Map;
  final gotCh = wsB.events.firstWhere((e) => e.op == 'msg.new' && e.d['channelId'] == general['id'])
      .timeout(const Duration(seconds: 5));
  await wsA.request('msg.send', {
    'channelId': general['id'], 'type': 'text', 'content': {'text': 'hola canal'},
  });
  final chMsg = await gotCh;
  ok('mensaje de canal llega a los miembros');

  // unread de canal + read.mark
  final commsB = await apiB.send('GET', '/communities') as List;
  if (((commsB.first as Map)['unread'] as int) < 1) throw 'GET /communities sin unread';
  Map chOf(Map det) =>
      (det['channels'] as List).firstWhere((c) => c['id'] == general['id']) as Map;
  final detB = await apiB.send('GET', '/communities/${comm['id']}') as Map;
  if ((chOf(detB)['unread'] as int) < 1) throw 'canal sin unread';
  await wsB.request('read.mark', {'channelId': general['id'], 'messageId': chMsg.d['id']});
  final det2 = await apiB.send('GET', '/communities/${comm['id']}') as Map;
  if ((chOf(det2)['unread'] as int) != 0) throw 'read.mark de canal no limpió';
  ok('unread de canal y read.mark');

  // canal de voz + token LiveKit
  final voiceCh = await apiA.send('POST', '/communities/${comm['id']}/channels',
      body: {'name': 'Sala smoke', 'type': 'voice'}) as Map;
  final ready = wsA.events.firstWhere((e) => e.op == 'voice.ready').timeout(const Duration(seconds: 5));
  await wsA.request('voice.join', {'channelId': voiceCh['id']});
  final v = (await ready).d;
  if ((v['token'] as String).isEmpty || !(v['url'] as String).startsWith('ws')) {
    throw 'voice.ready sin token/url';
  }
  ok('voice.join devuelve token LiveKit y URL (${v['url']})');

  await wsA.close();
  await wsB.close();
  stdout.writeln('SMOKE OK — $checks pasos verdes (usuarios $idA / $idB)');
  exit(0);
}
