import 'package:flutter/foundation.dart';
import '../../app/app_router.dart';
import '../../core/utils/formatters.dart';
import '../../domain/repositories/auth_repository.dart';

/// Drives the welcome → phone → otp → profile flow.
class OnboardingController extends ChangeNotifier {
  final AuthRepository _auth;
  final AppRouter _router;
  OnboardingController(this._auth, this._router);

  String phone = '', otp = '', name = '';

  String get phoneFormatted => formatPhone(phone);
  bool get phoneComplete => phone.length >= 9;
  bool get nameValid => name.trim().isNotEmpty;

  void start() => _router.go(AppScreen.phone);
  void back(AppScreen to) => _router.go(to);

  void onDigit(String d) {
    if (_router.screen == AppScreen.phone) {
      if (phone.length < 9) { phone += d; notifyListeners(); }
    } else if (_router.screen == AppScreen.otp) {
      if (otp.length < 6) {
        otp += d;
        notifyListeners();
        if (otp.length == 6) _verify();
      }
    }
  }

  void onBackspace() {
    if (_router.screen == AppScreen.phone && phone.isNotEmpty) {
      phone = phone.substring(0, phone.length - 1);
      notifyListeners();
    } else if (_router.screen == AppScreen.otp && otp.isNotEmpty) {
      otp = otp.substring(0, otp.length - 1);
      notifyListeners();
    }
  }

  Future<void> submitPhone() async {
    if (!phoneComplete) return;
    await _auth.requestCode(phone);
    _router.go(AppScreen.otp);
  }

  Future<void> _verify() async {
    if (!await _auth.verifyCode(otp)) return;
    await Future.delayed(const Duration(milliseconds: 380));
    _router.go(AppScreen.profile);
  }

  void setName(String value) { name = value; notifyListeners(); }

  Future<void> finish() async {
    if (!nameValid) return;
    await _auth.saveName(name);
    _router.go(AppScreen.chats);
  }
}
