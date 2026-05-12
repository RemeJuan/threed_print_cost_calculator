import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/services/settings_service.dart';

import '../../helpers/lower_level_test_fakes.dart';

void main() {
  test('delegates get and saves transformed settings on update', () async {
    final repository = FakeSettingsRepository(
      initialSettings: const GeneralSettingsModel(
        electricityCost: '0.25',
        wattage: '350',
        activePrinter: 'printer-1',
        selectedMaterial: 'mat-1',
        wearAndTear: '0.1',
        failureRisk: '0.2',
        labourRate: '18',
      ),
    );
    final container = ProviderContainer(
      overrides: [settingsRepositoryProvider.overrideWithValue(repository)],
    );
    addTearDown(container.dispose);

    final service = container.read(settingsServiceProvider);

    final current = await service.get();
    expect(current.activePrinter, 'printer-1');

    await service.update(
      (settings) => settings.copyWith(wattage: '400', labourRate: '20'),
    );

    expect(repository.lastSavedSettings, isNotNull);
    expect(repository.lastSavedSettings!.wattage, '400');
    expect(repository.lastSavedSettings!.labourRate, '20');
    expect(repository.lastSavedSettings!.activePrinter, 'printer-1');
  });
}
