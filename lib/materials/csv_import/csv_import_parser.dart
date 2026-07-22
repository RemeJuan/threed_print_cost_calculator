import 'dart:async';

import 'package:threed_print_cost_calculator/materials/csv_import/materials_csv_schema.dart';

enum CsvImportRowKind { create, update, invalid }

enum CsvImportErrorCode {
  requiredName,
  requiredColor,
  requiredSpoolWeight,
  invalidSpoolWeight,
  invalidRemainingWeight,
  requiredCost,
  invalidCost,
  invalidTrackRemaining,
  invalidArchived,
  invalidHeader,
  malformedCsv,
}

class CsvImportError {
  const CsvImportError(this.code, {this.field, this.message});

  final CsvImportErrorCode code;
  final String? field;
  final String? message;
}

const sampleRow1 =
    'foreign-1,PLA Pro+,Sunlu,PLA,Black,#000000,1000,950,24.99,true,false,Notes';
const sampleRow2 =
    ',PETG Black,Overture,PETG,White,#ffffff,1000,1000,29.99,false,false,Notes';

class CsvImportRecord {
  const CsvImportRecord({
    required this.startLine,
    required this.values,
    required this.hasDelimiter,
  });

  final int startLine;
  final List<String> values;
  final bool hasDelimiter;
}

class CsvImportRow {
  const CsvImportRow({
    required this.lineNumber,
    required this.kind,
    required this.sourceId,
    required this.name,
    required this.brand,
    required this.materialType,
    required this.color,
    required this.colorHex,
    required this.spoolWeight,
    required this.remainingWeight,
    required this.cost,
    required this.trackRemaining,
    required this.archived,
    required this.notes,
    required this.errors,
  });

  final int lineNumber;
  final CsvImportRowKind kind;
  final String sourceId;
  final String name;
  final String brand;
  final String materialType;
  final String color;
  final String colorHex;
  final double spoolWeight;
  final double remainingWeight;
  final double cost;
  final bool trackRemaining;
  final bool archived;
  final String notes;
  final List<CsvImportError> errors;
}

class ImportRow extends CsvImportRow {
  const ImportRow({
    required super.lineNumber,
    required super.name,
    required super.brand,
    required super.materialType,
    required super.color,
    required super.colorHex,
    required super.spoolWeight,
    required super.remainingWeight,
    required super.cost,
    required super.notes,
    required super.errors,
    super.kind = CsvImportRowKind.create,
    super.sourceId = '',
    super.trackRemaining = false,
    super.archived = false,
  });
}

class ParsedCsvImportFile {
  const ParsedCsvImportFile({required this.header, required this.rows});

  final List<String> header;
  final List<CsvImportRecord> rows;
}

class ClassifiedCsvImport {
  const ClassifiedCsvImport({required this.rows, required this.header});

  final List<CsvImportRow> rows;
  final List<String> header;
}

ParsedCsvImportFile parseCsvImportFile(String content) {
  final text = content.startsWith('\ufeff') ? content.substring(1) : content;
  final records = <CsvImportRecord>[];
  var field = StringBuffer();
  final row = <String>[];
  var inQuotes = false;
  var recordStart = 1;
  var line = 1;
  var recordHasDelimiter = false;

  void finishField() {
    row.add(field.toString());
    // ignore: cascade_invocations
    field = StringBuffer();
  }

  void finishRecord() {
    final isBlank = row.isEmpty || row.every((value) => value.trim().isEmpty);
    if (!isBlank || recordHasDelimiter) {
      records.add(
        CsvImportRecord(
          startLine: recordStart,
          values: List.of(row),
          hasDelimiter: recordHasDelimiter,
        ),
      );
    }
    row.clear();
    recordHasDelimiter = false;
  }

  for (var i = 0; i < text.length; i++) {
    final ch = text[i];
    if (ch == '"') {
      if (!inQuotes && field.isEmpty) {
        inQuotes = true;
      } else if (inQuotes && i + 1 < text.length && text[i + 1] == '"') {
        field.write('"');
        i++;
      } else if (inQuotes) {
        inQuotes = false;
      } else {
        throw FormatException('Malformed CSV');
      }
      continue;
    }
    if (ch == ',' && !inQuotes) {
      recordHasDelimiter = true;
      finishField();
      continue;
    }
    if (ch == '\n' && !inQuotes) {
      finishField();
      finishRecord();
      line++;
      recordStart = line;
      continue;
    }
    if (ch == '\r') continue;
    field.write(ch);
  }
  if (inQuotes) throw FormatException('Malformed CSV');
  finishField();
  if (row.isNotEmpty) finishRecord();
  records.removeWhere(
    (record) =>
        !record.hasDelimiter &&
        record.values.every((value) => value.trim().isEmpty),
  );
  if (records.isEmpty) return const ParsedCsvImportFile(header: [], rows: []);
  final header = records.first.values;
  final rows = records
      .skip(1)
      .where((record) => record.hasDelimiter || !_isBlankRecord(record))
      .toList();
  return ParsedCsvImportFile(header: header, rows: rows);
}

bool _parseBool(String value) {
  if (value == 'true') return true;
  if (value == 'false') return false;
  throw FormatException('Invalid boolean');
}

double _parseRequiredNum(String value) {
  final parsed = double.tryParse(value);
  if (parsed == null) throw FormatException('Invalid number');
  return parsed;
}

class CsvImportParser {
  const CsvImportParser();

