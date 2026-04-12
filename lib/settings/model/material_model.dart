import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

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
    @Default(false) bool autoDeductEnabled,
    @Default(0) double originalWeight,
    @Default(0) double remainingWeight,
  }) = _MaterialModel;

  factory MaterialModel.fromMap(Map<String, dynamic> map, String key) {
    final parsedWeight = parseLocalizedNum(map['weight']).toDouble();
    final hasOriginalWeight = map.containsKey('originalWeight');
    final hasRemainingWeight = map.containsKey('remainingWeight');
    final parsedOriginal = hasOriginalWeight
        ? parseLocalizedNum(map['originalWeight']).toDouble()
        : parsedWeight;
    final parsedRemaining = hasRemainingWeight
        ? parseLocalizedNum(map['remainingWeight']).toDouble()
        : parsedWeight;

    return MaterialModel(
      id: key,
      name: map['name'].toString(),
      cost: map['cost'].toString(),
      color: map['color'].toString(),
      weight: (map['weight'] ?? 0).toString(),
      archived: false,
      autoDeductEnabled: map['autoDeductEnabled'] == true,
      originalWeight: parsedOriginal,
      remainingWeight: parsedRemaining,
    );
  }
}

extension MaterialModelX on MaterialModel {
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'cost': cost,
      'color': color,
      'weight': weight,
      'autoDeductEnabled': autoDeductEnabled,
      'originalWeight': originalWeight,
      'remainingWeight': remainingWeight,
    };
  }
}
