import 'package:flutter/foundation.dart';
import '../models/user_profile.dart';

/// Authentication + the signed-in user's profile.
///
/// Async methods are the seam for a real backend: swap the in-memory
/// implementation for an API-backed one without touching the UI.
abstract class AuthRepository extends ChangeNotifier {
  UserProfile get user;

  /// Send a verification SMS to [phone] (digits only).
  Future<void> requestCode(String phone);

  /// Verify the 6-digit [code]. Returns whether it was accepted.
  Future<bool> verifyCode(String code);

  /// Persist the user's display name.
  Future<void> saveName(String name);
}
