import 'package:firebase_auth/firebase_auth.dart';
import 'package:task_list_app/features/auth/domain/model/user_model.dart';
import 'package:task_list_app/features/auth/domain/repository/auth_repository.dart';

class AuthRepositoryImp extends AuthRepository {
  final FirebaseAuth auth;

  AuthRepositoryImp(this.auth);

  @override
  UserModel? getCurrentUser() {
    final user = auth.currentUser;
    if (user == null) return null;
    return UserModel(uid: user.uid, email: user.email ?? '');
  }

  @override
  Future<void> signOut() async {
    auth.signOut();
  }

  @override
  Future<UserModel?> login({
    required String email,
    required String password,
  }) async {
    final userCredentials = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredentials.user;
    if (user == null) return null;
    return UserModel(uid: user.uid, email: user.email ?? '');
  }

  @override
  Future<UserModel?> createUser({
    required String email,
    required String password,
  }) async {
    final userCredentials = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final user = userCredentials.user;
    if (user == null) return null;
    return UserModel(uid: user.uid, email: user.email ?? '');
  }
}
