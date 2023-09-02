

class GeneralSettingsModel {
  const GeneralSettingsModel({
    required this.electricityCost,
    required this.wattage,
  });

  factory GeneralSettingsModel.fromMap(Map<String, dynamic> map) {
    return GeneralSettingsModel(
      electricityCost: (map['electricityCost'] ?? '0.0').toString(),
      wattage: (map['wattage'] ?? '0').toString(),
    );
  }

  factory GeneralSettingsModel.initial() {
    return const GeneralSettingsModel(electricityCost: '0', wattage: '0');
  }

  final String electricityCost;
  final String wattage;

  Map<String, dynamic> toMap() {
    return {
      'electricityCost': electricityCost,
      'wattage': wattage,
    };
  }

  GeneralSettingsModel copyWith({
    String? electricityCost,
    String? wattage,
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
