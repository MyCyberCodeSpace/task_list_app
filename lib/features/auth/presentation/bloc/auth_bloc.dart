import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_list_app/features/auth/domain/repository/auth_repository.dart';
import 'package:task_list_app/features/auth/presentation/bloc/auth_event.dart';
import 'package:task_list_app/features/auth/presentation/bloc/auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository _authRepository;

  AuthBloc(this._authRepository) : super(AuthInitialState()) {
    on<AuthCheckStatusRequestedEvent>((event, emit) {
      final user = _authRepository.getCurrentUser();
      
      if (user != null) {
        emit(AuthAuthenticatedState(user));
      } else {
        emit(AuthUnauthenticatedState());
      }
    });

    on<AuthLoginRequestedEvent>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final userCredential = await _authRepository.login(
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
        final userCredential = await _authRepository.createUser(
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
        await _authRepository.signOut();
        emit(AuthUnauthenticatedState());
      } catch (e) {
        emit(AuthErrorState('Failed in logout account: $e'));
      }
    });
  }
}
