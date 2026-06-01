import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/settings/model/general_settings_model.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/services/electricity_resolver.dart';

void main() {
  group('ElectricityResolver.resolve', () {
    const resolver = ElectricityResolver();
    final emptySettings = GeneralSettingsModel.initial();

    test('returns 0 rated when printers empty and settings empty', () {
      final result = resolver.resolve(
        printers: const [],
        activePrinterId: null,
        settings: emptySettings,
      );
      expect(result.wattage, 0);
      expect(result.source, WattageSource.rated);
      expect(result.printerId, isNull);
      expect(result.printerName, isNull);
    });

    test('uses settings averageWattage when printers empty', () {
      final settings = emptySettings.copyWith(averageWattage: '350');
      final result = resolver.resolve(
        printers: const [],
        activePrinterId: null,
        settings: settings,
      );
      expect(result.wattage, 350);
      expect(result.source, WattageSource.average);
    });

    test('uses settings wattage when printers empty and avg unset', () {
      final settings = emptySettings.copyWith(wattage: '750');
      final result = resolver.resolve(
        printers: const [],
        activePrinterId: null,
        settings: settings,
      );
      expect(result.wattage, 750);
      expect(result.source, WattageSource.rated);
    });

    test('settings avg takes precedence over rated when printers empty', () {
      final settings = emptySettings.copyWith(
        wattage: '750',
        averageWattage: '350',
      );
      final result = resolver.resolve(
        printers: const [],
        activePrinterId: null,
        settings: settings,
      );
      expect(result.wattage, 350);
      expect(result.source, WattageSource.average);
    });

    test('uses printer avg when printers exist and active printer has avg', () {
      final printer = _printer(id: 'p1', name: 'My Printer', avg: '280');
      final result = resolver.resolve(
        printers: [printer],
        activePrinterId: 'p1',
        settings: emptySettings,
      );
      expect(result.wattage, 280);
      expect(result.source, WattageSource.average);
      expect(result.printerId, 'p1');
      expect(result.printerName, 'My Printer');
    });

    test('uses printer rated when printers exist and avg unset', () {
      final printer = _printer(id: 'p1', wattage: '500', avg: '');
      final result = resolver.resolve(
        printers: [printer],
        activePrinterId: 'p1',
        settings: emptySettings,
      );
      expect(result.wattage, 500);
      expect(result.source, WattageSource.rated);
    });

    test('never falls back to settings when printers exist', () {
      final printer = _printer(id: 'p1', wattage: '500', avg: '');
      final settings = emptySettings.copyWith(averageWattage: '999');
      final result = resolver.resolve(
        printers: [printer],
        activePrinterId: 'p1',
        settings: settings,
      );
      expect(result.wattage, 500);
      expect(result.source, WattageSource.rated);
      expect(result.printerId, 'p1');
    });

    test('falls back to first printer when activePrinterId empty', () {
      final printers = [
        _printer(id: 'p1', wattage: '500', avg: '280'),
        _printer(id: 'p2', wattage: '750'),
      ];
      final result = resolver.resolve(
        printers: printers,
        activePrinterId: null,
        settings: emptySettings,
      );
      expect(result.wattage, 280);
      expect(result.source, WattageSource.average);
      expect(result.printerId, 'p1');
    });

    test('falls back to first printer when activePrinterId not found', () {
      final printers = [
        _printer(id: 'p1', wattage: '500'),
        _printer(id: 'p2', wattage: '750', avg: '450'),
      ];
      final result = resolver.resolve(
        printers: printers,
        activePrinterId: 'nonexistent',
        settings: emptySettings,
      );
      expect(result.wattage, 500);
      expect(result.source, WattageSource.rated);
      expect(result.printerId, 'p1');
    });

    test('returns 0 when printer has both wattages unset', () {
      final printer = _printer(id: 'p1', wattage: '', avg: '');
      final result = resolver.resolve(
        printers: [printer],
        activePrinterId: 'p1',
        settings: emptySettings,
      );
      expect(result.wattage, 0);
      expect(result.source, WattageSource.rated);
    });

    test('ignores global average when active printer has avg set', () {
      final printer = _printer(id: 'p1', wattage: '500', avg: '300');
      final settings = emptySettings.copyWith(averageWattage: '999');
      final result = resolver.resolve(
        printers: [printer],
        activePrinterId: 'p1',
        settings: settings,
      );
      expect(result.wattage, 300);
      expect(result.source, WattageSource.average);
    });
  });

  group('ElectricityResolver.resolveFromPrinter', () {
    const resolver = ElectricityResolver();

    test('uses avg when set', () {
      final printer = _printer(id: 'p1', name: 'P1', wattage: '500', avg: '280');
      final result = resolver.resolveFromPrinter(printer);
      expect(result.wattage, 280);
      expect(result.source, WattageSource.average);
      expect(result.printerId, 'p1');
      expect(result.printerName, 'P1');
    });

    test('falls back to rated when avg unset', () {
      final printer = _printer(id: 'p1', name: 'P1', wattage: '500', avg: '');
      final result = resolver.resolveFromPrinter(printer);
      expect(result.wattage, 500);
      expect(result.source, WattageSource.rated);
    });

    test('returns 0 when both unset', () {
      final printer = _printer(id: 'p1', wattage: '', avg: '');
      final result = resolver.resolveFromPrinter(printer);
      expect(result.wattage, 0);
      expect(result.source, WattageSource.rated);
    });
  });
}

PrinterModel _printer({
  required String id,
  String name = '',
  String wattage = '',
  String avg = '',
}) {
  return PrinterModel(
    id: id,
    name: name,
    bedSize: '200x200',
    wattage: wattage,
    averageWattage: avg,
    archived: false,
  );
}
