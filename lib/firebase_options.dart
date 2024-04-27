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
    apiKey: 'AIzaSyAB9FAFofjaol89aAD1ALJ0saTqT1_hkIU',
    appId: '1:786475015744:web:50840a6926c4c7a8d909a5',
    messagingSenderId: '786475015744',
    projectId: 'vaccino-9386f',
    authDomain: 'vaccino-9386f.firebaseapp.com',
    storageBucket: 'vaccino-9386f.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB8FRsnL8Mm5JmXZX4TCunWHSfNXf4hjVc',
    appId: '1:786475015744:android:4f643ba61c95281ad909a5',
    messagingSenderId: '786475015744',
    projectId: 'vaccino-9386f',
    storageBucket: 'vaccino-9386f.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAD8K0XvliJyMhfTqlBGCDbDpU_M-qntiA',
    appId: '1:786475015744:ios:9fa63b574dd4b3cbd909a5',
    messagingSenderId: '786475015744',
    projectId: 'vaccino-9386f',
    storageBucket: 'vaccino-9386f.appspot.com',
    iosBundleId: 'com.example.vaccino',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAD8K0XvliJyMhfTqlBGCDbDpU_M-qntiA',
    appId: '1:786475015744:ios:9fa63b574dd4b3cbd909a5',
    messagingSenderId: '786475015744',
    projectId: 'vaccino-9386f',
    storageBucket: 'vaccino-9386f.appspot.com',
    iosBundleId: 'com.example.vaccino',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyAB9FAFofjaol89aAD1ALJ0saTqT1_hkIU',
    appId: '1:786475015744:web:6fbcdfa2d913cd21d909a5',
    messagingSenderId: '786475015744',
    projectId: 'vaccino-9386f',
    authDomain: 'vaccino-9386f.firebaseapp.com',
    storageBucket: 'vaccino-9386f.appspot.com',
  );
}
