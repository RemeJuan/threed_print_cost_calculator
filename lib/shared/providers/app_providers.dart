import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/app_page_shell_config.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store.dart';

ProviderContainer? appProviderContainer;

void registerAppProviderContainer(ProviderContainer container) {
  appProviderContainer = container;
}

class PendingTabNavigationNotifier extends Notifier<AppPageTab?> {
  @override
  AppPageTab? build() => null;
  void navigate(AppPageTab? tab) => state = tab;
}

final pendingTabNavigationProvider =
    NotifierProvider<PendingTabNavigationNotifier, AppPageTab?>(
      PendingTabNavigationNotifier.new,
    );

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

final premiumLocalStoreProvider = Provider<PremiumLocalStore>(
  (_) => InMemoryPremiumLocalStore(),
);

final databaseProvider = Provider<Database>(
  (_) => throw UnimplementedError("Database not implemented"),
);
