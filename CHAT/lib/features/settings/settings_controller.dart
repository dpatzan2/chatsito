import 'package:flutter/foundation.dart';
import '../../app/app_router.dart';
import '../../domain/repositories/settings_repository.dart';

class SettingsController extends ChangeNotifier {
  final SettingsRepository _settings;
  final AppRouter _router;
  SettingsController(this._settings, this._router);

  String detailKey = 'cuenta';

  bool isOn(String key) => _settings.toggle(key);

  void openDetail(String key) { detailKey = key; _router.go(AppScreen.detail); }
  void openInvite() => _router.go(AppScreen.invite);
  void backToSettings() => _router.go(AppScreen.settings);

  void toggle(String key) => _settings.setToggle(key, !_settings.toggle(key));
}
