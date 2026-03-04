import 'package:freezed_annotation/freezed_annotation.dart';

part 'calculation_results_state.freezed.dart';

@freezed
abstract class CalculationResult with _$CalculationResult {
  const factory CalculationResult({
    required num electricity,
    required num filament,
    required num risk,
    required num labour,
    required num total,
  }) = _CalculationResult;

  factory CalculationResult.empty() {
    return const CalculationResult(
      electricity: 0.0,
      filament: 0.0,
      risk: 0.0,
      labour: 0.0,
      total: 0.0,
    );
  }
}
