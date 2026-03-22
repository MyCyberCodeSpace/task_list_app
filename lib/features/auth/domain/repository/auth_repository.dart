import 'package:task_list_app/features/auth/domain/model/user_model.dart';

export 'package:task_list_app/features/auth/domain/typedef/auth_typedef.dart';

abstract class AuthRepository {
  UserModel? getCurrentUser();

  Future<void> signOut();

  Future<UserModel?> login({required String email, required String password});

  Future<UserModel?> createUser({required String email, required String password});
}
