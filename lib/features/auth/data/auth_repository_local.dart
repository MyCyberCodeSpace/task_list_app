import 'package:task_list_app/features/auth/domain/model/user_model.dart';
import 'package:task_list_app/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryLocal extends AuthRepository {
  static const _testEmail = 'test@test.com';
  static const _testPassword = '123456';

  bool _isLoggedIn = false;

  @override
  UserModel? getCurrentUser() {
    return _isLoggedIn
        ? UserModel(uid: 'local-user', email: _testEmail)
        : null;
  }

  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300));
    _isLoggedIn = false;
  }

  @override
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (email == _testEmail && password == _testPassword) {
      _isLoggedIn = true;
      return UserModel(uid: 'local-user', email: email);
    }
    throw Exception(
      'Invalid credentials. Use $_testEmail / $_testPassword',
    );
  }

  @override
  Future<UserModel?> createUser({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    _isLoggedIn = true;
    return UserModel(uid: 'local-user', email: email);
  }
}
