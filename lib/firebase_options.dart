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
        return ios;
      case TargetPlatform.macOS:
        return macos;
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
    apiKey: 'AIzaSyDcJ6TRXHo5SoQUnzncoCTMnwoJxnGf7Xo',
    appId: '1:397524671983:web:906290f9791fb2809c6a1a',
    messagingSenderId: '397524671983',
    projectId: 'dosify-flutter',
    authDomain: 'dosify-flutter.firebaseapp.com',
    storageBucket: 'dosify-flutter.firebasestorage.app',
    measurementId: 'G-5SCD2FX6ZP',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyA4rO_dkkPY7SdkekbAYGK6GH5Pt0NqrMQ',
    appId: '1:397524671983:android:8b27cc97d38641c09c6a1a',
    messagingSenderId: '397524671983',
    projectId: 'dosify-flutter',
    storageBucket: 'dosify-flutter.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBeA08hiUhb7ttblKWWBEjPShVHrQ4HKnA',
    appId: '1:397524671983:ios:1cb3c8d609b443e09c6a1a',
    messagingSenderId: '397524671983',
    projectId: 'dosify-flutter',
    storageBucket: 'dosify-flutter.firebasestorage.app',
    iosBundleId: 'com.kinemspa.dosifyFlutter',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'YOUR-MACOS-API-KEY',
    appId: 'YOUR-MACOS-APP-ID',
    messagingSenderId: 'YOUR-SENDER-ID',
    projectId: 'YOUR-PROJECT-ID',
    storageBucket: 'YOUR-STORAGE-BUCKET',
    iosClientId: 'YOUR-MACOS-CLIENT-ID',
    iosBundleId: 'YOUR-MACOS-BUNDLE-ID',
  );
}