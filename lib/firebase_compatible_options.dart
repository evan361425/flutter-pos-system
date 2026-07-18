// Firebase configuration using dart-define environment variables.
// DO NOT COMMIT REAL API KEYS TO VERSION CONTROL.
//
// Usage: Run with --dart-define values:
// flutter run --dart-define=FIREBASE_API_KEY_ANDROID_PROD=your_key \
//             --dart-define=FIREBASE_APP_ID_ANDROID_PROD=your_app_id \
//             --dart-define=FIREBASE_MESSAGING_SENDER_ID_ANDROID_PROD=your_sender_id \
//             --dart-define=FIREBASE_PROJECT_ID_ANDROID_PROD=your_project_id \
//             --dart-define=FIREBASE_STORAGE_BUCKET_ANDROID_PROD=your_bucket \
//             --dart-define=FIREBASE_API_KEY_IOS_PROD=your_key \
//             --dart-define=FIREBASE_APP_ID_IOS_PROD=your_app_id \
//             --dart-define=FIREBASE_MESSAGING_SENDER_ID_IOS_PROD=your_sender_id \
//             --dart-define=FIREBASE_PROJECT_ID_IOS_PROD=your_project_id \
//             --dart-define=FIREBASE_STORAGE_BUCKET_IOS_PROD=your_bucket \
//             --dart-define=FIREBASE_ANDROID_CLIENT_ID_IOS_PROD=your_android_client_id \
//             --dart-define=FIREBASE_IOS_CLIENT_ID_IOS_PROD=your_ios_client_id \
//             --dart-define=FIREBASE_IOS_BUNDLE_ID_IOS_PROD=your_bundle_id \
//             --dart-define=FIREBASE_API_KEY_ANDROID_DEBUG=your_key \
//             --dart-define=FIREBASE_APP_ID_ANDROID_DEBUG=your_app_id \
//             --dart-define=FIREBASE_MESSAGING_SENDER_ID_ANDROID_DEBUG=your_sender_id \
//             --dart-define=FIREBASE_PROJECT_ID_ANDROID_DEBUG=your_project_id \
//             --dart-define=FIREBASE_STORAGE_BUCKET_ANDROID_DEBUG=your_bucket \
//             --dart-define=FIREBASE_API_KEY_IOS_DEBUG=your_key \
//             --dart-define=FIREBASE_APP_ID_IOS_DEBUG=your_app_id \
//             --dart-define=FIREBASE_MESSAGING_SENDER_ID_IOS_DEBUG=your_sender_id \
//             --dart-define=FIREBASE_PROJECT_ID_IOS_DEBUG=your_project_id \
//             --dart-define=FIREBASE_STORAGE_BUCKET_IOS_DEBUG=your_bucket \
//             --dart-define=FIREBASE_ANDROID_CLIENT_ID_IOS_DEBUG=your_android_client_id \
//             --dart-define=FIREBASE_IOS_CLIENT_ID_IOS_DEBUG=your_ios_client_id \
//             --dart-define=FIREBASE_IOS_BUNDLE_ID_IOS_DEBUG=your_bundle_id

// ignore_for_file: avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb;
import 'package:possystem/constants/constant.dart';

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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    return switch (defaultTargetPlatform) {
      .android => isProd ? _androidProd : _androidDebug,
      .iOS => isProd ? _iosProd : _iosDebug,
      .macOS => throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for macos - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      ),
      .windows => throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for windows - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      ),
      .linux => throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for linux - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      ),
      _ => throw UnsupportedError(
        'DefaultFirebaseOptions are not supported for this platform.',
      ),
    };
  }

  // Android Production
  static FirebaseOptions get _androidProd => FirebaseOptions(
    apiKey: _getEnv('FIREBASE_API_KEY_ANDROID_PROD'),
    appId: _getEnv('FIREBASE_APP_ID_ANDROID_PROD'),
    messagingSenderId: _getEnv('FIREBASE_MESSAGING_SENDER_ID_ANDROID_PROD'),
    projectId: _getEnv('FIREBASE_PROJECT_ID_ANDROID_PROD'),
    storageBucket: _getEnv('FIREBASE_STORAGE_BUCKET_ANDROID_PROD'),
  );

  // Android Debug
  static FirebaseOptions get _androidDebug => FirebaseOptions(
    apiKey: _getEnv('FIREBASE_API_KEY_ANDROID_DEBUG'),
    appId: _getEnv('FIREBASE_APP_ID_ANDROID_DEBUG'),
    messagingSenderId: _getEnv('FIREBASE_MESSAGING_SENDER_ID_ANDROID_DEBUG'),
    projectId: _getEnv('FIREBASE_PROJECT_ID_ANDROID_DEBUG'),
    storageBucket: _getEnv('FIREBASE_STORAGE_BUCKET_ANDROID_DEBUG'),
  );

  // iOS Production
  static FirebaseOptions get _iosProd => FirebaseOptions(
    apiKey: _getEnv('FIREBASE_API_KEY_IOS_PROD'),
    appId: _getEnv('FIREBASE_APP_ID_IOS_PROD'),
    messagingSenderId: _getEnv('FIREBASE_MESSAGING_SENDER_ID_IOS_PROD'),
    projectId: _getEnv('FIREBASE_PROJECT_ID_IOS_PROD'),
    storageBucket: _getEnv('FIREBASE_STORAGE_BUCKET_IOS_PROD'),
    androidClientId: _getEnv('FIREBASE_ANDROID_CLIENT_ID_IOS_PROD'),
    iosClientId: _getEnv('FIREBASE_IOS_CLIENT_ID_IOS_PROD'),
    iosBundleId: _getEnv('FIREBASE_IOS_BUNDLE_ID_IOS_PROD'),
  );

  // iOS Debug
  static FirebaseOptions get _iosDebug => FirebaseOptions(
    apiKey: _getEnv('FIREBASE_API_KEY_IOS_DEBUG'),
    appId: _getEnv('FIREBASE_APP_ID_IOS_DEBUG'),
    messagingSenderId: _getEnv('FIREBASE_MESSAGING_SENDER_ID_IOS_DEBUG'),
    projectId: _getEnv('FIREBASE_PROJECT_ID_IOS_DEBUG'),
    storageBucket: _getEnv('FIREBASE_STORAGE_BUCKET_IOS_DEBUG'),
    androidClientId: _getEnv('FIREBASE_ANDROID_CLIENT_ID_IOS_DEBUG'),
    iosClientId: _getEnv('FIREBASE_IOS_CLIENT_ID_IOS_DEBUG'),
    iosBundleId: _getEnv('FIREBASE_IOS_BUNDLE_ID_IOS_DEBUG'),
  );

  static String _getEnv(String name) {
    const value = String.fromEnvironment(name);
    if (value.isEmpty) {
      throw StateError(
        'Missing required environment variable: $name. '
        'Please provide it via --dart-define=$name=value',
      );
    }
    return value;
  }
}
