import 'package:threed_print_cost_calculator/shared/constants.dart';

class MaterialUsageInput {
  const MaterialUsageInput({
    required this.materialId,
    required this.materialName,
    required this.costPerKg,
    required this.weightGrams,
  });

  final String materialId;
  final String materialName;
  final num costPerKg;
  final int weightGrams;

  MaterialUsageInput copyWith({
    String? materialId,
    String? materialName,
    num? costPerKg,
    int? weightGrams,
  }) {
    return MaterialUsageInput(
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      costPerKg: costPerKg ?? this.costPerKg,
      weightGrams: weightGrams ?? this.weightGrams,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'costPerKg': costPerKg,
      'weightGrams': weightGrams,
    };
  }

  factory MaterialUsageInput.fromMap(Map<String, dynamic> map) {
    // Normalize strings and accept comma decimals
    String normalize(Object? v) =>
        v?.toString().trim().replaceAll(',', '.') ?? '';

    final materialId = map['materialId']?.toString() ?? '';
    final materialName = map['materialName']?.toString() ?? kUnassignedLabel;

    final costStr = normalize(map['costPerKg']);
    final cost = num.tryParse(costStr) ?? 0;

    final weightStr = normalize(map['weightGrams']);
    int weight = 0;
    if (weightStr.isNotEmpty) {
      // Accept decimal weights like "120.0" and round to nearest int
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
