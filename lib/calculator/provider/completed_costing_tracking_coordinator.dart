import 'dart:async';

import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculation_results_state.dart';
import 'package:threed_print_cost_calculator/shared/services/app_usage_service.dart';
import 'package:threed_print_cost_calculator/shared/utils/debounce_constants.dart';

final completedCostingTrackingDelayProvider = Provider<Duration>(
  (ref) => debounce7s,
);

class CompletedCostingTrackingCoordinator {
  CompletedCostingTrackingCoordinator(this.ref);

  final Ref ref;
  Timer? _timer;

  void schedule(CalculationResult results) {
    final hasMeaningfulCompletedCosting =
        results.electricity > 0 && results.filament > 0;
    if (!hasMeaningfulCompletedCosting) {
      cancel();
      return;
    }

    _timer?.cancel();
    final delay = ref.read(completedCostingTrackingDelayProvider);
    _timer = Timer(delay, () {
      _timer = null;
      unawaited(ref.read(appUsageServiceProvider).recordCompletedCosting());
    });
  }

  void cancel() {
    _timer?.cancel();
    _timer = null;
  }
}
