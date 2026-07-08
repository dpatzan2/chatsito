/// Llamada de voz activa, desacoplada del SDK para poder fakearla en tests.
abstract class VoiceCall {
  Future<void> setMicEnabled(bool enabled);

  /// userIds (identity de LiveKit) hablando ahora mismo.
  Stream<Set<String>> get speaking;

  Future<void> disconnect();
}

typedef VoiceConnector = Future<VoiceCall> Function(String url, String token);
