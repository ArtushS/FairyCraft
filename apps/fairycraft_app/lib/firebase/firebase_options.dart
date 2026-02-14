import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Placeholder Firebase options for local compilation.
// Replace by running `flutterfire configure` for FairyCraft.
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        return linux;
      default:
        return web;
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: '1:000000000000:web:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'fairycraft-placeholder',
    authDomain: 'fairycraft-placeholder.firebaseapp.com',
    storageBucket: 'fairycraft-placeholder.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: '1:000000000000:android:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'fairycraft-placeholder',
    storageBucket: 'fairycraft-placeholder.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: '1:000000000000:ios:0000000000000000',
    messagingSenderId: '000000000000',
    projectId: 'fairycraft-placeholder',
    storageBucket: 'fairycraft-placeholder.appspot.com',
    iosBundleId: 'com.fairycraft.app',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: '1:000000000000:ios:0000000000000001',
    messagingSenderId: '000000000000',
    projectId: 'fairycraft-placeholder',
    storageBucket: 'fairycraft-placeholder.appspot.com',
    iosBundleId: 'com.fairycraft.app',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: '1:000000000000:web:0000000000000001',
    messagingSenderId: '000000000000',
    projectId: 'fairycraft-placeholder',
    storageBucket: 'fairycraft-placeholder.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: '1:000000000000:web:0000000000000002',
    messagingSenderId: '000000000000',
    projectId: 'fairycraft-placeholder',
    storageBucket: 'fairycraft-placeholder.appspot.com',
  );
}
