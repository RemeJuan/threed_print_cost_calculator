import 'package:freezed_annotation/freezed_annotation.dart';

part 'material_model.freezed.dart';

@freezed
abstract class MaterialModel with _$MaterialModel {
  const factory MaterialModel({
    required String id,
    required String name,
    required String cost,
    required String color,
    required String weight,
    required bool archived,
  }) = _MaterialModel;

  factory MaterialModel.fromMap(Map<String, dynamic> map, String key) {
    return MaterialModel(
      id: key,
      name: map['name'].toString(),
      cost: map['cost'].toString(),
      color: map['color'].toString(),
      weight: (map['weight'] ?? 0).toString(),
      archived: false,
    );
  }
}

extension MaterialModelX on MaterialModel {
  Map<String, dynamic> toMap() {
    return {'name': name, 'cost': cost, 'color': color, 'weight': weight};
  }
}
