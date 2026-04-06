import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
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
  Future<void> deleteMaterial(String id) async {
    deleteCalls.add(id);
  }
}
