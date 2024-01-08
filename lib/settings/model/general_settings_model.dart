class GeneralSettingsModel {
  const GeneralSettingsModel({
    required this.electricityCost,
    required this.wattage,
    required this.activePrinter,
    required this.selectedMaterial,
  });

  factory GeneralSettingsModel.fromMap(Map<String, dynamic> map) {
    return GeneralSettingsModel(
      electricityCost: (map['electricityCost'] ?? '').toString(),
      wattage: (map['wattage'] ?? '').toString(),
      activePrinter: (map['activePrinter'] ?? '').toString(),
      selectedMaterial: (map['selectedMaterial'] ?? '').toString(),
    );
  }

  factory GeneralSettingsModel.initial() {
    return const GeneralSettingsModel(
      electricityCost: '',
      wattage: '',
      activePrinter: '',
      selectedMaterial: '',
    );
  }

  final String electricityCost;
  final String wattage;
  final String activePrinter;
  final String selectedMaterial;

  Map<String, dynamic> toMap() {
    return {
      'electricityCost': electricityCost,
      'wattage': wattage,
      'activePrinter': activePrinter,
      'selectedMaterial': selectedMaterial,
    };
  }

  GeneralSettingsModel copyWith({
    String? electricityCost,
    String? wattage,
    String? activePrinter,
    String? selectedMaterial,
  }) {
    return GeneralSettingsModel(
      electricityCost: electricityCost ?? this.electricityCost,
      wattage: wattage ?? this.wattage,
      activePrinter: activePrinter ?? this.activePrinter,
      selectedMaterial: selectedMaterial ?? this.selectedMaterial,
    );
  }

  @override
  String toString() => 'GeneralSettingsModel('
      'electricityCost: $electricityCost, '
      'wattage: $wattage, '
      'activePrinter: $activePrinter'
      'selectedMaterial: $selectedMaterial'
      ')';
}
