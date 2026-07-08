import '../domain/models/user_profile.dart';
import '../domain/repositories/auth_repository.dart';
import 'api/api_client.dart';

class ApiAuthRepository extends AuthRepository {
  final ApiClient _api;
  UserProfile _user = const UserProfile();

  ApiAuthRepository(this._api);

  @override
  UserProfile get user => _user;

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
      _api.access = r['access'] as String;
      _api.refresh = r['refresh'] as String;
      final u = (r['user'] as Map).cast<String, dynamic>();
      _user = UserProfile(
        id: u['id'] as String,
        name: (u['displayName'] as String?) ?? '',
        phone: u['phone'] as String,
      );
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
}
