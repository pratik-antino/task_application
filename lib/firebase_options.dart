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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      case TargetPlatform.windows:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyBR0FYSRHScWrzMRkJBZstLznfVJgxstm0',
    appId: '1:468180785903:web:1bbe0ed416eee6be15591a',
    messagingSenderId: '468180785903',
    projectId: 'aaplink-121e0',
    authDomain: 'aaplink-121e0.firebaseapp.com',
    storageBucket: 'aaplink-121e0.firebasestorage.app',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCi4y36QM_1T-s6HysIqrZqy7wfwkfhOKA',
    appId: '1:468180785903:android:8ec4c7fcf84dc73d15591a',
    messagingSenderId: '468180785903',
    projectId: 'aaplink-121e0',
    storageBucket: 'aaplink-121e0.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyABTYT3xzRc9xrbE7rv7jaWYAM4NEwAaPo',
    appId: '1:468180785903:ios:d2d75a62763ade7515591a',
    messagingSenderId: '468180785903',
    projectId: 'aaplink-121e0',
    storageBucket: 'aaplink-121e0.firebasestorage.app',
    androidClientId: '468180785903-286k9v76ph5igb3nkfbds76n0ntimr8h.apps.googleusercontent.com',
    iosClientId: '468180785903-jm45i2ikqipiqrlebmoal8ivm1g8t6vf.apps.googleusercontent.com',
    iosBundleId: 'com.taskapplication',
  );

}