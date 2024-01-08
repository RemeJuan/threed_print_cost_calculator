class MaterialModel {
  MaterialModel({
    required this.id,
    required this.name,
    required this.cost,
    required this.color,
    required this.weight,
    required this.archived,
  });

  factory MaterialModel.fromMap(Map<String, dynamic> map, String key) {
    return MaterialModel(
      id: key,
      name: map['name'] as String,
      cost: map['cost'] as String,
      color: map['color'] as String,
      weight: map['weight'] ?? '0' as String,
      archived: false, //map['archived'] as bool,
    );
  }

  String id;
  String name;
  String cost;
  String color;
  String weight;
  bool archived;

  MaterialModel copyWith({
    String? id,
    String? name,
    String? cost,
    String? color,
    String? weight,
    bool? archived,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      name: name ?? this.name,
      cost: cost ?? this.cost,
      color: color ?? this.color,
      weight: weight ?? this.weight,
      archived: archived ?? this.archived,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cost': cost,
      'color': color,
      'weight': weight,
    };
  }

  @override
  String toString() {
    return 'MaterialModel(name: $name, cost: $cost, color: $color, weight: $weight)';
  }
}
