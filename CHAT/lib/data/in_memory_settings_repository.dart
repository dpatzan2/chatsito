import '../domain/repositories/settings_repository.dart';

class InMemorySettingsRepository extends SettingsRepository {
  final Map<String, bool> _toggles = {
    'readReceipts': true, 'screenLock': false, 'enterToSend': false,
    'saveToRoll': true, 'msgNotif': true, 'groupNotif': true,
    'showPreview': true, 'reactionNotif': false, 'lessData': false, 'contactMute': false,
  };

  @override
  bool toggle(String key) => _toggles[key] ?? false;

  @override
  Future<void> setToggle(String key, bool value) async {
    _toggles[key] = value;
    notifyListeners();
  }
}
