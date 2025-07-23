import 'package:firebase_auth/firebase_auth.dart';

class AuthRepository {
  final FirebaseAuth auth;
  AuthRepository(this.auth);

  User? getCurrentUser() {
    return auth.currentUser;
  }

  Future<void> signOut() async {
    auth.signOut();
  }

  Future<User?> login({
    required String email,
    required String password,
  }) async {
    final userCredentials = await auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredentials.user;
  }

  Future<User?> createUser({
    required String email,
    required String password,
  }) async {
    final userCredentials = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return userCredentials.user;
  }
}
