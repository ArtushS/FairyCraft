import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options_dev.dart' as dev_options;
import 'firebase_options_prod.dart' as prod_options;

const _flavor = String.fromEnvironment('FLAVOR', defaultValue: 'dev');

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return _flavor == 'prod'
            ? prod_options.DefaultFirebaseOptions.android
            : dev_options.DefaultFirebaseOptions.android;
      case TargetPlatform.iOS:
        return _flavor == 'prod'
            ? prod_options.DefaultFirebaseOptions.ios
            : dev_options.DefaultFirebaseOptions.ios;
      case TargetPlatform.macOS:
        return _flavor == 'prod'
            ? prod_options.DefaultFirebaseOptions.macos
            : dev_options.DefaultFirebaseOptions.macos;
      case TargetPlatform.windows:
        return _flavor == 'prod'
            ? prod_options.DefaultFirebaseOptions.windows
            : dev_options.DefaultFirebaseOptions.windows;
      case TargetPlatform.linux:
        return _flavor == 'prod'
            ? prod_options.DefaultFirebaseOptions.linux
            : dev_options.DefaultFirebaseOptions.linux;
      default:
        return _flavor == 'prod'
            ? prod_options.DefaultFirebaseOptions.web
            : dev_options.DefaultFirebaseOptions.web;
    }
  }
}
