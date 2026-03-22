import 'package:task_list_app/features/auth/domain/model/user_model.dart';

abstract class AuthState {}

class AuthInitialState extends AuthState {}

class AuthLoadingState extends AuthState {}

class AuthAuthenticatedState extends AuthState {
  final UserModel? user;
  AuthAuthenticatedState(this.user);
}

class AuthUnauthenticatedState extends AuthState {}

class AuthErrorState extends AuthState {
  final String erroMessage;
  AuthErrorState(this.erroMessage);
}
