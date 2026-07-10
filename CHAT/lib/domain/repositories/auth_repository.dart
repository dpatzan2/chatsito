import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

/// Authentication + the signed-in user's profile.
///
/// Async methods are the seam for a real backend: swap the in-memory
/// implementation for an API-backed one without touching the UI.
abstract class AuthRepository extends ChangeNotifier {
  UserProfile get user;

  /// Restaura la sesión persistida. false si no hay o el backend la rechaza.
  Future<bool> restore() async => false;

  /// Send a verification SMS to [phone] (digits only).
  Future<void> requestCode(String phone);

  /// Verify the 6-digit [code]. Returns whether it was accepted.
  Future<bool> verifyCode(String code);

  /// Persist the user's display name.
  Future<void> saveName(String name);

  /// Sube la foto de perfil y la persiste en el backend.
  Future<void> saveAvatar(List<int> bytes, String filename, String mime) async {}

  /// Cierra la sesión en el servidor y limpia el estado local.
  Future<void> logout() async {}

  /// Borra la cuenta en el servidor y limpia el estado local.
  Future<void> deleteAccount() async {}
}
