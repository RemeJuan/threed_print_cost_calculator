import 'package:equatable/equatable.dart';

class CalculationResult extends Equatable {
  final num electricity;
  final num filament;
  final num risk;
  final num labour;
  final num total;

  const CalculationResult({
    required this.electricity,
    required this.filament,
    required this.risk,
    required this.labour,
    required this.total,
  });

  factory CalculationResult.empty() {
    return const CalculationResult(
      electricity: 0.0,
      filament: 0.0,
      risk: 0.0,
      labour: 0.0,
      total: 0.0,
    );
  }

  @override
  List<Object> get props => [electricity, filament, risk, labour, total];
}
