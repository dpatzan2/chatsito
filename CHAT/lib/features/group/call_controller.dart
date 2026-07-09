import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/api/livekit_call.dart';
import '../../data/api/voice_call.dart';
import '../../data/api/wire.dart';
import '../../domain/models/channels.dart';
import '../../domain/models/community.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/chat_repository.dart';

/// Voice-channel state: une el roster del servidor (voice.state) con la
/// llamada real de LiveKit (mic, speaking).
class CallController extends ChangeNotifier {
  final AuthRepository _auth;
  final ChatRepository _chat;
  final AppRouter _router;
  final VoiceConnector _connect;

  CallController(this._auth, this._chat, this._router, {VoiceConnector? connect})
      : _connect = connect ?? LiveKitCall.connect {
    _chat.addListener(notifyListeners); // voice.state / comunidad → repintar
  }

  bool muted = false;
  bool connecting = false;
  String channelName = '';
  String? _channelId;
  VoiceCall? _call;
  Set<String> _speaking = {};
  StreamSubscription<Set<String>>? _speakSub;

  bool get inCall => _call != null;

  VoiceMember _memberOf(VoiceUser u) {
    final self = u.userId == _auth.user.id;
    final m = _chat.activeCommunity?.member(u.userId);
    final name = self ? wireStrings.you : (m?.name ?? '···');
    return VoiceMember(
      name: name,
      initials: self ? _auth.user.youInitials : initialsOf(name),
      color: self ? C.accent : (m?.color ?? C.accent),
      muted: u.muted || (self && muted),
      speaking: _speaking.contains(u.userId),
    );
  }

  /// Ocupantes de un canal de voz (para la lista de canales del grupo).
  List<VoiceMember> membersOf(String channelId) =>
      [for (final u in _chat.voiceStates[channelId] ?? const <VoiceUser>[]) _memberOf(u)];

  /// Participantes de la llamada abierta en la pantalla de voz.
  List<VoiceMember> get callParticipants =>
      _channelId == null ? const [] : membersOf(_channelId!);

  Future<void> openCall(Channel ch) async {
    channelName = ch.name;
    _channelId = ch.id;
    muted = false;
    connecting = true;
    _router.go(AppScreen.voice);
    notifyListeners();
    try {
      final t = await _chat.joinVoice(ch.id);
      _call = await _connect(t.url, t.token);
      _speakSub = _call!.speaking.listen((s) {
        _speaking = s;
        notifyListeners();
      });
    } finally {
      connecting = false;
      notifyListeners();
    }
  }

  Future<void> toggleMute() async {
    muted = !muted;
    notifyListeners();
    await _call?.setMicEnabled(!muted);
  }

  Future<void> leave() async {
    await _speakSub?.cancel();
    _speakSub = null;
    await _call?.disconnect();
    _call = null;
    _speaking = {};
    final id = _channelId;
    _channelId = null;
    _router.go(AppScreen.group);
    notifyListeners();
    if (id != null) await _chat.leaveVoice(id);
  }
}
