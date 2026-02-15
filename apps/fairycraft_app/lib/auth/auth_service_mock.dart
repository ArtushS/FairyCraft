import 'dart:async';
import 'dart:math';

import 'auth_service.dart';

class AuthServiceMock implements AuthService {
  AuthServiceMock();

  final StreamController<AuthUser?> _controller =
      StreamController<AuthUser?>.broadcast();
  AuthUser? _current;

  @override
  AuthUser? get currentUser => _current;

  @override
  Stream<AuthUser?> authStateChanges() async* {
    // Always emit current state first for session gates that wait on first event.
    yield _current;
    yield* _controller.stream;
  }

  @override
  Future<void> changePassword(String newPassword) async {
    if (_current == null) {
      throw StateError('No authenticated user.');
    }
  }

  @override
  Future<String?> getIdToken() async => null;

  @override
  Future<void> linkProvider(String providerId) async {
    final current = _current;
    if (current == null) {
      return;
    }
    final next = current.providerIds.toSet()..add(providerId);
    _current = AuthUser(
      uid: current.uid,
      email: current.email,
      isAnonymous: current.isAnonymous,
      providerIds: next.toList()..sort(),
    );
    _controller.add(_current);
  }

  @override
  Future<void> unlinkProvider(String providerId) async {
    final current = _current;
    if (current == null) {
      return;
    }
    final next = current.providerIds.where((id) => id != providerId).toList();
    _current = AuthUser(
      uid: current.uid,
      email: current.email,
      isAnonymous: current.isAnonymous,
      providerIds: next,
    );
    _controller.add(_current);
  }

  @override
  Future<void> registerWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final uid = 'mock_${email.hashCode.abs()}_${Random().nextInt(9999)}';
    _current = AuthUser(
      uid: uid,
      email: email,
      providerIds: const <String>['password'],
    );
    _controller.add(_current);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {}

  @override
  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    final uid = 'mock_${email.hashCode.abs()}';
    _current = AuthUser(
      uid: uid,
      email: email,
      providerIds: const <String>['password'],
    );
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
