// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
    apiKey: 'AIzaSyDHQGQjXsD8DqeQxPzs-5v8KJnQiT438Pw',
    appId: '1:476308766683:web:5cad6bcc5d87912a0c31fe',
    messagingSenderId: '476308766683',
    projectId: 'd-print-cost-calculator-cf650',
    authDomain: 'd-print-cost-calculator-cf650.firebaseapp.com',
    storageBucket: 'd-print-cost-calculator-cf650.appspot.com',
    measurementId: 'G-ZNVWBSV5TR',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBw_U7lC1SREVirU29Y_ZpuPOT0e0hmPfo',
    appId: '1:476308766683:android:7fc07cf44f4526bc0c31fe',
    messagingSenderId: '476308766683',
    projectId: 'd-print-cost-calculator-cf650',
    storageBucket: 'd-print-cost-calculator-cf650.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAc1le-IkbKaQ4SV2jDZfFdCBwCpyo_XHo',
    appId: '1:476308766683:ios:df64edd07e4671b80c31fe',
    messagingSenderId: '476308766683',
    projectId: 'd-print-cost-calculator-cf650',
    storageBucket: 'd-print-cost-calculator-cf650.appspot.com',
    iosClientId:
        '476308766683-67bs8unk224gqs08rno46jie8mrdv5hk.apps.googleusercontent.com',
    iosBundleId: 'com.threed-print-calculator',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAc1le-IkbKaQ4SV2jDZfFdCBwCpyo_XHo',
    appId: '1:476308766683:ios:5e23f3fd8e51e8580c31fe',
    messagingSenderId: '476308766683',
    projectId: 'd-print-cost-calculator-cf650',
    storageBucket: 'd-print-cost-calculator-cf650.appspot.com',
    iosClientId:
        '476308766683-ro40nk28e2qp7br4bm5aq26h3ijct017.apps.googleusercontent.com',
    iosBundleId: 'com.threedprintcalculator.threedPrintCostCalculator',
  );
}
