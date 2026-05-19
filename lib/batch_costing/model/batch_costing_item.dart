import 'package:threed_print_cost_calculator/gcode_import/gcode_import_result.dart';

enum BatchCostingItemSourceType { manual, gcode }

class BatchCostingImportMetadata {
  BatchCostingImportMetadata({
    this.sourceFileName,
    this.sourcePath,
    this.slicer,
    this.hasSafePreview = false,
    Map<String, String> rawExtractedValues = const <String, String>{},
  }) : rawExtractedValues = Map.unmodifiable(rawExtractedValues);

  final String? sourceFileName;
  final String? sourcePath;
  final GCodeSlicer? slicer;
  final bool hasSafePreview;
  final Map<String, String> rawExtractedValues;

  BatchCostingImportMetadata copyWith({
    String? sourceFileName,
    String? sourcePath,
    GCodeSlicer? slicer,
    bool? hasSafePreview,
    Map<String, String>? rawExtractedValues,
  }) {
    return BatchCostingImportMetadata(
      sourceFileName: sourceFileName ?? this.sourceFileName,
      sourcePath: sourcePath ?? this.sourcePath,
      slicer: slicer ?? this.slicer,
      hasSafePreview: hasSafePreview ?? this.hasSafePreview,
      rawExtractedValues: rawExtractedValues ?? this.rawExtractedValues,
    );
  }
}

class BatchCostingItem {
  BatchCostingItem._({
    required this.id,
    required this.displayName,
    required int quantity,
    this.printWeightG,
    this.printDuration,
    this.sourceFileName,
    this.sourceType,
    this.importMetadata,
    this.printerId,
    this.materialId,
    this.pricingProfileId,
  }) : quantity = _validateQuantity(quantity);

  final String id;
  final String displayName;
  final String? sourceFileName;
  final int quantity;
  final double? printWeightG;
  final Duration? printDuration;
  final BatchCostingItemSourceType? sourceType;
  final BatchCostingImportMetadata? importMetadata;
  final String? printerId;
  final String? materialId;
  final String? pricingProfileId;

  factory BatchCostingItem.manual({
    required String id,
    required String displayName,
    required int quantity,
    required double printWeightG,
    required Duration printDuration,
    String? sourceFileName,
    String? printerId,
    String? materialId,
    String? pricingProfileId,
  }) {
    return BatchCostingItem._(
      id: id,
      displayName: displayName,
      sourceFileName: sourceFileName,
      quantity: _validateQuantity(quantity),
      printWeightG: printWeightG,
      printDuration: printDuration,
      sourceType: BatchCostingItemSourceType.manual,
      printerId: printerId,
      materialId: materialId,
      pricingProfileId: pricingProfileId,
    );
  }

  factory BatchCostingItem.fromGCodeImport({
    required String id,
    required String displayName,
    required int quantity,
    required GCodeImportResult importResult,
    String? sourceFileName,
    String? sourcePath,
    String? printerId,
    String? materialId,
    String? pricingProfileId,
  }) {
    return BatchCostingItem._(
      id: id,
      displayName: displayName,
      sourceFileName: sourceFileName,
      quantity: _validateQuantity(quantity),
      printWeightG: importResult.filamentWeightG,
      printDuration: importResult.estimatedDuration,
      sourceType: BatchCostingItemSourceType.gcode,
      importMetadata: BatchCostingImportMetadata(
        sourceFileName: sourceFileName,
        sourcePath: sourcePath,
        slicer: importResult.slicer,
        hasSafePreview: importResult.hasSafePreview,
        rawExtractedValues: importResult.rawExtractedValues,
      ),
      printerId: printerId,
      materialId: materialId,
      pricingProfileId: pricingProfileId,
    );
  }

  BatchCostingItem copyWith({
    String? id,
    String? displayName,
    String? sourceFileName,
    int? quantity,
    double? printWeightG,
    Duration? printDuration,
    BatchCostingItemSourceType? sourceType,
    BatchCostingImportMetadata? importMetadata,
    String? printerId,
    String? materialId,
    String? pricingProfileId,
  }) {
    return BatchCostingItem._(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      sourceFileName: sourceFileName ?? this.sourceFileName,
      quantity: quantity ?? this.quantity,
      printWeightG: printWeightG ?? this.printWeightG,
      printDuration: printDuration ?? this.printDuration,
      sourceType: sourceType ?? this.sourceType,
      importMetadata: importMetadata ?? this.importMetadata,
      printerId: printerId ?? this.printerId,
      materialId: materialId ?? this.materialId,
      pricingProfileId: pricingProfileId ?? this.pricingProfileId,
    );
  }

  static int _validateQuantity(int quantity) {
    if (quantity < 1) {
      throw ArgumentError.value(quantity, 'quantity', 'must be >= 1');
    }
    return quantity;
  }
}
