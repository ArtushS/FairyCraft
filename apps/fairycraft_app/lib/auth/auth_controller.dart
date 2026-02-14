import 'dart:async';

import 'package:flutter/foundation.dart';

import 'auth_service.dart';

enum AuthStatus {
  unknown,
  loading,
  authenticated,
  unauthenticated,
}

class AuthController extends ChangeNotifier {
  AuthController(this._authService);

  final AuthService _authService;

  StreamSubscription<AuthUser?>? _subscription;

  AuthStatus _status = AuthStatus.unknown;
  AuthUser? _user;
  String? _lastError;

  AuthStatus get status => _status;
  AuthUser? get user => _user;
  String? get lastError => _lastError;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  void start() {
    _status = AuthStatus.loading;
    _user = _authService.currentUser;
    notifyListeners();

    _subscription?.cancel();
    _subscription = _authService.authStateChanges().listen((user) {
      _user = user;
      _status = user == null ? AuthStatus.unauthenticated : AuthStatus.authenticated;
      notifyListeners();
    });
  }

  Future<void> signIn(String email, String password) async {
    _lastError = null;
    notifyListeners();
    try {
      await _authService.signInWithEmailPassword(email: email, password: password);
    } catch (error) {
      _lastError = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> register(String email, String password) async {
    _lastError = null;
    notifyListeners();
    try {
      await _authService.registerWithEmailPassword(email: email, password: password);
    } catch (error) {
      _lastError = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    _lastError = null;
    notifyListeners();
    try {
      await _authService.sendPasswordResetEmail(email);
    } catch (error) {
      _lastError = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> changePassword(String newPassword) async {
    _lastError = null;
    notifyListeners();
    try {
      await _authService.changePassword(newPassword);
    } catch (error) {
      _lastError = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> linkProvider(String providerId) async {
    _lastError = null;
    notifyListeners();
    try {
      await _authService.linkProvider(providerId);
    } catch (error) {
      _lastError = error.toString();
      notifyListeners();
      rethrow;
    }
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
