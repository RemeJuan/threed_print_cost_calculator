import 'package:freezed_annotation/freezed_annotation.dart';

part 'interface_settings_model.freezed.dart';

enum CustomerViewDisplayStyle { summary, breakdown }

enum CustomerViewExitGesture { singleTap, tripleTap, longPress }

CustomerViewDisplayStyle customerViewDisplayStyleFromStorage(String? value) =>
    value == 'breakdown'
    ? CustomerViewDisplayStyle.breakdown
    : CustomerViewDisplayStyle.summary;

CustomerViewExitGesture customerViewExitGestureFromStorage(String? value) =>
    switch (value) {
      'singleTap' => CustomerViewExitGesture.singleTap,
      'tripleTap' => CustomerViewExitGesture.tripleTap,
      _ => CustomerViewExitGesture.longPress,
    };

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
    @Default(false) bool customerViewEnabled,
    @Default('') String customerViewCompanyName,
    @Default(false) bool customerViewShowCostBreakdown,
    @Default(false) bool customerViewShowItemBreakdown,
    @Default(CustomerViewDisplayStyle.summary)
    CustomerViewDisplayStyle customerViewDisplayStyle,
    @Default(CustomerViewExitGesture.longPress)
    CustomerViewExitGesture customerViewExitGesture,
    @Default(false) bool customerViewShowBackControl,
    @Default(false) bool customerViewShowBaseCost,
    @Default(false) bool customerViewShowElectricity,
    @Default(false) bool customerViewShowMaterial,
    @Default(false) bool customerViewShowFailureRisk,
    @Default(false) bool customerViewShowLabour,
    @Default(false) bool customerViewShowAdditionalCost,
    @Default(false) bool customerViewShowMarkup,
    @Default(false) bool customerViewShowSetupFee,
    @Default(false) bool customerViewShowRoundingAdjustment,
  }) = _InterfaceSettingsModel;

  factory InterfaceSettingsModel.fromMap(Map<String, dynamic> map) {
    bool readBool(String key, {required bool defaultValue}) {
      if (!map.containsKey(key) || map[key] == null) return defaultValue;
      final value = map[key];
      return value == true || value.toString() == 'true';
    }

    return InterfaceSettingsModel(
      showPrinterSelect: readBool('showPrinterSelect', defaultValue: true),
      showBatchButton: readBool('showBatchButton', defaultValue: true),
      showHistoryTab: readBool('showHistoryTab', defaultValue: true),
      showMaterialsTab: readBool('showMaterialsTab', defaultValue: true),
      showGcodeAction: readBool('showGcodeAction', defaultValue: true),
      showAdvancedBreakdown: readBool(
        'showAdvancedBreakdown',
        defaultValue: true,
      ),
      showLabourFields: readBool('showLabourFields', defaultValue: true),
      showFailureRisk: readBool('showFailureRisk', defaultValue: true),
      showWearAndTear: readBool('showWearAndTear', defaultValue: true),
      showMarkup: readBool('showMarkup', defaultValue: true),
      showCurrency: readBool('showCurrency', defaultValue: true),
      customerViewEnabled: readBool('customerViewEnabled', defaultValue: false),
      customerViewCompanyName: (map['customerViewCompanyName'] ?? '')
          .toString(),
      customerViewShowCostBreakdown: readBool(
        'customerViewShowCostBreakdown',
        defaultValue: false,
      ),
      customerViewShowItemBreakdown: readBool(
        'customerViewShowItemBreakdown',
        defaultValue: false,
      ),
      customerViewDisplayStyle: customerViewDisplayStyleFromStorage(
        map['customerViewDisplayStyle']?.toString(),
      ),
      customerViewExitGesture: customerViewExitGestureFromStorage(
        map['customerViewExitGesture']?.toString(),
      ),
      customerViewShowBackControl: readBool(
        'customerViewShowBackControl',
        defaultValue: false,
      ),
      customerViewShowBaseCost: readBool(
        'customerViewShowBaseCost',
        defaultValue: false,
      ),
      customerViewShowElectricity: readBool(
        'customerViewShowElectricity',
        defaultValue: false,
      ),
      customerViewShowMaterial: readBool(
        'customerViewShowMaterial',
        defaultValue: false,
      ),
      customerViewShowFailureRisk: readBool(
        'customerViewShowFailureRisk',
        defaultValue: false,
      ),
      customerViewShowLabour: readBool(
        'customerViewShowLabour',
        defaultValue: false,
      ),
      customerViewShowAdditionalCost: readBool(
        'customerViewShowAdditionalCost',
        defaultValue: false,
      ),
      customerViewShowMarkup: readBool(
        'customerViewShowMarkup',
        defaultValue: false,
      ),
      customerViewShowSetupFee: readBool(
        'customerViewShowSetupFee',
        defaultValue: false,
      ),
      customerViewShowRoundingAdjustment: readBool(
        'customerViewShowRoundingAdjustment',
        defaultValue: false,
      ),
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
    'customerViewEnabled': customerViewEnabled,
    'customerViewCompanyName': customerViewCompanyName,
    'customerViewShowCostBreakdown': customerViewShowCostBreakdown,
    'customerViewShowItemBreakdown': customerViewShowItemBreakdown,
    'customerViewDisplayStyle': customerViewDisplayStyle.name,
    'customerViewExitGesture': customerViewExitGesture.name,
    'customerViewShowBackControl': customerViewShowBackControl,
    'customerViewShowBaseCost': customerViewShowBaseCost,
    'customerViewShowElectricity': customerViewShowElectricity,
    'customerViewShowMaterial': customerViewShowMaterial,
    'customerViewShowFailureRisk': customerViewShowFailureRisk,
    'customerViewShowLabour': customerViewShowLabour,
    'customerViewShowAdditionalCost': customerViewShowAdditionalCost,
    'customerViewShowMarkup': customerViewShowMarkup,
    'customerViewShowSetupFee': customerViewShowSetupFee,
    'customerViewShowRoundingAdjustment': customerViewShowRoundingAdjustment,
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
      showCurrency &&
      !customerViewEnabled;

  bool get isCustomView => !isDefaultView;
}
