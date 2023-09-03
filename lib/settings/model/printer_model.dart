class PrinterModel {
  PrinterModel(
      {required this.name,
      required this.bedSize,
      required this.wattage,
      required this.archived});

  factory PrinterModel.fromMap(Map<String, dynamic> map) {
    return PrinterModel(
      name: map['name'] as String,
      bedSize: map['bedSize'] as String,
      wattage: map['wattage'] as String,
      archived: false, //map['archived'] as bool,
    );
  }

  String name;
  String bedSize;
  String wattage;
  bool archived;

  PrinterModel copyWith({
    String? name,
    String? bedSize,
    String? wattage,
    bool? archived,
  }) {
    return PrinterModel(
      name: name ?? this.name,
      bedSize: bedSize ?? this.bedSize,
      wattage: wattage ?? this.wattage,
      archived: archived ?? this.archived,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bedSize': bedSize,
      'wattage': wattage,
      'archived': archived
    };
  }

  @override
  String toString() {
    return 'PrinterModel('
        'name: $name, '
        'bedSize: $bedSize, '
        'wattage: $wattage, '
        'archived: $archived'
        ')';
  }
}
