import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';

class NoopLogSink extends AppLogSink {
  const NoopLogSink();

  @override
  void log(AppLogEvent event) {}
}

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({GeneralSettingsModel? initialSettings})
    : _settings = initialSettings ?? GeneralSettingsModel.initial();

  final _controller = StreamController<GeneralSettingsModel>.broadcast();
  GeneralSettingsModel _settings;

  @override
  Ref get ref => throw UnimplementedError();

  @override
  Future<GeneralSettingsModel> getSettings() async => _settings;

  @override
  Stream<GeneralSettingsModel> watchSettings() => _controller.stream;

  @override
  Future<void> saveSettings(GeneralSettingsModel settings) async {
    _settings = settings;
    _controller.add(settings);
  }

  void emit(GeneralSettingsModel settings) {
    _settings = settings;
    _controller.add(settings);
  }

  Future<void> dispose() => _controller.close();
}
