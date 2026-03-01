/// Represents a single material's usage in a multi-material print.
///
/// Stores enough data to compute the filament cost for this usage
/// without requiring a live DB lookup during calculation.
class MaterialUsage {
  const MaterialUsage({
    required this.materialId,
    required this.materialName,
    required this.weightGrams,
    required this.spoolWeightGrams,
    required this.spoolCost,
  });

  factory MaterialUsage.fromMap(Map<String, dynamic> map) {
    return MaterialUsage(
      materialId: map['materialId']?.toString() ?? '',
      materialName: map['materialName']?.toString() ?? '',
      weightGrams: (map['weightGrams'] as num? ?? 0).toInt(),
      spoolWeightGrams: map['spoolWeightGrams'] as num? ?? 0,
      spoolCost: map['spoolCost'] as num? ?? 0,
    );
  }

  /// The material record key in the materials store.
  final String materialId;

  /// Human-readable name of the material (snapshot at time of adding).
  final String materialName;

  /// Weight of this material used in the print, in grams.
  final int weightGrams;

  /// Full spool/roll weight in grams (snapshot at time of adding).
  final num spoolWeightGrams;

  /// Cost of the full spool/roll (snapshot at time of adding).
  final num spoolCost;

  MaterialUsage copyWith({
    String? materialId,
    String? materialName,
    int? weightGrams,
    num? spoolWeightGrams,
    num? spoolCost,
  }) {
    return MaterialUsage(
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      weightGrams: weightGrams ?? this.weightGrams,
      spoolWeightGrams: spoolWeightGrams ?? this.spoolWeightGrams,
      spoolCost: spoolCost ?? this.spoolCost,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'weightGrams': weightGrams,
      'spoolWeightGrams': spoolWeightGrams,
      'spoolCost': spoolCost,
    };
  }

  @override
  String toString() {
    return 'MaterialUsage(materialName: $materialName, weightGrams: $weightGrams)';
  }
}
