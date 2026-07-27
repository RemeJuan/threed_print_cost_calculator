import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/materials_csv_schema.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';

class MaterialsCsvExportService {
  MaterialsCsvExportService([this.ref]);

  final Ref? ref;

  Future<String> buildCsv() async {
    final materials = await ref!
        .read(materialsRepositoryProvider)
        .getMaterials();
    return generateCsv(materials);
  }

  String generateCsv(List<MaterialModel> materials) {
    final buffer = StringBuffer()..writeln(materialsCsvHeader);
    for (final material in materials) {
      buffer.writeln(
        [
          _quote(material.id),
          _quote(material.name),
          _quote(material.brand),
          _quote(material.materialType),
          _quote(material.color),
          _quote(material.colorHex),
          _quote(material.originalWeight),
          _quote(material.remainingWeight),
          _quote(material.cost),
          _quote(material.autoDeductEnabled),
          _quote(material.archived),
          _quote(material.notes),
        ].join(','),
      );
    }
    return buffer.toString();
  }
}

final materialsCsvExportServiceProvider = Provider<MaterialsCsvExportService>((
  ref,
) {
  return MaterialsCsvExportService(ref);
});

String _quote(Object? value) {
  final text = value?.toString() ?? '';
  final spreadsheetSafe = RegExp(r'^[=+\-@]').hasMatch(text) ? "'$text" : text;
  final escaped = spreadsheetSafe.replaceAll('"', '""');
  return '"$escaped"';
}
