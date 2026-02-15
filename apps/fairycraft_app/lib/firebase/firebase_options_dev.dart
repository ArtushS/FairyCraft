import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

/// Dev Firebase options (generated / hand-maintained)
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
    apiKey: 'AIzaSyBcNnDvN4jBbgrzm8mOcssg9pgFyAj-zj4',
    appId: '1:790455730929:android:780d3b0e1af8faa1e89f50',
    messagingSenderId: '790455730929',
    projectId: 'fairycraft-dev',
    storageBucket: 'fairycraft-dev.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCc9HH1MTRzjuw1-ZPyByBL_Rcp458WdyU',
    appId: '1:790455730929:ios:16cd29ffcc871b74e89f50',
    messagingSenderId: '790455730929',
    projectId: 'fairycraft-dev',
    storageBucket: 'fairycraft-dev.firebasestorage.app',
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
