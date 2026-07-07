import '../domain/models/user_profile.dart';
import '../domain/repositories/auth_repository.dart';

class InMemoryAuthRepository extends AuthRepository {
  UserProfile _user = const UserProfile();

  @override
  UserProfile get user => _user;

  @override
  Future<void> requestCode(String phone) async {
    _user = _user.copyWith(phone: phone);
    notifyListeners();
  }

  @override
  Future<bool> verifyCode(String code) async => code.length == 6;

  @override
  Future<void> saveName(String name) async {
    _user = _user.copyWith(name: name);
    notifyListeners();
  }
}
