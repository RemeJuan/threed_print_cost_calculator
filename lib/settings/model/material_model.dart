class MaterialModel {
  MaterialModel({
    required this.name,
    required this.cost,
    required this.color,
  });

  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      name: map['name'] as String,
      cost: map['cost'] as String,
      color: map['color'] as String,
    );
  }

  String name;
  String cost;
  String color;

  MaterialModel copyWith({
    String? name,
    String? cost,
    String? color,
  }) {
    return MaterialModel(
      name: name ?? this.name,
      cost: cost ?? this.cost,
      color: color ?? this.color,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cost': cost,
      'color': color,
    };
  }

  @override
  String toString() {
    return 'MaterialModel(name: $name, cost: $cost, color: $color)';
  }
}