  Future<ClassifiedCsvImport> classifyAsync({
    required ParsedCsvImportFile file,
    required Future<Map<String, bool>> Function(Set<String> ids) lookupIds,
  }) async {
    final ids = file.rows
        .map((r) => r.values.isNotEmpty ? r.values.first.trim() : '')
        .where((id) => id.isNotEmpty)
        .toSet();
    return classify(file: file, existingIds: await lookupIds(ids));
  }

  ClassifiedCsvImport classify({
    required ParsedCsvImportFile file,
    required Map<String, bool> existingIds,
  }) {
    if (file.header.join(',') != materialsCsvHeader) {
      throw const FormatException('Invalid CSV header');
    }
    final rows = file.rows.map((record) {
      final raw = _raw(record.values);
      final trim = _trimmed(record.values);
      final errors = <CsvImportError>[];
      final sourceId = trim('id');
      final name = raw('name');
      final brand = raw('brand');
      final materialType = raw('material_type');
      final color = raw('color');
      final colorHex = raw('color_hex');
      final spoolWeightStr = trim('spool_weight_g');
      final remainingWeightStr = trim('remaining_weight_g');
      final costStr = trim('spool_cost');
      final trackRemainingStr = trim('track_remaining');
      final archivedStr = trim('archived');
      final notes = raw('notes');

      late final double spoolWeight;
      late final double remainingWeight;
      late final double cost;
      late final bool trackRemaining;
      late final bool archived;
      try {
        if (name.trim().isEmpty) {
          errors.add(
            CsvImportError(CsvImportErrorCode.requiredName, field: 'name'),
          );
        }
        if (color.trim().isEmpty) {
          errors.add(
            CsvImportError(CsvImportErrorCode.requiredColor, field: 'color'),
          );
        }
        spoolWeight = _parseRequiredNum(spoolWeightStr);
        remainingWeight = _parseRequiredNum(remainingWeightStr);
        cost = _parseRequiredNum(costStr);
        trackRemaining = _parseBool(trackRemainingStr);
        archived = _parseBool(archivedStr);
        if (!spoolWeight.isFinite) {
          errors.add(
            CsvImportError(
              CsvImportErrorCode.invalidSpoolWeight,
              field: 'spool_weight_g',
            ),
          );
        }
        if (!remainingWeight.isFinite) {
          errors.add(
            CsvImportError(
              CsvImportErrorCode.invalidRemainingWeight,
              field: 'remaining_weight_g',
            ),
          );
        }
        if (!cost.isFinite) {
          errors.add(
            CsvImportError(CsvImportErrorCode.invalidCost, field: 'spool_cost'),
          );
        }
        if (spoolWeight <= 0) {
          errors.add(
            CsvImportError(
              CsvImportErrorCode.requiredSpoolWeight,
              field: 'spool_weight_g',
            ),
          );
        }
        if (cost <= 0) {
          errors.add(
            CsvImportError(
              CsvImportErrorCode.requiredCost,
              field: 'spool_cost',
            ),
          );
        }
        if (remainingWeight < 0 || remainingWeight > spoolWeight) {
          errors.add(
            CsvImportError(
              CsvImportErrorCode.invalidRemainingWeight,
              field: 'remaining_weight_g',
            ),
          );
        }
      } on FormatException {
        return CsvImportRow(
          lineNumber: record.startLine,
          kind: CsvImportRowKind.invalid,
          sourceId: sourceId,
          name: name,
          brand: brand,
          materialType: materialType,
          color: color,
          colorHex: colorHex,
          spoolWeight: 0,
          remainingWeight: 0,
          cost: 0,
          trackRemaining: false,
          archived: false,
          notes: notes,
          errors: [CsvImportError(CsvImportErrorCode.malformedCsv)],
        );
      }
      final kind = errors.isNotEmpty
          ? CsvImportRowKind.invalid
          : sourceId.isNotEmpty && existingIds[sourceId] == true
          ? CsvImportRowKind.update
          : CsvImportRowKind.create;
      return CsvImportRow(
        lineNumber: record.startLine,
        kind: kind,
        sourceId: sourceId,
        name: name,
        brand: brand,
        materialType: materialType,
        color: color,
        colorHex: colorHex,
        spoolWeight: spoolWeight,
        remainingWeight: remainingWeight,
        cost: cost,
        trackRemaining: trackRemaining,
        archived: archived,
        notes: notes,
        errors: errors,
      );
    }).toList();
    return ClassifiedCsvImport(rows: rows, header: file.header);
  }
}

// Backwards-compatible helpers for legacy callers/tests.
const csvHeader = materialsCsvHeader;

List<String> parseCsvLine(String line) => parseCsvImportFile('$line\n').header;

List<ImportRow> parseCsvContent(String content, Object _) =>
    const CsvImportParser()
        .classify(file: parseCsvImportFile(content), existingIds: const {})
        .rows
        .map(
          (row) => ImportRow(
            lineNumber: row.lineNumber,
            name: row.name,
            brand: row.brand,
            materialType: row.materialType,
            color: row.color,
            colorHex: row.colorHex,
            spoolWeight: row.spoolWeight,
            remainingWeight: row.remainingWeight,
            cost: row.cost,
            notes: row.notes,
            errors: row.errors,
          ),
        )
        .toList();

typedef _ValueReader = String Function(String);

_ValueReader _raw(List<String> values) => (col) {
  final idx = materialsCsvHeaders.indexOf(col);
  if (idx < 0 || idx >= values.length) return '';
  return values[idx];
};

_ValueReader _trimmed(List<String> values) => (col) {
  final idx = materialsCsvHeaders.indexOf(col);
  if (idx < 0 || idx >= values.length) return '';
  return values[idx].trim();
};

bool _isBlankRecord(CsvImportRecord record) =>
    record.values.every((value) => value.trim().isEmpty);
