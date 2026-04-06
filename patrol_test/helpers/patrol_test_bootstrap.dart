import 'package:flutter_test/flutter_test.dart';
import 'package:patrol/patrol.dart';

import '../../integration_test/helpers/integration_test_harness.dart';

Future<IntegrationTestHarness> launchFreePatrolApp(
  PatrolIntegrationTester $, {
  IntegrationHarnessSeed? seed,
}) {
  return _launchPatrolApp(
    $,
    createHarness: () => IntegrationTestHarness.free(seed: seed),
  );
}

Future<IntegrationTestHarness> launchPremiumPatrolApp(
  PatrolIntegrationTester $, {
  IntegrationHarnessSeed? seed,
}) {
  return _launchPatrolApp(
    $,
    createHarness: () => IntegrationTestHarness.premium(seed: seed),
  );
}

Future<IntegrationTestHarness> _launchPatrolApp(
  PatrolIntegrationTester $, {
  required Future<IntegrationTestHarness> Function() createHarness,
}) async {
  final harness = await createHarness();
  addTearDown(harness.dispose);

  await $.pumpWidgetAndSettle(harness.buildApp());

  return harness;
}
