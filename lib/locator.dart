import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/database/database.dart';

final GetIt sl = GetIt.instance;

void initServices() {
  // Register services here
  sl.registerSingletonAsync<Database>(
    () async => DatabaseStorageImpl().openDb(),
  );
}
