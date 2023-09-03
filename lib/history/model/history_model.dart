class HistoryModel {
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
      totalCost: map['totalCost'] as String,
      riskCost: map['riskCost'] as String,
      filamentCost: map['filamentCost'] as String,
      electricityCost: map['electricityCost'] as String,
      labourCost: map['labourCost'] as String,
      date: map['date'] as String,
    );
  }

  HistoryModel copyWith({
    String? name,
    String? totalCost,
    String? riskCost,
    String? filamentCost,
    String? electricityCost,
    String? labourCost,
    String? date,
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

  final String name;
  final String totalCost;
  final String riskCost;
  final String filamentCost;
  final String electricityCost;
  final String labourCost;
  final String date;

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
