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
    return MaterialUsageInput(
      materialId: map['materialId']?.toString() ?? '',
      materialName: map['materialName']?.toString() ?? 'NotSelected',
      costPerKg: num.tryParse(map['costPerKg']?.toString() ?? '0') ?? 0,
      weightGrams:
          int.tryParse(map['weightGrams']?.toString() ?? '0') ?? 0,
    );
  }
}
