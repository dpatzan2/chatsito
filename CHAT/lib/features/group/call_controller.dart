import 'package:flutter/foundation.dart';
import '../../app/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../data/seed_data.dart';
import '../../domain/models/channels.dart';
import '../../domain/repositories/auth_repository.dart';

/// Voice-channel state. Composes the live participant lists from seed data
/// plus the signed-in user.
class CallController extends ChangeNotifier {
  final AuthRepository _auth;
  final AppRouter _router;
  CallController(this._auth, this._router);

  bool muted = false;
  String channelName = 'Sala general';

  VoiceMember get _you => VoiceMember(
        name: 'Tú', initials: _auth.user.youInitials, color: C.accent,
        speaking: !muted, muted: muted,
      );

  List<VoiceMember> get callParticipants => [...SeedData.voiceCallOthers, _you];

  List<VoiceChannel> get groupVoiceChannels => [
        VoiceChannel('Sala general', [
          ...SeedData.salaGeneralOthers,
          VoiceMember(name: 'Tú', initials: _auth.user.youInitials, color: C.accent),
        ]),
        const VoiceChannel('Reunión diaria', []),
      ];

  void openCall(String name) { channelName = name; _router.go(AppScreen.voice); }
  void toggleMute() { muted = !muted; notifyListeners(); }
  void leave() => _router.go(AppScreen.group);
}
