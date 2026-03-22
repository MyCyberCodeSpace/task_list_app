import 'package:task_list_app/features/auth/domain/model/user_model.dart';

typedef GetCurrentUser = UserModel? Function();

typedef SignOut = Future<void> Function();

typedef Login = Future<UserModel?> Function({
  required String email,
  required String password,
});

typedef CreateUser = Future<UserModel?> Function({
  required String email,
  required String password,
});
