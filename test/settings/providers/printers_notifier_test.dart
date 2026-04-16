import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/settings/providers/printers_notifier.dart';

import '../settings_test_fakes.dart';

void main() {
  test('rejects invalid printer payloads before persistence', () async {
    final printersRepository = FakePrintersRepository();
    final container = ProviderContainer(
      overrides: [
        printersRepositoryProvider.overrideWithValue(printersRepository),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(printersProvider.notifier);
    notifier.updateName('Prusa MK4');
    notifier.updateBedSize('0');
    notifier.updateWattage('350');

    final didSave = await notifier.submit(null);

    expect(didSave, isFalse);
    expect(printersRepository.savedPrinters, isEmpty);
  });

  test('accepts legacy dimension bed size payloads', () async {
    final printersRepository = FakePrintersRepository();
    final container = ProviderContainer(
      overrides: [
        printersRepositoryProvider.overrideWithValue(printersRepository),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(printersProvider.notifier);
    notifier.updateName('Prusa MK4');
    notifier.updateBedSize('250x210x220');
    notifier.updateWattage('350');

    final didSave = await notifier.submit(null);

    expect(didSave, isTrue);
    expect(printersRepository.savedPrinters.single.bedSize, '250x210x220');
  });
}
