import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

import '../config/app_environment.dart';
import 'local_admin_uid_loader.dart';

enum AdminAccessState { initializing, unauthenticated, unauthorized, authorized }

class AdminAuthController extends ChangeNotifier {
  AdminAuthController({
    required this.environment,
    required this.mockMode,
    required this.bootstrapError,
    FirebaseAuth? firebaseAuth,
    LocalAdminUidLoader? localUidLoader,
  })  : _firebaseAuth = firebaseAuth,
        _localUidLoader = localUidLoader ?? LocalAdminUidLoader();

  final AppEnvironment environment;
  final bool mockMode;
  final String? bootstrapError;
  final FirebaseAuth? _firebaseAuth;
  final LocalAdminUidLoader _localUidLoader;

  StreamSubscription<User?>? _authSubscription;
  User? _firebaseUser;
  bool _mockSignedIn = false;
  bool _isCheckingClaims = true;
  bool _isAdmin = false;
  String? _mockEmail;
  String? _errorMessage;
  Set<String> _localAdminUids = <String>{};

  bool get isAuthenticated => mockMode ? _mockSignedIn : _firebaseUser != null;
  bool get isAdmin => mockMode ? _mockSignedIn : _isAdmin;
  bool get isCheckingClaims => _isCheckingClaims;
  String? get errorMessage => _errorMessage;
  String? get currentUid => mockMode ? (_mockSignedIn ? 'mock_admin' : null) : _firebaseUser?.uid;
  String? get currentEmail => mockMode ? _mockEmail : _firebaseUser?.email;

  AdminAccessState get accessState {
    if (_isCheckingClaims) {
      return AdminAccessState.initializing;
    }
    if (!isAuthenticated) {
      return AdminAccessState.unauthenticated;
    }
    return isAdmin ? AdminAccessState.authorized : AdminAccessState.unauthorized;
  }

  Future<void> init() async {
    _isCheckingClaims = true;
    _errorMessage = null;

    if (environment.allowLocalAdminUidOverrides) {
      _localAdminUids = await _localUidLoader.load();
    }

    if (mockMode) {
      _isCheckingClaims = false;
      notifyListeners();
      return;
    }

    if (_firebaseAuth == null) {
      _isCheckingClaims = false;
      _errorMessage = 'Firebase Auth is not available in current mode.';
      notifyListeners();
      return;
    }

    _firebaseUser = _firebaseAuth.currentUser;
    await _refreshClaims();

    _authSubscription = _firebaseAuth.authStateChanges().listen((user) async {
      _firebaseUser = user;
      await _refreshClaims();
    });
  }

  Future<void> _refreshClaims() async {
    if (mockMode) {
      _isCheckingClaims = false;
      notifyListeners();
      return;
    }

    final user = _firebaseUser;
    if (user == null) {
      _isAdmin = false;
      _isCheckingClaims = false;
      notifyListeners();
      return;
    }

    _isCheckingClaims = true;
    notifyListeners();

    try {
      final tokenResult = await user.getIdTokenResult(true);
      final claimedAdmin = tokenResult.claims?['admin'] == true;
      final localOverride = environment.allowLocalAdminUidOverrides &&
          _localAdminUids.contains(user.uid);
      _isAdmin = claimedAdmin || localOverride;
    } catch (error) {
      _isAdmin = false;
      _errorMessage = error.toString();
    } finally {
      _isCheckingClaims = false;
      notifyListeners();
    }
  }

  Future<void> signInWithGoogle() async {
    _errorMessage = null;
    notifyListeners();

    if (mockMode) {
      _mockSignedIn = true;
      _mockEmail = 'mock-admin@fairycraft.local';
      notifyListeners();
      return;
    }

    if (_firebaseAuth == null) {
      _errorMessage = 'Firebase Auth is unavailable.';
      notifyListeners();
      return;
    }

    try {
      if (!kIsWeb) {
        throw UnsupportedError('Google popup sign-in is currently configured for web only.');
      }
      final provider = GoogleAuthProvider();
      await _firebaseAuth.signInWithPopup(provider);
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> signInWithEmailPassword({
    required String email,
    required String password,
  }) async {
    _errorMessage = null;
    notifyListeners();

    if (mockMode) {
      _mockSignedIn = true;
      _mockEmail = email;
      notifyListeners();
      return;
    }

    if (_firebaseAuth == null) {
      _errorMessage = 'Firebase Auth is unavailable.';
      notifyListeners();
      return;
    }

    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<void> signOut() async {
    _errorMessage = null;
    if (mockMode) {
      _mockSignedIn = false;
      _mockEmail = null;
      notifyListeners();
      return;
    }

    try {
      await _firebaseAuth?.signOut();
    } catch (error) {
      _errorMessage = error.toString();
      notifyListeners();
    }
  }

  Future<String?> getIdToken() async {
    if (mockMode) {
      return null;
    }
    final user = _firebaseAuth?.currentUser;
    if (user == null) {
      return null;
    }
    return user.getIdToken();
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }
}
