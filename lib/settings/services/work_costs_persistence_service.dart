import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/services/settings_service.dart';

class WorkCostsPersistenceService {
  WorkCostsPersistenceService(this.ref);
  final Ref ref;

  SettingsService get _settingsService => ref.read(settingsServiceProvider);
  AppLogger get _logger => ref.read(appLoggerProvider);

  Future<void> saveSetting({
    required GeneralSettingsModel Function(GeneralSettingsModel) updateWith,
    required String settingName,
  }) async {
    try {
      await _settingsService.update(updateWith);
    } catch (e, st) {
      _logger.error(
        AppLogCategory.ui,
        'Failed to persist $settingName',
        context: {'setting': settingName},
        error: e,
        stackTrace: st,
      );
    }
  }
}

final workCostsPersistenceServiceProvider =
    Provider<WorkCostsPersistenceService>((ref) {
      return WorkCostsPersistenceService(ref);
    });
