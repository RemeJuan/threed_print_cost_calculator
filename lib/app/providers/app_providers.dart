import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sembast/sembast.dart';

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError("SharedPreferences not implemented"),
);

final databaseProvider = Provider<Database>(
  (_) => throw UnimplementedError("Database not implemented"),
);
