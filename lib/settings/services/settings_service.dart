import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

final settingsServiceProvider = Provider<SettingsService>(SettingsService.new);

class SettingsService {
  SettingsService(this.ref);

  final Ref ref;

  SettingsRepository get _repository => ref.read(settingsRepositoryProvider);

  Future<GeneralSettingsModel> get() => _repository.getSettings();

  Future<void> update(
    GeneralSettingsModel Function(GeneralSettingsModel current) updater,
  ) async {
    final current = await get();
    await _repository.saveSettings(updater(current));
  }
}
