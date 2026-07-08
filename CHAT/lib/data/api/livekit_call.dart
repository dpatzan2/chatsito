import 'dart:async';
import 'package:livekit_client/livekit_client.dart';
import 'voice_call.dart';

/// VoiceCall real sobre livekit_client (audio SFU).
class LiveKitCall implements VoiceCall {
  final Room _room;
  final EventsListener<RoomEvent> _listener;
  final _speaking = StreamController<Set<String>>.broadcast();

  LiveKitCall._(this._room) : _listener = _room.createListener() {
    _listener.on<ActiveSpeakersChangedEvent>((e) {
      _speaking.add({for (final p in e.speakers) p.identity});
    });
  }

  static Future<VoiceCall> connect(String url, String token) async {
    final room = Room();
    await room.connect(url, token);
    await room.localParticipant?.setMicrophoneEnabled(true);
    return LiveKitCall._(room);
  }

  @override
  Future<void> setMicEnabled(bool enabled) async {
    await _room.localParticipant?.setMicrophoneEnabled(enabled);
  }

  @override
  Stream<Set<String>> get speaking => _speaking.stream;

  @override
  Future<void> disconnect() async {
    await _listener.dispose();
    await _room.disconnect();
    await _speaking.close();
  }
}
