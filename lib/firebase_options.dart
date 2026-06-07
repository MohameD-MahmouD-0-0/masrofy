// File generated from android/app/google-services.json.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        throw UnsupportedError(
          'Firebase iOS is not configured for the new project.',
        );
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'Firebase macOS is not configured for the new project.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'Firebase Windows is not configured for the new project.',
        );
      case TargetPlatform.linux:
        throw UnsupportedError(
          'Firebase Linux is not configured for the new project.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyDuQSEu3h9rciwTgAp9YJHRGJS4ImFPwko',
    appId: '1:542813765612:android:3493c128c06a5d6aa28ac9',
    messagingSenderId: '542813765612',
    projectId: 'masrof-60ad5',
    storageBucket: 'masrof-60ad5.firebasestorage.app',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDuQSEu3h9rciwTgAp9YJHRGJS4ImFPwko',
    appId: '1:542813765612:web:3493c128c06a5d6aa28ac9',
    messagingSenderId: '542813765612',
    projectId: 'masrof-60ad5',
    authDomain: 'masrof-60ad5.firebaseapp.com',
    storageBucket: 'masrof-60ad5.firebasestorage.app',
  );
}
