// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyDOijvMG167VjoMKnB6g5L8hrkknujYrTA',
    appId: '1:827966598217:web:62c0d467d1455e5a722398',
    messagingSenderId: '827966598217',
    projectId: 'moonhike-df75b',
    authDomain: 'moonhike-df75b.firebaseapp.com',
    storageBucket: 'moonhike-df75b.appspot.com',
    measurementId: 'G-JZKFVJTJSR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB23ptgAEg-Dsf7xKQQ-HE3l4kyIVHjiAE',
    appId: '1:827966598217:android:843b1f92ee7e39ec722398',
    messagingSenderId: '827966598217',
    projectId: 'moonhike-df75b',
    storageBucket: 'moonhike-df75b.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBf1pU8lS8LI0oAawGVrjQkMlRvcTQRMDg',
    appId: '1:827966598217:ios:2637cc8fe673f0ab722398',
    messagingSenderId: '827966598217',
    projectId: 'moonhike-df75b',
    storageBucket: 'moonhike-df75b.appspot.com',
    iosBundleId: 'com.example.moonhike',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBf1pU8lS8LI0oAawGVrjQkMlRvcTQRMDg',
    appId: '1:827966598217:ios:2637cc8fe673f0ab722398',
    messagingSenderId: '827966598217',
    projectId: 'moonhike-df75b',
    storageBucket: 'moonhike-df75b.appspot.com',
    iosBundleId: 'com.example.moonhike',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyDOijvMG167VjoMKnB6g5L8hrkknujYrTA',
    appId: '1:827966598217:web:ef9808264274580a722398',
    messagingSenderId: '827966598217',
    projectId: 'moonhike-df75b',
    authDomain: 'moonhike-df75b.firebaseapp.com',
    storageBucket: 'moonhike-df75b.appspot.com',
    measurementId: 'G-PP628PLVDE',
  );
}