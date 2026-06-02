import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:threed_print_cost_calculator/shared/constants.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

part 'material_usage_input.freezed.dart';

@freezed
abstract class MaterialUsageInput with _$MaterialUsageInput {
  const factory MaterialUsageInput({
    required String materialId,
    required String materialName,
    required num costPerKg,
    required int weightGrams,
    @Default(false) bool isUnsaved,
    @Default(0) num unsavedSpoolWeight,
    @Default(0) num unsavedSpoolCost,
  }) = _MaterialUsageInput;

  factory MaterialUsageInput.fromMap(Map<String, dynamic> map) {
    final materialId = map['materialId']?.toString() ?? '';
    final materialName = map['materialName']?.toString() ?? kUnassignedLabel;

    final cost = parseLocalizedNumOrFallback(map['costPerKg']);
    final weight = parseLocalizedInt(map['weightGrams'], round: true);

    return MaterialUsageInput(
      materialId: materialId,
      materialName: materialName,
      costPerKg: cost,
      weightGrams: weight,
      isUnsaved: map['isUnsaved'] == true,
      unsavedSpoolWeight: parseLocalizedNumOrFallback(
        map['unsavedSpoolWeight'],
      ),
      unsavedSpoolCost: parseLocalizedNumOrFallback(map['unsavedSpoolCost']),
    );
  }

  static const unsavedMaterialIdPrefix = '__unsaved__';
}

extension MaterialUsageInputX on MaterialUsageInput {
  Map<String, dynamic> toMap() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'costPerKg': costPerKg,
      'weightGrams': weightGrams,
      'isUnsaved': isUnsaved,
      'unsavedSpoolWeight': unsavedSpoolWeight,
      'unsavedSpoolCost': unsavedSpoolCost,
    };
  }
}
