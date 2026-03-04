import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:threed_print_cost_calculator/shared/constants.dart';

part 'history_model.freezed.dart';

@freezed
abstract class HistoryModel with _$HistoryModel {
  const factory HistoryModel({
    required String name,
    required num totalCost,
    required num riskCost,
    required num filamentCost,
    required num electricityCost,
    required num labourCost,
    required DateTime date,
    required String printer,
    required String material,
    required num weight,
    @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> materialUsages,
    required String timeHours,
  }) = _HistoryModel;

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    final dynamic dateValue = map['date'];
    DateTime parsedDate;
    if (dateValue is DateTime) {
      parsedDate = dateValue;
    } else if (dateValue is String) {
      parsedDate = DateTime.parse(dateValue);
    } else {
      parsedDate = DateTime.parse(dateValue.toString());
    }

    return HistoryModel(
      name: map['name']?.toString() ?? '',
      totalCost: map['totalCost'] as num,
      riskCost: map['riskCost'] as num,
      filamentCost: map['filamentCost'] as num,
      electricityCost: map['electricityCost'] as num,
      labourCost: map['labourCost'] as num,
      date: parsedDate,
      printer: map['printer']?.toString() ?? kUnassignedLabel,
      material: map['material']?.toString() ?? kUnassignedLabel,
      weight: map['weight'] as num? ?? 0.0,
      materialUsages: _parseMaterialUsages(map['materialUsages']),
      timeHours: map['timeHours']?.toString() ?? '00:00',
    );
  }

  static List<Map<String, dynamic>> _parseMaterialUsages(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }
}

extension HistoryModelX on HistoryModel {
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'totalCost': totalCost,
      'riskCost': riskCost,
      'filamentCost': filamentCost,
      'electricityCost': electricityCost,
      'labourCost': labourCost,
      'date': date.toIso8601String(),
      'printer': printer,
      'material': material,
      'weight': weight,
      'materialUsages': materialUsages,
      'timeHours': timeHours,
    };
  }
}
