import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_list_app/features/auth/bloc/auth_event.dart';
import 'package:task_list_app/features/auth/bloc/auth_state.dart';
import 'package:task_list_app/features/auth/repository/auth_repository.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final FirebaseAuth _firebaseAuth;

  AuthBloc(this._firebaseAuth) : super(AuthInitialState()) {
    on<AuthCheckStatusRequestedEvent>((event, emit) {
      final authRepository = AuthRepository(_firebaseAuth);
      final user = authRepository.getCurrentUser();
      
      if (user != null) {
        emit(AuthAuthenticatedState(user));
      } else {
        emit(AuthUnauthenticatedState());
      }
    });

    on<AuthLoginRequestedEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final authRepository = AuthRepository(_firebaseAuth);
        final userCredential = await authRepository.login(
          email: event.email,
          password: event.password,
        );
        emit(AuthAuthenticatedState(userCredential));
      } catch (erro) {
        emit(AuthErrorState('Failed to login: $erro'));
        emit(AuthUnauthenticatedState());
      }
    });

    on<AuthCreateAccountEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final authRepository = AuthRepository(_firebaseAuth);
        final userCredential = await authRepository.createUser(
          email: event.email,
          password: event.password,
        );
        emit(AuthAuthenticatedState(userCredential));
      } catch (e) {
        emit(AuthErrorState('Failed in created account: $e'));
        emit(AuthUnauthenticatedState());
      }
    });

    on<AuthLogoutRequestedEvent>((event, emit) async {
      try {
        final authRepository = AuthRepository(_firebaseAuth);
        await authRepository.signOut();
        emit(AuthUnauthenticatedState());
      } catch (e) {
        emit(AuthErrorState('Failed in logout account: $e'));
      }
    });
  }
}
