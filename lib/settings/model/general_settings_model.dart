class GeneralSettingsModel {
  const GeneralSettingsModel({
    required this.electricityCost,
    required this.wattage,
    required this.activePrinter,
  });

  factory GeneralSettingsModel.fromMap(Map<String, dynamic> map) {
    return GeneralSettingsModel(
      electricityCost: (map['electricityCost'] ?? '0.0').toString(),
      wattage: (map['wattage'] ?? '0').toString(),
      activePrinter: (map['activePrinter'] ?? '').toString(),
    );
  }

  factory GeneralSettingsModel.initial() {
    return const GeneralSettingsModel(
      electricityCost: '0',
      wattage: '0',
      activePrinter: '',
    );
  }

  final String electricityCost;
  final String wattage;
  final String activePrinter;

  Map<String, dynamic> toMap() {
    return {
      'electricityCost': electricityCost,
      'wattage': wattage,
      'activePrinter': activePrinter,
    };
  }

  GeneralSettingsModel copyWith({
    String? electricityCost,
    String? wattage,
    String? activePrinter,
  }) {
    return GeneralSettingsModel(
      electricityCost: electricityCost ?? this.electricityCost,
      wattage: wattage ?? this.wattage,
      activePrinter: activePrinter ?? this.activePrinter,
    );
  }

  @override
  String toString() =>
      'GeneralSettingsModel(electricityCost: $electricityCost, wattage: $wattage, activePrinter: $activePrinter)';
}
