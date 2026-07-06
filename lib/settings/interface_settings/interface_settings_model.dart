import 'package:freezed_annotation/freezed_annotation.dart';

part 'interface_settings_model.freezed.dart';

@freezed
abstract class InterfaceSettingsModel with _$InterfaceSettingsModel {
  const factory InterfaceSettingsModel({
    @Default(true) bool showPrinterSelect,
    @Default(true) bool showBatchButton,
    @Default(true) bool showHistoryTab,
    @Default(true) bool showMaterialsTab,
    @Default(true) bool showGcodeAction,
    @Default(true) bool showAdvancedBreakdown,
    @Default(true) bool showLabourFields,
    @Default(true) bool showFailureRisk,
    @Default(true) bool showWearAndTear,
    @Default(true) bool showMarkup,
    @Default(true) bool showCurrency,
  }) = _InterfaceSettingsModel;

  factory InterfaceSettingsModel.fromMap(Map<String, dynamic> map) {
    bool readBool(String key) {
      if (!map.containsKey(key) || map[key] == null) return true;
      final value = map[key];
      return value == true || value?.toString() == 'true';
    }

    return InterfaceSettingsModel(
      showPrinterSelect: readBool('showPrinterSelect'),
      showBatchButton: readBool('showBatchButton'),
      showHistoryTab: readBool('showHistoryTab'),
      showMaterialsTab: readBool('showMaterialsTab'),
      showGcodeAction: readBool('showGcodeAction'),
      showAdvancedBreakdown: readBool('showAdvancedBreakdown'),
      showLabourFields: readBool('showLabourFields'),
      showFailureRisk: readBool('showFailureRisk'),
      showWearAndTear: readBool('showWearAndTear'),
      showMarkup: readBool('showMarkup'),
      showCurrency: readBool('showCurrency'),
    );
  }

  factory InterfaceSettingsModel.initial() => const InterfaceSettingsModel();
}

extension InterfaceSettingsModelX on InterfaceSettingsModel {
  Map<String, dynamic> toMap() => {
    'showPrinterSelect': showPrinterSelect,
    'showBatchButton': showBatchButton,
    'showHistoryTab': showHistoryTab,
    'showMaterialsTab': showMaterialsTab,
    'showGcodeAction': showGcodeAction,
    'showAdvancedBreakdown': showAdvancedBreakdown,
    'showLabourFields': showLabourFields,
    'showFailureRisk': showFailureRisk,
    'showWearAndTear': showWearAndTear,
    'showMarkup': showMarkup,
    'showCurrency': showCurrency,
  };

  bool get isDefaultView =>
      showPrinterSelect &&
      showBatchButton &&
      showHistoryTab &&
      showMaterialsTab &&
      showGcodeAction &&
      showAdvancedBreakdown &&
      showLabourFields &&
      showFailureRisk &&
      showWearAndTear &&
      showMarkup &&
      showCurrency;

  bool get isCustomView => !isDefaultView;
}
