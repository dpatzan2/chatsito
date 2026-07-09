import 'package:flutter/foundation.dart';
import '../../app/app_router.dart';
import '../../core/utils/countries.dart';
import '../../core/utils/formatters.dart';
import '../../domain/repositories/auth_repository.dart';

/// Drives the welcome → phone → otp → profile flow.
class OnboardingController extends ChangeNotifier {
  final AuthRepository _auth;
  final AppRouter _router;
  OnboardingController(this._auth, this._router);

  String phone = '', otp = '', name = '';

  /// Preseleccionado por la región del locale del sistema (es_GT → 🇬🇹 +502).
  Country country =
      countryForIso(PlatformDispatcher.instance.locale.countryCode);

  void setCountry(Country c) {
    country = c;
    notifyListeners();
  }

  /// Lo que se registra en el server: prefijo + número, solo dígitos.
  String get fullPhone => '${country.dial}$phone';

  String get phoneFormatted => formatPhone(phone);
  bool get phoneComplete => phone.length >= 8;
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
    await _auth.requestCode(fullPhone);
    _router.go(AppScreen.otp);
  }

  Future<void> _verify() async {
    if (!await _auth.verifyCode(otp)) {
      otp = '';
      notifyListeners();
      return;
    }
    await Future.delayed(const Duration(milliseconds: 380));
    // usuario conocido: ya tiene nombre, directo a los chats
    _router.go(_auth.user.hasName ? AppScreen.chats : AppScreen.profile);
  }

  void setName(String value) { name = value; notifyListeners(); }

  Future<void> finish() async {
    if (!nameValid) return;
    await _auth.saveName(name);
    _router.go(AppScreen.chats);
  }
}
