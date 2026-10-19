// File generated manually for web support.
// Firebase project: order-gaza
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
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
            'DefaultFirebaseOptions have not been configured for macOS.');
      case TargetPlatform.windows:
        throw UnsupportedError(
            'DefaultFirebaseOptions have not been configured for Windows.');
      case TargetPlatform.linux:
        throw UnsupportedError(
            'DefaultFirebaseOptions have not been configured for Linux.');
      default:
        throw UnsupportedError(
            'DefaultFirebaseOptions are not supported for this platform.');
    }
  }

  // ── Web ────────────────────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBKmeY5AoMI3sE9CUhQTQqeDC5biwagX8A',
    authDomain: 'order-gaza.firebaseapp.com',
    projectId: 'order-gaza',
    storageBucket: 'order-gaza.firebasestorage.app',
    messagingSenderId: '103107852998',
    appId: '1:103107852998:web:d6a4ea0d681d9f7bf8f5c7',
    measurementId: 'G-32PZHC72BS',
  );

  // ── Android ────────────────────────────────────────────────────────────────
  // Values are read from google-services.json on Android — keep as-is.
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBKmeY5AoMI3sE9CUhQTQqeDC5biwagX8A',
    authDomain: 'order-gaza.firebaseapp.com',
    projectId: 'order-gaza',
    storageBucket: 'order-gaza.firebasestorage.app',
    messagingSenderId: '103107852998',
    appId: '1:103107852998:android:admin', // placeholder — Android reads google-services.json
  );

  // ── iOS ────────────────────────────────────────────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBKmeY5AoMI3sE9CUhQTQqeDC5biwagX8A',
    authDomain: 'order-gaza.firebaseapp.com',
    projectId: 'order-gaza',
    storageBucket: 'order-gaza.firebasestorage.app',
    messagingSenderId: '103107852998',
    appId: '1:103107852998:ios:admin', // placeholder — iOS reads GoogleService-Info.plist
  );
}
