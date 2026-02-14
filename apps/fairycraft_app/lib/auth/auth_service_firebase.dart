import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';

import 'auth_service.dart';

class AuthServiceFirebase implements AuthService {
  AuthServiceFirebase({FirebaseAuth? firebaseAuth}) : _auth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _auth;

  Stream<AuthUser?>? _stream;

  @override
  AuthUser? get currentUser {
    final user = _auth.currentUser;
    if (user == null) {
      return null;
    }
    return AuthUser(uid: user.uid, email: user.email, isAnonymous: user.isAnonymous);
  }

  @override
  Future<void> changePassword(String newPassword) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw StateError('No authenticated user.');
    }
    await user.updatePassword(newPassword);
  }

  @override
  Stream<AuthUser?> authStateChanges() {
    return _stream ??= _auth.authStateChanges().map((user) {
      if (user == null) {
        return null;
      }
      return AuthUser(uid: user.uid, email: user.email, isAnonymous: user.isAnonymous);
    }).asBroadcastStream();
  }

  @override
  Future<String?> getIdToken() async {
    return _auth.currentUser?.getIdToken();
  }

  @override
  Future<void> linkProvider(String providerId) async {
    // Provider linking can be implemented per provider in production.
    return;
  }

  @override
  Future<void> registerWithEmailPassword({required String email, required String password}) async {
    await _auth.createUserWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  @override
  Future<void> signInWithEmailPassword({required String email, required String password}) async {
    await _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  void dispose() {}
}
