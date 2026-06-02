import 'package:freezed_annotation/freezed_annotation.dart';

part 'general_settings_model.freezed.dart';

@freezed
abstract class GeneralSettingsModel with _$GeneralSettingsModel {
  const factory GeneralSettingsModel({
    required String electricityCost,
    required String wattage,
    @Default('') String averageWattage,
    required String activePrinter,
    required String selectedMaterial,
    required String wearAndTear,
    required String failureRisk,
    required String labourRate,
    @Default('') String pricingMarkupPercent,
    @Default('') String pricingSetupFee,
    @Default('none') String pricingRoundingMode,
    @Default('') String currencySymbol,
    @Default('before') String currencyPosition,
    @Default(false) bool currencySpacing,
  }) = _GeneralSettingsModel;

  factory GeneralSettingsModel.fromMap(Map<String, dynamic> map) {
    return GeneralSettingsModel(
      electricityCost: (map['electricityCost'] ?? '').toString(),
      wattage: (map['wattage'] ?? '').toString(),
      averageWattage: (map['averageWattage'] ?? '').toString(),
      activePrinter: (map['activePrinter'] ?? '').toString(),
      selectedMaterial: (map['selectedMaterial'] ?? '').toString(),
      wearAndTear: (map['wearAndTear'] ?? '').toString(),
      failureRisk: (map['failureRisk'] ?? '').toString(),
      labourRate: (map['labourRate'] ?? '').toString(),
      pricingMarkupPercent: (map['pricingMarkupPercent'] ?? '').toString(),
      pricingSetupFee: (map['pricingSetupFee'] ?? '').toString(),
      pricingRoundingMode: (map['pricingRoundingMode'] ?? 'none').toString(),
      currencySymbol: (map['currencySymbol'] ?? '').toString(),
      currencyPosition: (map['currencyPosition'] ?? 'before').toString(),
      currencySpacing:
          map['currencySpacing'] == true ||
          map['currencySpacing']?.toString() == 'true',
    );
  }

  factory GeneralSettingsModel.initial() {
    return const GeneralSettingsModel(
      electricityCost: '',
      wattage: '',
      averageWattage: '',
      activePrinter: '',
      selectedMaterial: '',
      wearAndTear: '',
      failureRisk: '',
      labourRate: '',
      pricingMarkupPercent: '',
      pricingSetupFee: '',
      pricingRoundingMode: 'none',
      currencySymbol: '',
      currencyPosition: 'before',
      currencySpacing: false,
    );
  }
}

extension GeneralSettingsModelX on GeneralSettingsModel {
  Map<String, dynamic> toMap() {
    return {
      'electricityCost': electricityCost,
      'wattage': wattage,
      'averageWattage': averageWattage,
      'activePrinter': activePrinter,
      'selectedMaterial': selectedMaterial,
      'wearAndTear': wearAndTear,
      'failureRisk': failureRisk,
      'labourRate': labourRate,
      'pricingMarkupPercent': pricingMarkupPercent,
      'pricingSetupFee': pricingSetupFee,
      'pricingRoundingMode': pricingRoundingMode,
      'currencySymbol': currencySymbol,
      'currencyPosition': currencyPosition,
      'currencySpacing': currencySpacing,
    };
  }
}
