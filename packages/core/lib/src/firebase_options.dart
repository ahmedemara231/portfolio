import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return const bool.fromEnvironment('USE_EMULATORS') ? emulator : web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for this platform.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions emulator = FirebaseOptions(
    apiKey: 'demo-api-key',
    appId: '1:123456789:web:demo',
    messagingSenderId: '123456789',
    projectId: 'demo-portfolio',
    authDomain: 'localhost',
    storageBucket: 'demo-portfolio.appspot.com',
  );

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCUJY9s-lnGXlfW6KgrVLj_mEVwM6_Dgis',
    appId: '1:103600749341:web:2690c74627c2ad9030bff4',
    messagingSenderId: '103600749341',
    projectId: 'portfolio-60d78',
    authDomain: 'portfolio-60d78.firebaseapp.com',
    storageBucket: 'portfolio-60d78.firebasestorage.app',
    measurementId: 'G-TTJPE64XNX',
  );
}
