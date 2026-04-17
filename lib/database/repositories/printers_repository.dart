import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/database_helpers.dart';
import 'package:threed_print_cost_calculator/database/database_record_mapper.dart';
import 'package:threed_print_cost_calculator/settings/model/printer_model.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

final printersRepositoryProvider = Provider<PrintersRepository>(
  PrintersRepository.new,
);

class PrintersRepository {
  PrintersRepository(this.ref);

  final Ref ref;

  AppLogger get _logger => ref.read(appLoggerProvider);

  Database get _db => ref.read(databaseProvider);

  StoreRef<Object?, Object?> get _store =>
      StoreRef<Object?, Object?>(DBName.printers.name);

  Future<List<PrinterModel>> getPrinters() async {
    final snapshots = await _store.find(_db);
    return _mapSnapshots(snapshots);
  }

  Stream<List<PrinterModel>> watchPrinters() async* {
    yield await getPrinters();
    await for (final snapshots in _store.query().onSnapshots(_db)) {
      yield _mapSnapshots(snapshots);
    }
  }

  Future<PrinterModel?> getPrinterById(String id) async {
    final snapshot = await _store.record(id).getSnapshot(_db);
    return _mapSnapshot(snapshot);
  }

  Future<Object?> savePrinter(PrinterModel printer, {String? id}) async {
    if (id != null) {
      await ref
          .read(dbHelpersProvider(DBName.printers))
          .updateRecord(id, printer.toMap());
      return id;
    }

    return ref
        .read(dbHelpersProvider(DBName.printers))
        .insertRecord(printer.toMap());
  }

  Future<void> deletePrinter(String id) {
    return ref.read(dbHelpersProvider(DBName.printers)).deleteRecord(id);
  }

  PrinterModel? _mapSnapshot(RecordSnapshot<Object?, Object?>? snapshot) {
    if (snapshot == null) return null;

    final map = castDatabaseRecord(
      snapshot.value,
      storeName: DBName.printers.name,
      key: snapshot.key,
      logger: _logger,
    );
    if (map == null) return null;

    try {
      return PrinterModel.fromMap(map, snapshot.key.toString());
    } catch (error, stackTrace) {
      _logger.warn(
        AppLogCategory.migration,
        'Skipping malformed printer record',
        context: {'store': DBName.printers.name, 'key': snapshot.key},
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  List<PrinterModel> _mapSnapshots(
    List<RecordSnapshot<Object?, Object?>> snapshots,
  ) => snapshots.map(_mapSnapshot).whereType<PrinterModel>().toList();
}

final printersStreamProvider = StreamProvider<List<PrinterModel>>((ref) {
  ref.watch(appRefreshProvider);
  return ref.watch(printersRepositoryProvider).watchPrinters();
});
