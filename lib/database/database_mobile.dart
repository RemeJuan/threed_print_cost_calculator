import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_io.dart';
import 'package:threed_print_cost_calculator/database/database_contract.dart';

class DatabaseStorageImpl implements DatabaseStorage {
  @override
  Future<Database> openDb() async {
    // get the application documents directory
    final dir = await getApplicationDocumentsDirectory();
    // make sure it exists
    await dir.create(recursive: true);
    // build the database path
    final dbPath = join(dir.path, '$DB_NAME.db');
    // open the database
    return databaseFactoryIo.openDatabase(dbPath);
  }
}
