import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/settings/providers/printers_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

import '../settings_test_fakes.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({});

  Future<SharedPreferences> prefs() => SharedPreferences.getInstance();

  test('rejects invalid printer payloads before persistence', () async {
    final printersRepository = FakePrintersRepository();
    final container = ProviderContainer(
      overrides: [
        printersRepositoryProvider.overrideWithValue(printersRepository),
        sharedPreferencesProvider.overrideWithValue(await prefs()),
        isPremiumProvider.overrideWithValue(true),
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
        sharedPreferencesProvider.overrideWithValue(await prefs()),
        isPremiumProvider.overrideWithValue(true),
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

  test('hydrates existing printer into state on init', () async {
    final printersRepository = FakePrintersRepository();
    printersRepository.printersById['printer-1'] = const PrinterModel(
      id: 'printer-1',
      name: 'Prusa MK4',
      bedSize: '250x210x220',
      wattage: '350',
      archived: false,
    );

    final container = ProviderContainer(
      overrides: [
        printersRepositoryProvider.overrideWithValue(printersRepository),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(printersProvider.notifier);
    await notifier.init('printer-1');

    final state = container.read(printersProvider);
    expect(state.name.value, 'Prusa MK4');
    expect(state.bedSize.value, '250x210x220');
    expect(state.wattage.value, '350');
    expect(printersRepository.getPrinterByIdCalls, ['printer-1']);
  });
}
