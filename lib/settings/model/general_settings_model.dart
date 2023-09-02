class GeneralSettingsModel {
  const GeneralSettingsModel({
    required this.electricityCost,
    required this.wattage,
  });

  factory GeneralSettingsModel.fromMap(Map<String, dynamic> map) {
    return GeneralSettingsModel(
      electricityCost: map['electricityCost'] as double,
      wattage: map['wattage'] as int,
    );
  }

  final double electricityCost;
  final int wattage;

  Map<String, dynamic> toMap() {
    return {
      'electricityCost': electricityCost,
    };
  }

  GeneralSettingsModel copyWith({
    double? electricityCost,
    int? wattage,
  }) {
    return GeneralSettingsModel(
      electricityCost: electricityCost ?? this.electricityCost,
      wattage: wattage ?? this.wattage,
    );
  }

  @override
  String toString() =>
      'GeneralSettingsModel(electricityCost: $electricityCost, wattage: $wattage)';
}
