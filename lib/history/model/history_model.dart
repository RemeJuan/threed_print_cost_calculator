import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:threed_print_cost_calculator/shared/constants.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

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
    @Default(0) num additionalCostAmount,
    String? additionalCostNote,
    required DateTime date,
    required String printer,
    required String material,
    required num weight,
    @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> materialUsages,
    required String timeHours,
    @Default(false) bool importedFromGcode,
    num? pricingMarkupPercent,
    num? pricingMarkupAmount,
    num? pricingSetupFee,
    String? pricingRoundingMode,
    num? pricingSubtotalBeforeRounding,
    num? pricingRoundingAdjustment,
    num? finalPrice,
    bool? pricingUsedOverrides,
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
      totalCost: parseLocalizedNumOrFallback(map['totalCost']),
      riskCost: parseLocalizedNumOrFallback(map['riskCost']),
      filamentCost: parseLocalizedNumOrFallback(map['filamentCost']),
      electricityCost: parseLocalizedNumOrFallback(map['electricityCost']),
      labourCost: parseLocalizedNumOrFallback(map['labourCost']),
      additionalCostAmount: _parseNullableNum(map['additionalCostAmount']) ?? 0,
      additionalCostNote: map['additionalCostNote']?.toString(),
      date: parsedDate,
      printer: map['printer']?.toString() ?? kUnassignedLabel,
      material: map['material']?.toString() ?? kUnassignedLabel,
      weight: parseLocalizedNumOrFallback(map['weight']),
      materialUsages: _parseMaterialUsages(map['materialUsages']),
      timeHours: map['timeHours']?.toString() ?? '00:00',
      importedFromGcode: map['importedFromGcode'] == true,
      pricingMarkupPercent: _parseNullableNum(map['pricingMarkupPercent']),
      pricingMarkupAmount: _parseNullableNum(map['pricingMarkupAmount']),
      pricingSetupFee: _parseNullableNum(map['pricingSetupFee']),
      pricingRoundingMode: map['pricingRoundingMode']?.toString(),
      pricingSubtotalBeforeRounding: _parseNullableNum(
        map['pricingSubtotalBeforeRounding'],
      ),
      pricingRoundingAdjustment: _parseNullableNum(
        map['pricingRoundingAdjustment'],
      ),
      finalPrice: _parseNullableNum(map['finalPrice']),
      pricingUsedOverrides: map['pricingUsedOverrides'] == null
          ? null
          : map['pricingUsedOverrides'] == true,
    );
  }

  static num? _parseNullableNum(dynamic raw) {
    if (raw == null) return null;
    return parseLocalizedNumOrFallback(raw);
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
      'additionalCostAmount': additionalCostAmount,
      'additionalCostNote': additionalCostNote,
      'date': date.toIso8601String(),
      'printer': printer,
      'material': material,
      'weight': weight,
      'materialUsages': materialUsages,
      'timeHours': timeHours,
      'importedFromGcode': importedFromGcode,
      'pricingMarkupPercent': pricingMarkupPercent,
      'pricingMarkupAmount': pricingMarkupAmount,
      'pricingSetupFee': pricingSetupFee,
      'pricingRoundingMode': pricingRoundingMode,
      'pricingSubtotalBeforeRounding': pricingSubtotalBeforeRounding,
      'pricingRoundingAdjustment': pricingRoundingAdjustment,
      'finalPrice': finalPrice,
      'pricingUsedOverrides': pricingUsedOverrides,
    };
  }
}
