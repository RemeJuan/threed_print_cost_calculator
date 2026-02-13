class GeneralSettingsModel {
  const GeneralSettingsModel({
    required this.electricityCost,
    required this.wattage,
    required this.activePrinter,
    required this.selectedMaterial,
    required this.wearAndTear,
    required this.failureRisk,
    required this.hourlyRate,
  });

  factory GeneralSettingsModel.fromMap(Map<String, dynamic> map) {
    return GeneralSettingsModel(
      electricityCost: (map['electricityCost'] ?? '').toString(),
      wattage: (map['wattage'] ?? '').toString(),
      activePrinter: (map['activePrinter'] ?? '').toString(),
      selectedMaterial: (map['selectedMaterial'] ?? '').toString(),
      wearAndTear: (map['wearAndTear'] ?? '').toString(),
      failureRisk: (map['failureRisk'] ?? '').toString(),
      hourlyRate: (map['hourlyRate'] ?? '').toString(),
    );
  }

  factory GeneralSettingsModel.initial() {
    return const GeneralSettingsModel(
      electricityCost: '',
      wattage: '',
      activePrinter: '',
      selectedMaterial: '',
      wearAndTear: '',
      failureRisk: '',
      hourlyRate: '',
    );
  }

  final String electricityCost;
  final String wattage;
  final String activePrinter;
  final String selectedMaterial;
  final String wearAndTear;
  final String failureRisk;
  final String hourlyRate;

  Map<String, dynamic> toMap() {
    return {
      'electricityCost': electricityCost,
      'wattage': wattage,
      'activePrinter': activePrinter,
      'selectedMaterial': selectedMaterial,
      'wearAndTear': wearAndTear,
      'failureRisk': failureRisk,
      'hourlyRate': hourlyRate,
    };
  }

  GeneralSettingsModel copyWith({
    String? electricityCost,
    String? wattage,
    String? activePrinter,
    String? selectedMaterial,
    String? wearAndTear,
    String? failureRisk,
    String? hourlyRate,
  }) {
    return GeneralSettingsModel(
      electricityCost: electricityCost ?? this.electricityCost,
      wattage: wattage ?? this.wattage,
      activePrinter: activePrinter ?? this.activePrinter,
      selectedMaterial: selectedMaterial ?? this.selectedMaterial,
      wearAndTear: wearAndTear ?? this.wearAndTear,
      failureRisk: failureRisk ?? this.failureRisk,
      hourlyRate: hourlyRate ?? this.hourlyRate,
    );
  }

  @override
  String toString() => 'GeneralSettingsModel('
      'electricityCost: $electricityCost, '
      'wattage: $wattage, '
      'activePrinter: $activePrinter, '
      'selectedMaterial: $selectedMaterial, '
      'wearAndTear: $wearAndTear, '
      'failureRisk: $failureRisk, '
      'hourlyRate: $hourlyRate'
      ')';
}
