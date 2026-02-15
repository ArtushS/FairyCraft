import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Prod Firebase options (generated / hand-maintained)
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
    apiKey: 'AIzaSyCn_11LJmm7M6Rs4WCdfsbuOjOkK6qwBBc',
    appId: '1:640487678578:android:a6eed98f01c506a8ec18eb',
    messagingSenderId: '640487678578',
    projectId: 'fairycraft-prod',
    storageBucket: 'fairycraft-prod.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyDDsQZteJ47bP8H1O6isl2q8M7u8No-s20',
    appId: '1:640487678578:ios:c9a2456cd59737fdec18eb',
    messagingSenderId: '640487678578',
    projectId: 'fairycraft-prod',
    storageBucket: 'fairycraft-prod.firebasestorage.app',
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
