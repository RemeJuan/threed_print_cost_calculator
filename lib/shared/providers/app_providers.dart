import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sembast/sembast.dart';

ProviderContainer? appProviderContainer;

void registerAppProviderContainer(ProviderContainer container) {
  appProviderContainer = container;
}

final appRefreshProvider = NotifierProvider<AppRefreshNotifier, int>(
  AppRefreshNotifier.new,
);

class AppRefreshNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void refresh() => state++;
}

final sharedPreferencesProvider = Provider<SharedPreferences>(
  (_) => throw UnimplementedError("SharedPreferences not implemented"),
);

final databaseProvider = Provider<Database>(
  (_) => throw UnimplementedError("Database not implemented"),
);
