import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/materials_csv_schema.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_generation.dart';

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
          quoteCsvCell(sanitizeCsvSpreadsheetCell(material.id)),
          quoteCsvCell(sanitizeCsvSpreadsheetCell(material.name)),
          quoteCsvCell(sanitizeCsvSpreadsheetCell(material.brand)),
          quoteCsvCell(sanitizeCsvSpreadsheetCell(material.materialType)),
          quoteCsvCell(sanitizeCsvSpreadsheetCell(material.color)),
          quoteCsvCell(sanitizeCsvSpreadsheetCell(material.colorHex)),
          quoteCsvCell(
            sanitizeCsvSpreadsheetCell(material.originalWeight.toString()),
          ),
          quoteCsvCell(
            sanitizeCsvSpreadsheetCell(material.remainingWeight.toString()),
          ),
          quoteCsvCell(sanitizeCsvSpreadsheetCell(material.cost)),
          quoteCsvCell(
            sanitizeCsvSpreadsheetCell(material.autoDeductEnabled.toString()),
          ),
          quoteCsvCell(
            sanitizeCsvSpreadsheetCell(material.archived.toString()),
          ),
          quoteCsvCell(sanitizeCsvSpreadsheetCell(material.notes)),
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
