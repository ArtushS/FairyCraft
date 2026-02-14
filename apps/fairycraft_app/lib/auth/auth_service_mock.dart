import 'dart:async';
import 'dart:math';

import 'auth_service.dart';

class AuthServiceMock implements AuthService {
  AuthServiceMock() {
    _controller.add(null);
  }

  final StreamController<AuthUser?> _controller = StreamController<AuthUser?>.broadcast();
  AuthUser? _current;

  @override
  AuthUser? get currentUser => _current;

  @override
  Stream<AuthUser?> authStateChanges() => _controller.stream;

  @override
  Future<void> changePassword(String newPassword) async {
    if (_current == null) {
      throw StateError('No authenticated user.');
    }
  }

  @override
  Future<String?> getIdToken() async => null;

  @override
  Future<void> linkProvider(String providerId) async {}

  @override
  Future<void> registerWithEmailPassword({required String email, required String password}) async {
    final uid = 'mock_${email.hashCode.abs()}_${Random().nextInt(9999)}';
    _current = AuthUser(uid: uid, email: email);
    _controller.add(_current);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signInWithEmailPassword({required String email, required String password}) async {
    final uid = 'mock_${email.hashCode.abs()}';
    _current = AuthUser(uid: uid, email: email);
    _controller.add(_current);
  }

  @override
  Future<void> signOut() async {
    _current = null;
    _controller.add(null);
  }

  @override
  void dispose() {
    _controller.close();
  }
}
