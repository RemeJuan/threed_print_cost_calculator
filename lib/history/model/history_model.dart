class HistoryModel {
  final String name;
  final num totalCost;
  final num riskCost;
  final num filamentCost;
  final num electricityCost;
  final num labourCost;
  final DateTime date;
  final String printer;
  final String material;
  final num weight; // grams
  final List<Map<String, dynamic>> materialUsages;
  final String timeHours; // stored as "hh:mm"

  const HistoryModel({
    required this.name,
    required this.totalCost,
    required this.riskCost,
    required this.filamentCost,
    required this.electricityCost,
    required this.labourCost,
    required this.date,
    required this.printer,
    required this.material,
    required this.weight,
    this.materialUsages = const [],
    required this.timeHours,
  });

  factory HistoryModel.fromMap(Map<String, dynamic> map) {
    // robust date parsing: accept String or DateTime
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
      printer: map['printer']?.toString() ?? 'NotSelected',
      material: map['material']?.toString() ?? 'NotSelected',
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

  HistoryModel copyWith({
    String? name,
    num? totalCost,
    num? riskCost,
    num? filamentCost,
    num? electricityCost,
    num? labourCost,
    DateTime? date,
    String? printer,
    String? material,
    num? weight,
    List<Map<String, dynamic>>? materialUsages,
    String? timeHours,
  }) {
    return HistoryModel(
      name: name ?? this.name,
      totalCost: totalCost ?? this.totalCost,
      riskCost: riskCost ?? this.riskCost,
      filamentCost: filamentCost ?? this.filamentCost,
      electricityCost: electricityCost ?? this.electricityCost,
      labourCost: labourCost ?? this.labourCost,
      date: date ?? this.date,
      printer: printer ?? this.printer,
      material: material ?? this.material,
      weight: weight ?? this.weight,
      materialUsages: materialUsages ?? this.materialUsages,
      timeHours: timeHours ?? this.timeHours,
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
      'date': date.toIso8601String(),
      'printer': printer,
      'material': material,
      'weight': weight,
      'materialUsages': materialUsages,
      'timeHours': timeHours,
    };
  }

  @override
  String toString() {
    return 'HistoryModel{'
        'name: $name, '
        'totalCost: $totalCost, '
        'riskCost: $riskCost, '
        'filamentCost: $filamentCost, '
        'electricityCost: $electricityCost, '
        'printer: $printer, '
        'material: $material, '
        'weight: $weight, '
        'timeHours: $timeHours'
        '}';
  }
}
