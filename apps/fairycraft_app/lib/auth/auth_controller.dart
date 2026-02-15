import 'dart:async';

import 'package:flutter/foundation.dart';

import 'auth_service.dart';

enum AuthStatus { unknown, loading, authenticated, unauthenticated }

class AuthController extends ChangeNotifier {
  AuthController(this._authService);

  final AuthService _authService;

  StreamSubscription<AuthUser?>? _subscription;
  Timer? _initialSessionTimeout;

  AuthStatus _status = AuthStatus.unknown;
  AuthUser? _user;
  String? _lastError;

  AuthStatus get status => _status;
  AuthUser? get user => _user;
  String? get lastError => _lastError;
  bool get isAuthenticated => _status == AuthStatus.authenticated;

  void start() {
    _initialSessionTimeout?.cancel();
    _subscription?.cancel();

    _status = AuthStatus.loading;
    _user = _authService.currentUser;
    _logStage('start', user: _user);
    notifyListeners();

    var hasFirstEvent = false;
    _initialSessionTimeout = Timer(const Duration(seconds: 6), () {
      if (hasFirstEvent) {
        return;
      }

      _logStage('first-auth-event-timeout', user: _authService.currentUser);
      _applyAuthState(_authService.currentUser);
    });

    _subscription = _authService.authStateChanges().listen(
      (user) {
        if (!hasFirstEvent) {
          hasFirstEvent = true;
          _initialSessionTimeout?.cancel();
          _initialSessionTimeout = null;
        }
        _logStage('auth-event', user: user);
        _applyAuthState(user);
      },
      onError: (Object error, StackTrace stackTrace) {
        if (!hasFirstEvent) {
          hasFirstEvent = true;
          _initialSessionTimeout?.cancel();
          _initialSessionTimeout = null;
        }
        _lastError = error.toString();
        _logStage('auth-event-error', error: _lastError);
        _applyAuthState(_authService.currentUser);
      },
      onDone: () {
        _logStage('auth-stream-done');
      },
    );
  }

  void _applyAuthState(AuthUser? user) {
    _user = user;
    _status = user == null
        ? AuthStatus.unauthenticated
        : AuthStatus.authenticated;
    _logStage('state-applied', user: user);
    notifyListeners();
  }

  void _logStage(String stage, {AuthUser? user, String? error}) {
    if (!kDebugMode) {
      return;
    }
    debugPrint(
      '[auth_session] stage=$stage status=$_status uid=${user?.uid ?? '-'} '
      'email=${user?.email ?? '-'} error=${error ?? '-'}',
    );
  }

  Future<void> signIn(String email, String password) async {
    _lastError = null;
    notifyListeners();
    try {
      await _authService.signInWithEmailPassword(
        email: email,
        password: password,
      );
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
      await _authService.registerWithEmailPassword(
        email: email,
        password: password,
      );
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

  Future<void> unlinkProvider(String providerId) async {
    _lastError = null;
    notifyListeners();
    try {
      await _authService.unlinkProvider(providerId);
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
    _initialSessionTimeout?.cancel();
    _subscription?.cancel();
    super.dispose();
  }
}
