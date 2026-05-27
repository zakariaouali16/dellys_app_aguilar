import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) throw UnsupportedError('Web platform is not configured.');
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB8O8xRMdz2n-41daq2X9VzJqJlvQ4wI0c',
    appId: '1:949624679161:android:1cb1c5f2d7fa25d4c7d028',
    messagingSenderId: '949624679161',
    projectId: 'dellyp-app',
    storageBucket: 'dellyp-app.firebasestorage.app',
  );
}
