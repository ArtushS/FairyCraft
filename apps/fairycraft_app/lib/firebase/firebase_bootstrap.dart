import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../app/config.dart';
import 'firebase_options.dart';

class FirebaseBootstrap {
  FirebaseBootstrap({
    required this.firebaseReady,
    required this.appCheckAttempted,
    this.error,
  });

  final bool firebaseReady;
  final bool appCheckAttempted;
  final String? error;

  static Future<FirebaseBootstrap> init(AppConfig config) async {
    try {
      await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

      try {
        FirebaseFirestore.instance.settings = const Settings(persistenceEnabled: true);
      } catch (_) {
        // Persistence is best-effort and should not crash app startup.
      }

      var appCheckAttempted = false;
      try {
        appCheckAttempted = true;
        if (defaultTargetPlatform == TargetPlatform.android) {
          await FirebaseAppCheck.instance.activate(
            providerAndroid:
                kDebugMode ? const AndroidDebugProvider() : const AndroidPlayIntegrityProvider(),
          );
        } else if (defaultTargetPlatform == TargetPlatform.iOS) {
          await FirebaseAppCheck.instance.activate(
            providerApple: kDebugMode
                ? const AppleDebugProvider()
                : const AppleAppAttestWithDeviceCheckFallbackProvider(),
          );
        } else {
          await FirebaseAppCheck.instance.activate();
        }
      } catch (_) {
        // App Check issues should not crash app startup.
      }

      return FirebaseBootstrap(
        firebaseReady: true,
        appCheckAttempted: appCheckAttempted || config.appCheckRequired,
      );
    } catch (error) {
      return FirebaseBootstrap(
        firebaseReady: false,
        appCheckAttempted: false,
        error: error.toString(),
      );
    }
  }
}


