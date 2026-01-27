import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Configuration generated from Firebase Console
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
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
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCUJwRI1Wk8ZXSg14SEXCWQd4lybsjEH4g',
    appId: '1:993360298833:web:577b5acab4191bf0214970',
    messagingSenderId: '993360298833',
    projectId: 'silownia-app',
    authDomain: 'silownia-app.firebaseapp.com',
    storageBucket: 'silownia-app.firebasestorage.app',
    measurementId: 'G-JP4QNVB7T0',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCUJwRI1Wk8ZXSg14SEXCWQd4lybsjEH4g',
    appId: '1:993360298833:android:xxxxxxxxxxxxxxxx',
    messagingSenderId: '993360298833',
    projectId: 'silownia-app',
    storageBucket: 'silownia-app.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCUJwRI1Wk8ZXSg14SEXCWQd4lybsjEH4g',
    appId: '1:993360298833:ios:xxxxxxxxxxxxxxxx',
    messagingSenderId: '993360298833',
    projectId: 'silownia-app',
    storageBucket: 'silownia-app.firebasestorage.app',
    iosBundleId: 'com.example.silowniaApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCUJwRI1Wk8ZXSg14SEXCWQd4lybsjEH4g',
    appId: '1:993360298833:macos:xxxxxxxxxxxxxxxx',
    messagingSenderId: '993360298833',
    projectId: 'silownia-app',
    storageBucket: 'silownia-app.firebasestorage.app',
    iosBundleId: 'com.example.silowniaApp',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCUJwRI1Wk8ZXSg14SEXCWQd4lybsjEH4g',
    appId: '1:993360298833:windows:xxxxxxxxxxxxxxxx',
    messagingSenderId: '993360298833',
    projectId: 'silownia-app',
    storageBucket: 'silownia-app.firebasestorage.app',
  );

  static const FirebaseOptions linux = FirebaseOptions(
    apiKey: 'AIzaSyCUJwRI1Wk8ZXSg14SEXCWQd4lybsjEH4g',
    appId: '1:993360298833:linux:xxxxxxxxxxxxxxxx',
    messagingSenderId: '993360298833',
    projectId: 'silownia-app',
    storageBucket: 'silownia-app.firebasestorage.app',
  );
}
