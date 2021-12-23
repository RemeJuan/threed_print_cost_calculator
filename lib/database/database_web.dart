import 'package:sembast/sembast.dart';
import 'package:sembast_web/sembast_web.dart';
import 'package:threed_print_cost_calculator/database/database_contract.dart';

class DatabaseStorageImpl implements DatabaseStorage {
  @override
  Future<Database> openDb() async {
    // Open the database
    return databaseFactoryWeb.openDatabase(DB_NAME);
  }
}
