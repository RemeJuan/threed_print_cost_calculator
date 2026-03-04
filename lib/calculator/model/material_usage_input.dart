import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:threed_print_cost_calculator/shared/constants.dart';

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
    String normalize(Object? v) =>
        v?.toString().trim().replaceAll(',', '.') ?? '';

    final materialId = map['materialId']?.toString() ?? '';
    final materialName = map['materialName']?.toString() ?? kUnassignedLabel;

    final costStr = normalize(map['costPerKg']);
    final cost = num.tryParse(costStr) ?? 0;

    final weightStr = normalize(map['weightGrams']);
    int weight = 0;
    if (weightStr.isNotEmpty) {
      final parsedDouble = double.tryParse(weightStr);
      if (parsedDouble != null) {
        weight = parsedDouble.round();
      } else {
        weight = int.tryParse(weightStr) ?? 0;
      }
    }

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
