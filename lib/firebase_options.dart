// Stub: replace this file by running:
//   dart pub global activate flutterfire_cli
//   flutterfire configure
//
// This allows the project to compile before Firebase is configured.
// Delete this comment after running flutterfire configure.

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;

class DefaultFirebaseOptions {
  DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    return const FirebaseOptions(
      apiKey: 'placeholder',
      appId: 'placeholder',
      messagingSenderId: 'placeholder',
      projectId: 'placeholder',
      storageBucket: 'placeholder',
    );
  }
}
