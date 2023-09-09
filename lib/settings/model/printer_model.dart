class PrinterModel {
  PrinterModel({
    required this.id,
    required this.name,
    required this.bedSize,
    required this.wattage,
    required this.archived,
  });

  factory PrinterModel.fromMap(Map<String, dynamic> map, String key) {
    return PrinterModel(
      id: key,
      name: map['name'] as String,
      bedSize: map['bedSize'] as String,
      wattage: map['wattage'] as String,
      archived: false, //map['archived'] as bool,
    );
  }

  String id;
  String name;
  String bedSize;
  String wattage;
  bool archived;

  PrinterModel copyWith({
    String? id,
    String? name,
    String? bedSize,
    String? wattage,
    bool? archived,
  }) {
    return PrinterModel(
      id: id ?? this.id,
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
      'archived': archived,
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
