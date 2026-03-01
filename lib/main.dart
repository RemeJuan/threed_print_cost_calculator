// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.

import 'dart:io';

import 'package:device_check/device_check.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter/services.dart';
import 'package:localizely_sdk/localizely_sdk.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:sembast/sembast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/bootstrap.dart';
import 'package:threed_print_cost_calculator/calculator/model/material_usage.dart';
import 'package:threed_print_cost_calculator/firebase_options.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/history/index/printer_index.dart';

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

  await FirebaseAppCheck.instance.activate(
    providerApple: AppleAppAttestProvider(),
  );

  await revenueCat();
  final prefs = await SharedPreferences.getInstance();
  final db = await DatabaseStorageImpl().openDb();

  // Run any startup migrations (index rebuild etc.)
  await startupMigration(db);
  FlutterError.onError = FirebaseCrashlytics.instance.recordFlutterFatalError;
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  if (Platform.isIOS) {
    final deviceCheck = DeviceCheck.instance;
    final isSupported = await deviceCheck.isSupported();

    if (isSupported) {
      await DeviceCheck.instance.generateToken();
    }
  }

  Localizely.init(
    '8e7a9d1398e34b6cb58a2a16cc6954368b062836',
    'bfa0278e4ce9434e92abf8fc74aa6790',
  );

  return bootstrap(
    () => ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
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

Future<void> startupMigration(Database db) async {
  // Startup migration: ensure the printer index is built. Use a short-lived
  // ProviderContainer so we can use existing helper wiring without changing
  // the ProviderScope that's used by the app.
  final tempContainer = ProviderContainer(
    overrides: [databaseProvider.overrideWithValue(db)],
  );
  try {
    final indexHelpers = PrinterIndexHelpers.fromContainer(tempContainer);
    final indexed = await indexHelpers.getAllIndexedPrinters();
    if (indexed.isEmpty) {
      if (kDebugMode) {
        // ignore: avoid_print
        print('Printer index empty — rebuilding from history store...');
      }
      await indexHelpers.rebuildIndex();
      if (kDebugMode) {
        // ignore: avoid_print
        print('Printer index rebuild finished');
      }
    }
  } catch (e, st) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('Printer index rebuild failed: $e\n$st');
    }
  } finally {
    tempContainer.dispose();
  }

  // Migrate history records that pre-date multi-material support.
  await _migrateHistoryToMultiMaterial(db);
}

/// For each history record without a `materialUsages` field, create one
/// [MaterialUsage] from the legacy `material` (name) and `weight` fields so
/// that the multi-material UI always has data to display.
Future<void> _migrateHistoryToMultiMaterial(Database db) async {
  try {
    final store = stringMapStoreFactory.store('history');
    final records = await store.find(db);

    for (final record in records) {
      final map = Map<String, dynamic>.from(record.value as Map);
      if (map['materialUsages'] != null) continue;

      final materialName = map['material']?.toString() ?? '';
      final weight = (map['weight'] as num? ?? 0).toInt();

      final usage = MaterialUsage(
        materialId: '',
        materialName: materialName,
        weightGrams: weight,
        spoolWeightGrams: 0,
        spoolCost: 0,
      );

      await store.record(record.key).update(db, {
        ...map,
        'materialUsages': [usage.toMap()],
      });
    }

    if (kDebugMode) {
      // ignore: avoid_print
      print('History multi-material migration complete');
    }
  } catch (e, st) {
    if (kDebugMode) {
      // ignore: avoid_print
      print('History multi-material migration failed: $e\n$st');
    }
  }
}
