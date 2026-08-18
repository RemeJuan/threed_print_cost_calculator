import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_parser.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_repository.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/material_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository({GeneralSettingsModel? initialSettings})
    : _settings = initialSettings ?? GeneralSettingsModel.initial(),
      _controller = StreamController<GeneralSettingsModel>.broadcast();

  GeneralSettingsModel _settings;
  final StreamController<GeneralSettingsModel> _controller;
  GeneralSettingsModel? lastSavedSettings;

  @override
  Ref get ref => throw UnimplementedError();
  @override
  Future<GeneralSettingsModel> getSettings() async => _settings;
  @override
  Stream<GeneralSettingsModel> watchSettings() async* {
    yield _settings;
    yield* _controller.stream;
  }

  @override
  Future<void> saveSettings(GeneralSettingsModel settings) async {
    _settings = settings;
    lastSavedSettings = settings;
    if (!_controller.isClosed) _controller.add(settings);
  }

  void emit(GeneralSettingsModel settings) {
    _settings = settings;
    if (!_controller.isClosed) _controller.add(settings);
  }

  Future<void> dispose() async => _controller.close();
}

class FakePrintersRepository implements PrintersRepository {
  FakePrintersRepository([Map<String, PrinterModel>? printers])
    : _printers = printers ?? const {};
  final Map<String, PrinterModel> _printers;
  @override
  Ref get ref => throw UnimplementedError();
  @override
  Future<List<PrinterModel>> getPrinters() async => _printers.values.toList();
  @override
  Stream<List<PrinterModel>> watchPrinters() async* {
    yield _printers.values.toList();
  }

  @override
  Future<PrinterModel?> getPrinterById(String id) async => _printers[id];
  @override
  Future<Object?> savePrinter(PrinterModel printer, {String? id}) async =>
      id ?? printer.id;
  @override
  Future<void> deletePrinter(String id) async {}
  @override
  Future<int> count() async => _printers.length;
}

class FakeMaterialsRepository implements MaterialsRepository {
  FakeMaterialsRepository([Map<String, MaterialModel>? materials])
    : _materials = Map<String, MaterialModel>.from(materials ?? const {});
  final Map<String, MaterialModel> _materials;
  @override
  Ref get ref => throw UnimplementedError();
  @override
  Future<List<MaterialModel>> getMaterials() async =>
      _materials.values.toList();
  @override
  Stream<List<MaterialModel>> watchMaterials() async* {
    yield _materials.values.toList();
  }

  @override
  Future<MaterialModel?> getMaterialById(String id) async => _materials[id];
  @override
  Future<Object?> saveMaterial(MaterialModel material, {String? id}) async {
    final key = id ?? material.id;
    if (key.isNotEmpty) _materials[key] = material.copyWith(id: key);
    return key;
  }

  @override
  Future<Map<String, bool>> existingIds(Set<String> ids) async => {
    for (final id in ids) id: _materials.containsKey(id),
  };
  @override
  Future<MaterialsUpsertResult> upsertMaterials({
    required List<CsvImportRow> creates,
    required List<CsvImportRow> updates,
    Future<void> Function(CsvImportRow row)? onBeforeWrite,
  }) async {
    final skippedRows = <CsvImportRow>[];
    var created = 0;
    var updated = 0;
    for (final row in updates) {
      if (!_materials.containsKey(row.sourceId)) {
        skippedRows.add(row);
        continue;
      }
      _materials[row.sourceId] = MaterialModel(
        id: row.sourceId,
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
      updated += 1;
    }
    for (final row in creates) {
      var nextId = _materials.length + created + 1;
      while (_materials.containsKey('material_$nextId')) {
        nextId += 1;
      }
      final key = 'material_$nextId';
      _materials[key] = MaterialModel(
        id: key,
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
  Future<void> deleteMaterial(String id) async {}
  @override
  Future<int> count() async => _materials.length;
}

class FakeInterfaceSettingsRepository implements InterfaceSettingsRepository {
  FakeInterfaceSettingsRepository({InterfaceSettingsModel? initialSettings})
    : _settings = initialSettings ?? const InterfaceSettingsModel(),
      _controller = StreamController<InterfaceSettingsModel>.broadcast();
  InterfaceSettingsModel _settings;
  final StreamController<InterfaceSettingsModel> _controller;
  @override
  Ref get ref => throw UnimplementedError();
  @override
  Future<InterfaceSettingsModel> getSettings() async => _settings;
  @override
  Stream<InterfaceSettingsModel> watchSettings() => Stream.multi((multi) {
    final subscription = _controller.stream.listen(
      multi.add,
      onError: multi.addError,
      onDone: multi.close,
    );
    multi
      ..add(_settings)
      ..onCancel = subscription.cancel;
  });
  @override
  Future<void> saveSettings(InterfaceSettingsModel settings) async {
    _settings = settings;
    if (!_controller.isClosed) _controller.add(settings);
  }

  @override
  Future<void> updateSettings(
    InterfaceSettingsModel Function(InterfaceSettingsModel current) updater,
  ) async {
    await saveSettings(updater(_settings));
  }

  Future<void> dispose() async => _controller.close();
}
