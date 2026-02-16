import 'package:firebase_core/firebase_core.dart';

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
  static Future<FirebaseBootstrapResult> init(AppEnvironment environment) async {
    if (environment.useMockAdmin) {
      return const FirebaseBootstrapResult(
        firebaseReady: false,
        usingMockMode: true,
      );
    }

    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
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
