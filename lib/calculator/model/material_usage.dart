import 'package:equatable/equatable.dart';

/// Represents a single material used in a multi-material print job.
///
/// Stores both the calculation inputs (spoolWeight, spoolCost) and the
/// computed filamentCost so that history records can show per-material
/// cost breakdowns without needing to re-query the materials database.
class MaterialUsage extends Equatable {
  final String materialId;
  final String materialName;

  /// Grams of this material consumed in the print (integer to avoid float drift).
  final int weightGrams;

  /// Total weight of the source spool/resin unit in grams (for calculation).
  final num spoolWeight;

  /// Total cost of the source spool/resin unit (for calculation).
  final num spoolCost;

  /// Computed filament cost for this material usage.
  /// Populated during [submit] and stored in history for display.
  final num filamentCost;

  const MaterialUsage({
    required this.materialId,
    required this.materialName,
    required this.weightGrams,
    required this.spoolWeight,
    required this.spoolCost,
    this.filamentCost = 0,
  });

  MaterialUsage copyWith({
    String? materialId,
    String? materialName,
    int? weightGrams,
    num? spoolWeight,
    num? spoolCost,
    num? filamentCost,
  }) {
    return MaterialUsage(
      materialId: materialId ?? this.materialId,
      materialName: materialName ?? this.materialName,
      weightGrams: weightGrams ?? this.weightGrams,
      spoolWeight: spoolWeight ?? this.spoolWeight,
      spoolCost: spoolCost ?? this.spoolCost,
      filamentCost: filamentCost ?? this.filamentCost,
    );
  }

  factory MaterialUsage.fromMap(Map<String, dynamic> map) {
    return MaterialUsage(
      materialId: map['materialId']?.toString() ?? '',
      materialName: map['materialName']?.toString() ?? '',
      weightGrams: (map['weightGrams'] as num?)?.toInt() ?? 0,
      spoolWeight: map['spoolWeight'] as num? ?? 0,
      spoolCost: map['spoolCost'] as num? ?? 0,
      filamentCost: map['filamentCost'] as num? ?? 0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'materialId': materialId,
      'materialName': materialName,
      'weightGrams': weightGrams,
      'spoolWeight': spoolWeight,
      'spoolCost': spoolCost,
      'filamentCost': filamentCost,
    };
  }

  @override
  List<Object> get props => [
    materialId,
    materialName,
    weightGrams,
    spoolWeight,
    spoolCost,
    filamentCost,
  ];
}
