// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/bootstrap.dart';
import 'package:threed_print_cost_calculator/settings/backup_restore/automatic_backup_callback.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_migration.dart';
import 'package:threed_print_cost_calculator/startup.dart';
import 'package:threed_print_cost_calculator/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:workmanager/workmanager.dart';

import 'app/app.dart';
import 'database/database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations early and await to avoid side-effects in widgets
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FirebaseAnalytics.instance.setAnalyticsCollectionEnabled(!kDebugMode);

  await FirebaseAppCheck.instance.activate(
    providerApple: AppleAppAttestProvider(),
  );

  await Workmanager().initialize(automaticBackupCallbackDispatcher);

  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  await revenueCat();
  final prefs = await SharedPreferences.getInstance();
  final premiumLocalStore = CachedPremiumLocalStore(
    const FlutterSecureStorage(),
    onError: (error, stackTrace) {
      FlutterError.reportError(
        FlutterErrorDetails(
          exception: error,
          stack: stackTrace,
          library: 'premium_local_store',
          context: ErrorDescription('while reading secure premium local store'),
        ),
      );
    },
  );
  await premiumLocalStore.preload();
  await migratePremiumLocalStore(
    sharedPreferences: prefs,
    premiumLocalStore: premiumLocalStore,
  );
  final db = await DatabaseStorageImpl().openDb();

  // Run any startup migrations (index rebuild etc.)
  await startupMigration(db);

  return bootstrap(
    () => ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
        premiumLocalStoreProvider.overrideWithValue(premiumLocalStore),
        databaseProvider.overrideWithValue(db),
      ],
      child: const App(),
    ),
  );
}

Future<void> revenueCat() async {
  await Purchases.setLogLevel(LogLevel.debug);

  late PurchasesConfiguration configuration;
  if (Platform.isAndroid) {
    configuration = PurchasesConfiguration('goog_JuJbmwmKhkyRSsswDqoVyMDlGdM');
  } else if (Platform.isIOS || Platform.isMacOS) {
    configuration = PurchasesConfiguration('appl_pKHoxoNodCJqGiKMyPkOzCNtcyF');
  }
  await Purchases.configure(configuration);
}
