import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_parser.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

class FakePrintersRepository implements PrintersRepository {
  FakePrintersRepository({List<Object> watchResponses = const []})
    : watchResponses = watchResponses.isEmpty
          ? const [<PrinterModel>[]]
          : watchResponses;

  final List<Object> watchResponses;
  final List<String> getPrinterByIdCalls = [];
  final List<PrinterModel> savedPrinters = [];
  final List<String> deleteCalls = [];
  final Map<String, PrinterModel> printersById = {};
  Object? saveResult;
  int _watchCount = 0;

  @override
  Ref get ref => throw UnimplementedError();

  @override
  Future<List<PrinterModel>> getPrinters() async {
    return printersById.values.toList();
  }

  @override
  Stream<List<PrinterModel>> watchPrinters() {
    final index = _watchCount < watchResponses.length
        ? _watchCount
        : watchResponses.length - 1;
    final response = watchResponses[index];
    _watchCount += 1;

    return response is List<PrinterModel>
        ? Stream<List<PrinterModel>>.value(response)
        : Stream<List<PrinterModel>>.error(response);
  }

  @override
  Future<PrinterModel?> getPrinterById(String id) async {
    getPrinterByIdCalls.add(id);
    return printersById[id];
  }

  @override
  Future<Object?> savePrinter(PrinterModel printer, {String? id}) async {
    savedPrinters.add(printer);
    if (saveResult != null) {
      return saveResult;
    }
    final key = id ?? printer.id;
    if (key.isNotEmpty) {
      printersById[key] = printer.copyWith(id: key);
    }
    return key;
  }

  @override
  Future<void> deletePrinter(String id) async {
    deleteCalls.add(id);
  }

  @override
  Future<int> count() async => printersById.length;
}

class FakeMaterialsRepository implements MaterialsRepository {
  FakeMaterialsRepository({
    List<Object> watchResponses = const [],
    this.saveResult,
    this.useExplicitSaveResult = false,
  }) : watchResponses = watchResponses.isEmpty
           ? const [<MaterialModel>[]]
           : watchResponses;

  final List<Object> watchResponses;
  final Object? saveResult;
  final bool useExplicitSaveResult;
  final List<String> getMaterialByIdCalls = [];
  final List<MaterialModel> savedMaterials = [];
  final List<String> deleteCalls = [];
  final Map<String, MaterialModel> materialsById = {};
  int _watchCount = 0;

  @override
  Ref get ref => throw UnimplementedError();

  @override
  Future<List<MaterialModel>> getMaterials() async {
    return materialsById.values.toList();
  }

  @override
  Stream<List<MaterialModel>> watchMaterials() {
    final index = _watchCount < watchResponses.length
        ? _watchCount
        : watchResponses.length - 1;
    final response = watchResponses[index];
    _watchCount += 1;

    return response is List<MaterialModel>
        ? Stream<List<MaterialModel>>.value(response)
        : Stream<List<MaterialModel>>.error(response);
  }

  @override
  Future<MaterialModel?> getMaterialById(String id) async {
    getMaterialByIdCalls.add(id);
    return materialsById[id];
  }

  @override
  Future<Map<String, bool>> existingIds(Set<String> ids) async {
    return {for (final id in ids) id: materialsById.containsKey(id)};
  }

  @override
  Future<Object?> saveMaterial(MaterialModel material, {String? id}) async {
    savedMaterials.add(material);

    final key = useExplicitSaveResult ? saveResult : (id ?? material.id);
    if (key != null && key.toString().isNotEmpty) {
      final savedKey = key.toString();
      materialsById[savedKey] = material.copyWith(id: savedKey);
    }

    return useExplicitSaveResult ? saveResult : (id ?? material.id);
  }

  @override
  Future<MaterialsUpsertResult> upsertMaterials({
    required List<CsvImportRow> creates,
    required List<CsvImportRow> updates,
    Future<void> Function(CsvImportRow row)? onBeforeWrite,
  }) async {
    final skippedRows = <CsvImportRow>[];
    var created = 0;
    var updated = 0;

    MaterialModel mapRow(CsvImportRow row, String id) {
      return MaterialModel(
        id: id,
        name: row.name,
        cost: row.cost.toString(),
        color: row.color,
        weight: row.spoolWeight.toString(),
        archived: row.archived,
        autoDeductEnabled: row.trackRemaining,
        originalWeight: row.spoolWeight,
        remainingWeight: row.remainingWeight,
        brand: row.brand,
        materialType: row.materialType,
        colorHex: row.colorHex,
        notes: row.notes,
      );
    }

    for (final row in updates) {
      if (!materialsById.containsKey(row.sourceId)) {
        skippedRows.add(row);
        continue;
      }
      final material = mapRow(row, row.sourceId);
      materialsById[row.sourceId] = material;
      savedMaterials.add(material);
      updated += 1;
    }

    for (final row in creates) {
      var nextId = materialsById.length + created + 1;
      while (materialsById.containsKey('material_$nextId')) {
        nextId += 1;
      }
      final id = 'material_$nextId';
      final material = mapRow(row, id);
      materialsById[id] = material;
      savedMaterials.add(material);
      created += 1;
    }

    return MaterialsUpsertResult(
      created: created,
      updated: updated,
      skippedRows: skippedRows,
      saveFailures: const [],
    );
  }

  @override
  Future<void> deleteMaterial(String id) async {
    deleteCalls.add(id);
  }

  @override
  Future<int> count() async => materialsById.length;
}
