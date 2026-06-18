import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:riverpod/riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/app/app_page_shell_config.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store.dart';

final appNavigatorKey = GlobalKey<NavigatorState>();

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
  bool _refreshQueued = false;

  @override
  int build() => 0;

  void refresh() {
    SchedulerBinding binding;
    try {
      binding = SchedulerBinding.instance;
    } catch (_) {
      state++;
      return;
    }

    final schedulerPhase = binding.schedulerPhase;

    final shouldDefer =
        schedulerPhase == SchedulerPhase.persistentCallbacks ||
        schedulerPhase == SchedulerPhase.transientCallbacks ||
        schedulerPhase == SchedulerPhase.midFrameMicrotasks;

    if (!shouldDefer) {
      state++;
      return;
    }

    if (_refreshQueued) {
      return;
    }

    _refreshQueued = true;
    binding.addPostFrameCallback((_) {
      _refreshQueued = false;
      state++;
    });
  }
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
