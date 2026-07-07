import 'package:flutter/foundation.dart';

/// Persisted user preferences (boolean toggles keyed by name).
abstract class SettingsRepository extends ChangeNotifier {
  bool toggle(String key);
  Future<void> setToggle(String key, bool value);
}
