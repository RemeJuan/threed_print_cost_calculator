import 'package:freezed_annotation/freezed_annotation.dart';

part 'printer_model.freezed.dart';

@freezed
abstract class PrinterModel with _$PrinterModel {
  const factory PrinterModel({
    required String id,
    required String name,
    required String bedSize,
    required String wattage,
    required bool archived,
  }) = _PrinterModel;

  factory PrinterModel.fromMap(Map<String, dynamic> map, String key) {
    return PrinterModel(
      id: key,
      name: map['name'].toString(),
      bedSize: map['bedSize'].toString(),
      wattage: map['wattage'].toString(),
      archived: false,
    );
  }
}

extension PrinterModelX on PrinterModel {
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'bedSize': bedSize,
      'wattage': wattage,
      'archived': archived,
    };
  }
}
