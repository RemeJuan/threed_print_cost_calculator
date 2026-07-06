import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_repository.dart';

final interfaceSettingsServiceProvider = Provider<InterfaceSettingsService>(
  InterfaceSettingsService.new,
);

class InterfaceSettingsService {
  InterfaceSettingsService(this.ref);
  final Ref ref;
  InterfaceSettingsRepository get _repository =>
      ref.read(interfaceSettingsRepositoryProvider);
  Future<InterfaceSettingsModel> get() => _repository.getSettings();
  Future<void> update(
    InterfaceSettingsModel Function(InterfaceSettingsModel current) updater,
  ) async {
    await _repository.updateSettings(updater);
    ref.invalidate(interfaceSettingsFutureProvider);
  }
}
