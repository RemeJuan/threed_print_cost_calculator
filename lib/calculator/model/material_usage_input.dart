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
  }) = _MaterialUsageInput;

  factory MaterialUsageInput.fromMap(Map<String, dynamic> map) {
    final materialId = map['materialId']?.toString() ?? '';
    final materialName = map['materialName']?.toString() ?? kUnassignedLabel;

    final cost = parseLocalizedNum(map['costPerKg']);
    final weight = parseLocalizedInt(map['weightGrams'], round: true);

    return MaterialUsageInput(
      materialId: materialId,
      materialName: materialName,
      costPerKg: cost,
      weightGrams: weight,
    );
  }
}

extension MaterialUsageInputX on MaterialUsageInput {
  Map<String, dynamic> toMap() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'costPerKg': costPerKg,
      'weightGrams': weightGrams,
    };
  }
}
