import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_summary_calculator.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_pricing_state.dart';
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
    @Default(false) bool batchQuote,
    @Default(<Map<String, dynamic>>[])
    List<Map<String, dynamic>> batchQuoteItems,
    Map<String, dynamic>? batchQuoteSummary,
  }) = _HistoryModel;

  factory HistoryModel.batchQuote({
    required String name,
    required DateTime date,
    required BatchCostingState state,
    required BatchSummaryResult summary,
  }) {
    return HistoryModel(
      name: name,
      totalCost: summary.finalTotal,
      riskCost: _pricingValue(state.pricing.failureRisk),
      filamentCost: 0,
      electricityCost: 0,
      labourCost: 0,
      additionalCostAmount: summary.additionalCost,
      date: date,
      printer: state.batchPrinterId ?? kUnassignedLabel,
      material: state.batchMaterialId ?? kUnassignedLabel,
      weight: summary.totalWeightG,
      timeHours: _formatDuration(summary.totalPrintDuration),
      batchQuote: true,
      batchQuoteItems: summary.items.map(_batchItemToMap).toList(),
      batchQuoteSummary: {
        'itemCount': summary.itemCount,
        'totalQuantity': summary.totalQuantity,
        'totalWeightG': summary.totalWeightG,
        'totalPrintDurationMinutes': summary.totalPrintDuration.inMinutes,
        'finalTotal': summary.finalTotal,
        'printerAssignmentMode': state.printerAssignmentMode.name,
        'materialAssignmentMode': state.materialAssignmentMode.name,
        'batchPrinterId': state.batchPrinterId,
        'batchMaterialId': state.batchMaterialId,
        'pricing': {
          'failureRisk': _pricingFieldToMap(state.pricing.failureRisk),
          'markupPercent': _pricingFieldToMap(state.pricing.markupPercent),
          'labourRate': _pricingFieldToMap(state.pricing.labourRate),
          'additionalCostAmount': _pricingFieldToMap(
            state.pricing.additionalCostAmount,
          ),
        },
      },
    );
  }

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
      batchQuote: map['batchQuote'] == true,
      batchQuoteItems: _parseMapList(map['batchQuoteItems']),
      batchQuoteSummary: _parseMap(map['batchQuoteSummary']),
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

  static List<Map<String, dynamic>> _parseMapList(dynamic raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => e.map((k, v) => MapEntry(k.toString(), v)))
        .toList();
  }

  static Map<String, dynamic>? _parseMap(dynamic raw) {
    if (raw is! Map) return null;
    return raw.map((k, v) => MapEntry(k.toString(), v));
  }

  static Map<String, dynamic> _batchItemToMap(
    BatchSummaryItemBreakdown breakdown,
  ) {
    return {
      'id': breakdown.item.id,
      'name': breakdown.item.displayName,
      'quantity': breakdown.totalQuantity,
      'printerId': breakdown.item.printerId,
      'materialId': breakdown.item.materialId,
      'pricingProfileId': breakdown.item.pricingProfileId,
      'totalWeightG': breakdown.totalWeightG,
      'totalPrintDurationMinutes': breakdown.totalPrintDuration.inMinutes,
      'baseCost': breakdown.baseCost,
      'additionalCost': breakdown.additionalCost,
      'finalTotal': breakdown.pricing.finalPrice,
      'pricing': {
        'markupPercent': breakdown.pricing.markupPercent,
        'setupFee': breakdown.pricing.setupFee,
        'subtotalBeforeRounding': breakdown.pricing.subtotalBeforeRounding,
        'roundingAdjustment': breakdown.pricing.roundingAdjustment,
      },
    };
  }

  static Map<String, dynamic> _pricingFieldToMap(BatchPricingFieldState field) {
    return {'value': field.value, 'scope': field.scope.name};
  }

  static num _pricingValue(BatchPricingFieldState field) {
    return num.tryParse(field.value.replaceAll(',', '.')) ?? 0;
  }

  static String _formatDuration(Duration duration) {
    final hours = duration.inHours.toString().padLeft(2, '0');
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    return '$hours:$minutes';
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
      'batchQuote': batchQuote,
      'batchQuoteItems': batchQuoteItems,
      'batchQuoteSummary': batchQuoteSummary,
    };
  }
}
