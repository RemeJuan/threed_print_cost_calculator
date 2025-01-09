class HistoryModel {
  final String name;
  final num totalCost;
  final num riskCost;
  final num filamentCost;
  final num electricityCost;
  final num labourCost;
  final DateTime date;

  const HistoryModel({
    required this.name,
    required this.totalCost,
    required this.riskCost,
    required this.filamentCost,
    required this.electricityCost,
    required this.labourCost,
    required this.date,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    return HistoryModel(
      name: map['name'] as String,
      totalCost: map['totalCost'] as double,
      riskCost: map['riskCost'] as double,
      filamentCost: map['filamentCost'] as double,
      electricityCost: map['electricityCost'] as double,
      labourCost: map['labourCost'] as double,
      date: DateTime.parse(map['date']),
    );
  }

  HistoryModel copyWith({
    String? name,
    double? totalCost,
    double? riskCost,
    double? filamentCost,
    double? electricityCost,
    double? labourCost,
    DateTime? date,
  }) {
    return HistoryModel(
      name: name ?? this.name,
      totalCost: totalCost ?? this.totalCost,
      riskCost: riskCost ?? this.riskCost,
      filamentCost: filamentCost ?? this.filamentCost,
      electricityCost: electricityCost ?? this.electricityCost,
      labourCost: labourCost ?? this.labourCost,
      date: date ?? this.date,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'totalCost': totalCost,
      'riskCost': riskCost,
      'filamentCost': filamentCost,
      'electricityCost': electricityCost,
      'labourCost': labourCost,
      'date': date,
    };
  }

  @override
  String toString() {
    return 'HistoryModel{'
        'name: $name, '
        'totalCost: $totalCost, '
        'riskCost: $riskCost, '
        'filamentCost: $filamentCost, '
        'electricityCost: $electricityCost'
        '}';
  }
}
