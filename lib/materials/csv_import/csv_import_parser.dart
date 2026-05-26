import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

const csvHeader =
    'name,brand,material_type,color,color_hex,spool_weight,remaining_weight,spool_cost,notes';
const sampleRow1 = 'PLA Pro+,Sunlu,PLA,Black,,1000,950,24.99,';
const sampleRow2 = 'PETG Black,Overture,PETG,White,,1000,950,24.99,';

class ImportRow {
  final int lineNumber;
  final String name;
  final String brand;
  final String materialType;
  final String color;
  final String colorHex;
  final double spoolWeight;
  final double remainingWeight;
  final double cost;
  final String notes;
  final List<String> errors;

  const ImportRow({
    required this.lineNumber,
    required this.name,
    required this.brand,
    required this.materialType,
    required this.color,
    required this.colorHex,
    required this.spoolWeight,
    required this.remainingWeight,
    required this.cost,
    required this.notes,
    required this.errors,
  });
}

List<String> parseCsvLine(String line) {
  final result = <String>[];
  var current = StringBuffer();
  var inQuotes = false;

  for (var i = 0; i < line.length; i++) {
    final char = line[i];
    if (char == '"') {
      if (inQuotes && i + 1 < line.length && line[i + 1] == '"') {
        current.write('"');
        i++;
      } else {
        inQuotes = !inQuotes;
      }
    } else if (char == ',' && !inQuotes) {
      result.add(current.toString());
      current = StringBuffer();
    } else {
      current.write(char);
    }
  }
  result.add(current.toString());
  return result;
}

ImportRow parseImportRow(
  List<String> values,
  Map<String, int> colIndex,
  int lineNumber,
  AppLocalizations l10n,
) {
  String val(String col) {
    final idx = colIndex[col];
    if (idx == null || idx >= values.length) return '';
    return values[idx].trim();
  }

  final name = val('name');
  final brand = val('brand');
  final materialType = val('material_type');
  final color = val('color');
  final colorHex = val('color_hex');
  final spoolWeightStr = val('spool_weight');
  final remainingWeightStr = val('remaining_weight');
  final costStr = val('spool_cost');
  final notes = val('notes');

  final errors = <String>[];
  if (name.isEmpty) errors.add(l10n.csvNameRequiredError);
  if (color.isEmpty) errors.add(l10n.csvColorRequiredError);

  final spoolWeight = double.tryParse(spoolWeightStr) ?? 0;
  if (spoolWeightStr.isEmpty) {
    errors.add(l10n.csvSpoolWeightRequiredError);
  } else if (spoolWeight <= 0) {
    errors.add(l10n.csvSpoolWeightPositiveError);
  }

  final cost = double.tryParse(costStr) ?? 0;
  if (costStr.isEmpty) {
    errors.add(l10n.csvCostRequiredError);
  } else if (cost <= 0) {
    errors.add(l10n.csvCostPositiveError);
  }

  final remainingWeight = double.tryParse(remainingWeightStr) ?? spoolWeight;

  return ImportRow(
    lineNumber: lineNumber,
    name: name,
    brand: brand,
    materialType: materialType,
    color: color,
    colorHex: colorHex,
    spoolWeight: spoolWeight,
    remainingWeight: remainingWeight,
    cost: cost,
    notes: notes,
    errors: errors,
  );
}

List<ImportRow> parseCsvContent(String content, AppLocalizations l10n) {
  final lines = content
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .toList();
  if (lines.isEmpty) return [];

  final headers = parseCsvLine(lines[0]);
  final columnIndex = <String, int>{};
  for (var i = 0; i < headers.length; i++) {
    columnIndex[headers[i].toLowerCase().trim()] = i;
  }

  final rows = <ImportRow>[];
  for (var i = 1; i < lines.length; i++) {
    final values = parseCsvLine(lines[i]);
    rows.add(parseImportRow(values, columnIndex, i, l10n));
  }

  return rows;
}
