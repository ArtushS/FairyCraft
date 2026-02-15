import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../app/config.dart';
import 'firebase_options.dart';

const _flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

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
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      try {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
        );
      } catch (_) {
        // Persistence is best-effort and should not crash app startup.
      }

      var appCheckAttempted = false;
      if (config.appCheckRequired &&
          defaultTargetPlatform == TargetPlatform.android) {
        try {
          appCheckAttempted = true;
          final isProdFlavor = _flavor.trim().toLowerCase() == 'prod';
          await FirebaseAppCheck.instance.activate(
            providerAndroid: isProdFlavor
                ? const AndroidPlayIntegrityProvider()
                : const AndroidDebugProvider(),
          );
        } catch (_) {
          // App Check issues should not crash app startup.
        }
      } else if (config.appCheckRequired &&
          defaultTargetPlatform == TargetPlatform.iOS) {
        // TODO: configure iOS App Check once iOS Firebase wiring is enabled on macOS.
      }

      return FirebaseBootstrap(
        firebaseReady: true,
        appCheckAttempted: appCheckAttempted,
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
