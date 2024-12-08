class GeneralSettingsModel {
  final num electricityCost;
  final num wattage;
  final String activePrinter;
  final String selectedMaterial;

  const GeneralSettingsModel({
    required this.electricityCost,
    required this.wattage,
    required this.activePrinter,
    required this.selectedMaterial,
  });

  factory GeneralSettingsModel.fromMap(Map<String, dynamic> map) {
    return GeneralSettingsModel(
      electricityCost: num.parse(map['electricityCost'].toString()) ?? 0.0,
      wattage: num.parse(map['wattage'].toString()) ?? 0,
      activePrinter: map['activePrinter'],
      selectedMaterial: map['selectedMaterial'],
    );
  }

  factory GeneralSettingsModel.initial() {
    return const GeneralSettingsModel(
      electricityCost: 0.0,
      wattage: 0,
      activePrinter: '',
      selectedMaterial: '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'electricityCost': electricityCost,
      'wattage': wattage,
      'activePrinter': activePrinter,
      'selectedMaterial': selectedMaterial,
    };
  }

  GeneralSettingsModel copyWith({
    num? electricityCost,
    num? wattage,
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
