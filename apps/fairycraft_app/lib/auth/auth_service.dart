import 'dart:async';

class AuthUser {
  AuthUser({required this.uid, required this.email, this.isAnonymous = false});

  final String uid;
  final String? email;
  final bool isAnonymous;
}

abstract class AuthService {
  AuthUser? get currentUser;

  Stream<AuthUser?> authStateChanges();

  Future<void> signInWithEmailPassword({required String email, required String password});

  Future<void> registerWithEmailPassword({required String email, required String password});

  Future<void> sendPasswordResetEmail(String email);

  Future<void> changePassword(String newPassword);

  Future<void> signOut();

  Future<void> linkProvider(String providerId);

  Future<String?> getIdToken();

  void dispose();
}
