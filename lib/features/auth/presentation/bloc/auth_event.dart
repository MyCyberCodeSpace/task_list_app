abstract class AuthEvent {}

class AuthCheckStatusRequestedEvent extends AuthEvent {}

class AuthLoginRequestedEvent extends AuthEvent {
  final String email;
  final String password;
  AuthLoginRequestedEvent(this.email, this.password);
}

class AuthCreateAccountEvent extends AuthEvent {
  final String email;
  final String password;
  AuthCreateAccountEvent(this.email, this.password);
}

class AuthLogoutRequestedEvent extends AuthEvent {}
