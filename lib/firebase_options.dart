// ============================================================
//  PLACEHOLDER — replace this file by running:
//  flutterfire configure
// ============================================================
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'Run: flutterfire configure',
        );
    }
  }

  // TODO: These values are replaced automatically by: flutterfire configure
  static const FirebaseOptions android = FirebaseOptions(
    apiKey:            'YOUR_API_KEY',
    appId:             'YOUR_APP_ID',
    messagingSenderId: 'YOUR_SENDER_ID',
    projectId:         'YOUR_PROJECT_ID',
    storageBucket:     'YOUR_PROJECT_ID.appspot.com',
  );
}
