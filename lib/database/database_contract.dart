//ignore_for_file: one_member_abstracts
import 'package:sembast/sembast.dart';

const DB_NAME = 'calculator';

abstract class DatabaseStorage {
  Future<Database> openDb();
}
