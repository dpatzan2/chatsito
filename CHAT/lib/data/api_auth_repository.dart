import 'package:shared_preferences/shared_preferences.dart';

import '../domain/models/user_profile.dart';
import '../domain/repositories/auth_repository.dart';
import 'api/api_client.dart';

class ApiAuthRepository extends AuthRepository {
  static const _kAccess = 'access', _kRefresh = 'refresh';

  final ApiClient _api;
  UserProfile _user = const UserProfile();

  ApiAuthRepository(this._api) {
    _api.onTokens = (a, r) => SharedPreferences.getInstance().then((p) {
          if (r == null) {
            p.remove(_kAccess);
            p.remove(_kRefresh);
          } else {
            p.setString(_kAccess, a ?? '');
            p.setString(_kRefresh, r);
          }
        });
  }

  @override
  UserProfile get user => _user;

  @override
  Future<bool> restore() async {
    final p = await SharedPreferences.getInstance();
    final refresh = p.getString(_kRefresh);
    if (refresh == null || refresh.isEmpty) return false;
    _api.access = p.getString(_kAccess);
    _api.refresh = refresh;
    try {
      final u = (await _api.send('GET', '/me') as Map).cast<String, dynamic>();
      _user = _profileFromWire(u);
      notifyListeners();
      return true;
    } catch (_) {
      // ponytail: backend caído o refresh caducado → onboarding normal
      return false;
    }
  }

  @override
  Future<void> requestCode(String phone) async {
    await _api.send('POST', '/auth/otp', body: {'phone': phone});
    _user = _user.copyWith(phone: phone);
    notifyListeners();
  }

  @override
  Future<bool> verifyCode(String code) async {
    try {
      final r = await _api.send('POST', '/auth/verify',
          body: {'phone': _user.phone, 'code': code}) as Map;
      _api.setTokens(r['access'] as String, r['refresh'] as String);
      final u = (r['user'] as Map).cast<String, dynamic>();
      _user = _profileFromWire(u);
      notifyListeners();
      return true;
    } on ApiException {
      return false;
    }
  }

  @override
  Future<void> saveName(String name) async {
    await _api.send('PATCH', '/me', body: {'displayName': name.trim()});
    _user = _user.copyWith(name: name);
    notifyListeners();
  }

  @override
  Future<void> saveAvatar(List<int> bytes, String filename, String mime) async {
    final up = await _api.upload(bytes, filename, mime);
    await _api.send('PATCH', '/me', body: {'avatarUrl': up['url']});
    _user = _user.copyWith(avatarUrl: '${_api.baseUrl}${up['url']}');
    notifyListeners();
  }

  @override
  Future<void> logout() async {
    try {
      await _api.send('POST', '/auth/logout', body: {'refresh': _api.refresh});
    } catch (_) {
      // best-effort: lo local se limpia igual
    }
    _clearSession();
  }

  @override
  Future<void> deleteAccount() async {
    await _api.send('DELETE', '/me');
    _clearSession();
  }

  void _clearSession() {
    _api.setTokens(null, null);
    _user = const UserProfile();
    notifyListeners();
  }

  UserProfile _profileFromWire(Map<String, dynamic> u) => UserProfile(
        id: u['id'] as String,
        name: (u['displayName'] as String?) ?? '',
        phone: u['phone'] as String,
        avatarUrl: u['avatarUrl'] == null ? null : '${_api.baseUrl}${u['avatarUrl']}',
      );
}
