import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

// Placeholder config. Replace via `flutterfire configure` for fairycraft_admin.
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
    appId: '1:000000000000:web:1111111111111111',
    messagingSenderId: '000000000000',
    projectId: 'fairycraft-placeholder',
    authDomain: 'fairycraft-placeholder.firebaseapp.com',
    storageBucket: 'fairycraft-placeholder.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: '1:000000000000:android:1111111111111111',
    messagingSenderId: '000000000000',
    projectId: 'fairycraft-placeholder',
    storageBucket: 'fairycraft-placeholder.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: '1:000000000000:ios:1111111111111111',
    messagingSenderId: '000000000000',
    projectId: 'fairycraft-placeholder',
    storageBucket: 'fairycraft-placeholder.appspot.com',
    iosBundleId: 'com.fairycraft.admin',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: '1:000000000000:ios:1111111111111112',
    messagingSenderId: '000000000000',
    projectId: 'fairycraft-placeholder',
    storageBucket: 'fairycraft-placeholder.appspot.com',
    iosBundleId: 'com.fairycraft.admin',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: '1:000000000000:web:1111111111111112',
    messagingSenderId: '000000000000',
    projectId: 'fairycraft-placeholder',
    storageBucket: 'fairycraft-placeholder.appspot.com',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'placeholder-api-key',
    appId: '1:000000000000:web:1111111111111113',
    messagingSenderId: '000000000000',
    projectId: 'fairycraft-placeholder',
    storageBucket: 'fairycraft-placeholder.appspot.com',
  );
}
