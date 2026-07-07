import 'package:flutter/foundation.dart';

enum AppScreen {
  welcome, phone, otp, profile, chats, chat,
  createGroup, group, voice, settings, detail, invite, contactProfile,
}

/// Holds the active screen. Screen-state navigation kept deliberately simple;
/// can be swapped for Navigator 2.0 / go_router without touching features.
class AppRouter extends ChangeNotifier {
  AppScreen _screen = AppScreen.welcome;
  AppScreen get screen => _screen;

  bool get isDark => _screen == AppScreen.group || _screen == AppScreen.voice;

  void go(AppScreen screen) {
    if (_screen == screen) return;
    _screen = screen;
    notifyListeners();
  }
}
