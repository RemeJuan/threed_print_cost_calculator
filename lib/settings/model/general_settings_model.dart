import 'package:freezed_annotation/freezed_annotation.dart';

part 'general_settings_model.freezed.dart';

@freezed
abstract class GeneralSettingsModel with _$GeneralSettingsModel {
  const factory GeneralSettingsModel({
    required String electricityCost,
    required String wattage,
    required String activePrinter,
    required String selectedMaterial,
    required String wearAndTear,
    required String failureRisk,
    required String labourRate,
  }) = _GeneralSettingsModel;

  factory GeneralSettingsModel.fromMap(Map<String, dynamic> map) {
    return GeneralSettingsModel(
      electricityCost: (map['electricityCost'] ?? '').toString(),
      wattage: (map['wattage'] ?? '').toString(),
      activePrinter: (map['activePrinter'] ?? '').toString(),
      selectedMaterial: (map['selectedMaterial'] ?? '').toString(),
      wearAndTear: (map['wearAndTear'] ?? '').toString(),
      failureRisk: (map['failureRisk'] ?? '').toString(),
      labourRate: (map['labourRate'] ?? '').toString(),
    );
  }

  factory GeneralSettingsModel.initial() {
    return const GeneralSettingsModel(
      electricityCost: '',
      wattage: '',
      activePrinter: '',
      selectedMaterial: '',
      wearAndTear: '',
      failureRisk: '',
      labourRate: '',
    );
  }
}

extension GeneralSettingsModelX on GeneralSettingsModel {
  Map<String, dynamic> toMap() {
    return {
      'electricityCost': electricityCost,
      'wattage': wattage,
      'activePrinter': activePrinter,
      'selectedMaterial': selectedMaterial,
      'wearAndTear': wearAndTear,
      'failureRisk': failureRisk,
      'labourRate': labourRate,
    };
  }
}
