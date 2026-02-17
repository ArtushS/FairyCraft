import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../config/app_environment.dart';
import 'firebase_options.dart';

class FirebaseBootstrapResult {
  const FirebaseBootstrapResult({
    required this.firebaseReady,
    required this.usingMockMode,
    this.error,
  });

  final bool firebaseReady;
  final bool usingMockMode;
  final String? error;
}

class FirebaseBootstrap {
  static Future<FirebaseBootstrapResult> init(
    AppEnvironment environment,
  ) async {
    if (environment.useMockAdmin) {
      return const FirebaseBootstrapResult(
        firebaseReady: false,
        usingMockMode: true,
      );
    }

    try {
      final options = DefaultFirebaseOptions.currentPlatform;

      // On web we require authDomain to be present in the generated firebase options.
      if (kIsWeb) {
        final authDomain = options.authDomain;
        if (authDomain == null || authDomain.isEmpty) {
          return const FirebaseBootstrapResult(
            firebaseReady: false,
            usingMockMode: true,
            error:
                'Missing firebase authDomain in firebase_options for web. Regenerate firebase_options using FlutterFire CLI and include the web authDomain.',
          );
        }
      }

      await Firebase.initializeApp(options: options);
      return const FirebaseBootstrapResult(
        firebaseReady: true,
        usingMockMode: false,
      );
    } catch (error) {
      return FirebaseBootstrapResult(
        firebaseReady: false,
        usingMockMode: true,
        error: error.toString(),
      );
    }
  }
}
