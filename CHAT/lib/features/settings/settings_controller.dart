import 'package:flutter/foundation.dart';
import '../../app/app_router.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsController extends ChangeNotifier {
  final SettingsRepository _settings;
  final AuthRepository _auth;
  final AppRouter _router;
  SettingsController(this._settings, this._auth, this._router);

  Future<void> logout() async { await _auth.logout(); _router.go(AppScreen.welcome); }
  Future<void> deleteAccount() async { await _auth.deleteAccount(); _router.go(AppScreen.welcome); }

  String detailKey = 'cuenta';

  bool isOn(String key) => _settings.toggle(key);

  void openDetail(String key) { detailKey = key; _router.go(AppScreen.detail); }
  void openInvite() => _router.go(AppScreen.invite);
  void backToSettings() => _router.go(AppScreen.settings);

  void toggle(String key) => _settings.setToggle(key, !_settings.toggle(key));
}
