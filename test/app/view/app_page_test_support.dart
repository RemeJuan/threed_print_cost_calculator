import 'package:flutter/material.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sembast/sembast.dart' hide Finder;
import 'package:threed_print_cost_calculator/app/app_page.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/whats_new_provider.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';
import '../../../test_support/fake_purchases_gateway.dart';

Future<void> bootstrapAppPageTests() async {
  await setupTest();
  PackageInfo.setMockInitialValues(
    appName: 'App',
    packageName: 'pkg',
    version: '1.2.3',
    buildNumber: '42',
    buildSignature: 'sig',
  );
}

void seedAppPagePrefs({int runCount = 0, bool hideProPromotions = false}) {
  SharedPreferences.setMockInitialValues({
    'run_count': runCount,
    if (hideProPromotions) 'hideProPromotions': true,
  });
}

Future<Database> pumpAppPage(
  WidgetTester tester,
  FakePurchasesGateway gateway,
  FakeCalculatorNotifier calculatorNotifier, {
  List<Override> overrides = const [],
  bool useDefaultAnnouncementOverride = true,
}) async {
  final db = await tester.pumpApp(const AppPage(), [
    calculatorProvider.overrideWith(() => calculatorNotifier),
    settingsRepositoryProvider.overrideWithValue(FakeSettingsRepository()),
    purchasesGatewayProvider.overrideWithValue(gateway),
    materialsStreamProvider.overrideWith(
      (ref) => Stream.value(const <MaterialModel>[]),
    ),
    if (useDefaultAnnouncementOverride)
      currentAnnouncementProvider.overrideWith((ref) async => null),
    ...overrides,
  ]);
  addTearDown(db.close);
  addTearDown(gateway.dispose);
  return db;
}

Future<void> settleAppPage(WidgetTester tester) async {
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 600));
}

String historyNavLabel() {
  return lookupAppLocalizations(const Locale('en')).historyNavLabel;
}

Finder historyNavFinder() => find.text(historyNavLabel());

Finder historyBadgeFinder() =>
    find.byKey(const ValueKey<String>('nav.history.pro.badge'));

PremiumState freeUser({String userId = 'free-1'}) {
  return PremiumState(isPremium: false, isLoading: false, userId: userId);
}

PremiumState premiumUser({String userId = 'pro-1'}) {
  return PremiumState(isPremium: true, isLoading: false, userId: userId);
}
