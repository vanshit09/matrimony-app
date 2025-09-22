import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import '../../firebase_options.dart';

// If you prefer using native platform configs (google-services.json / GoogleService-Info.plist),
// you can initialize without explicit options and remove firebase_options.dart.

class FirebaseInitializer {
  static bool _initialized = false;

  static Future<void> ensureInitialized() async {
    if (_initialized) return;
    if (kIsWeb) {
      // Web requires explicit FirebaseOptions
      await Firebase.initializeApp(
          options: DefaultFirebaseOptions.currentPlatform);
    } else {
      // Mobile/desktop can use native config (google-services.json / GoogleService-Info.plist)
      await Firebase.initializeApp();
    }
    _initialized = true;
  }
}
