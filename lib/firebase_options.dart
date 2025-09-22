// Placeholder Firebase options. Replace with real config using FlutterFire CLI.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show kIsWeb, defaultTargetPlatform, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      // Web requires explicit values; put your real web config here
      return const FirebaseOptions(
          apiKey: "AIzaSyDjx2tjlI2TevIoYJSDF2NvPe_PzhxBZpc",
          authDomain: "matrimonyapp-8341a.firebaseapp.com",
          projectId: "matrimonyapp-8341a",
          storageBucket: "matrimonyapp-8341a.firebasestorage.app",
          messagingSenderId: "619059687842",
          appId: "1:619059687842:web:c33ad15eff436a253842fb",
          measurementId: "G-JFQRWGC905");
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return const FirebaseOptions(
            apiKey: "AIzaSyDjx2tjlI2TevIoYJSDF2NvPe_PzhxBZpc",
            authDomain: "matrimonyapp-8341a.firebaseapp.com",
            projectId: "matrimonyapp-8341a",
            storageBucket: "matrimonyapp-8341a.firebasestorage.app",
            messagingSenderId: "619059687842",
            appId: "1:619059687842:web:c33ad15eff436a253842fb",
            measurementId: "G-JFQRWGC905");
      case TargetPlatform.iOS:
        return const FirebaseOptions(
            apiKey: "AIzaSyDjx2tjlI2TevIoYJSDF2NvPe_PzhxBZpc",
            authDomain: "matrimonyapp-8341a.firebaseapp.com",
            projectId: "matrimonyapp-8341a",
            storageBucket: "matrimonyapp-8341a.firebasestorage.app",
            messagingSenderId: "619059687842",
            appId: "1:619059687842:web:c33ad15eff436a253842fb",
            measurementId: "G-JFQRWGC905");
      case TargetPlatform.macOS:
        return const FirebaseOptions(
            apiKey: "AIzaSyDjx2tjlI2TevIoYJSDF2NvPe_PzhxBZpc",
            authDomain: "matrimonyapp-8341a.firebaseapp.com",
            projectId: "matrimonyapp-8341a",
            storageBucket: "matrimonyapp-8341a.firebasestorage.app",
            messagingSenderId: "619059687842",
            appId: "1:619059687842:web:c33ad15eff436a253842fb",
            measurementId: "G-JFQRWGC905");
      case TargetPlatform.windows:
      case TargetPlatform.linux:
      case TargetPlatform.fuchsia:
        return const FirebaseOptions(
            apiKey: "AIzaSyDjx2tjlI2TevIoYJSDF2NvPe_PzhxBZpc",
            authDomain: "matrimonyapp-8341a.firebaseapp.com",
            projectId: "matrimonyapp-8341a",
            storageBucket: "matrimonyapp-8341a.firebasestorage.app",
            messagingSenderId: "619059687842",
            appId: "1:619059687842:web:c33ad15eff436a253842fb",
            measurementId: "G-JFQRWGC905");
    }
  }
}
