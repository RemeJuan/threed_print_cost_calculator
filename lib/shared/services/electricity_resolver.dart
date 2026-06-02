import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/utils/number_parsing.dart';

final electricityResolverProvider = Provider<ElectricityResolver>(
  (_) => const ElectricityResolver(),
);

enum WattageSource { rated, average }

class WattageResolution {
  const WattageResolution({
    required this.wattage,
    required this.source,
    this.printerId,
    this.printerName,
  });

  final num wattage;
  final WattageSource source;
  final String? printerId;
  final String? printerName;
}

class ElectricityResolver {
  const ElectricityResolver();

  WattageResolution resolve({
    required List<PrinterModel> printers,
    required String? activePrinterId,
    required GeneralSettingsModel settings,
  }) {
    if (printers.isEmpty) {
      return _resolveFromSettings(settings);
    }

    PrinterModel? printer;
    if (activePrinterId != null && activePrinterId.isNotEmpty) {
      final match = printers.where((p) => p.id == activePrinterId);
      printer = match.isNotEmpty ? match.first : null;
    }

    printer ??= printers.first;

    return _resolveFromPrinter(printer);
  }

  WattageResolution resolveFromPrinter(PrinterModel printer) {
    return _resolveFromPrinter(printer);
  }

  WattageResolution _resolveFromPrinter(PrinterModel printer) {
    final avg = tryParseLocalizedNum(printer.averageWattage);
    if (avg != null) {
      return WattageResolution(
        wattage: avg,
        source: WattageSource.average,
        printerId: printer.id,
        printerName: printer.name,
      );
    }

    final rated = tryParseLocalizedNum(printer.wattage);
    return WattageResolution(
      wattage: rated ?? 0,
      source: WattageSource.rated,
      printerId: printer.id,
      printerName: printer.name,
    );
  }

  WattageResolution _resolveFromSettings(GeneralSettingsModel settings) {
    final avg = tryParseLocalizedNum(settings.averageWattage);
    if (avg != null) {
      return WattageResolution(wattage: avg, source: WattageSource.average);
    }

    final rated = tryParseLocalizedNum(settings.wattage);
    return WattageResolution(wattage: rated ?? 0, source: WattageSource.rated);
  }
}
