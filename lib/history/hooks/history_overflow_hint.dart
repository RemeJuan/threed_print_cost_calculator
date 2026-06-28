import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

const overflowHintPreferenceKey = 'history_overflow_hint_seen_v2';
const overflowMenuOpenedPreferenceKey = 'history_overflow_menu_opened_v1';
const overflowHintDuration = Duration(seconds: 4);

HistoryOverflowHintController useHistoryOverflowHint({
  required WidgetRef ref,
  required int itemCount,
}) {
  final prefs = ref.read(sharedPreferencesProvider);
  final showOverflowHint = useState(false);
  final overflowHintTimer = useRef<Timer?>(null);

  Future<void> markOverflowHintSeen() async {
    if (prefs.getBool(overflowHintPreferenceKey) == true) return;
    await prefs.setBool(overflowHintPreferenceKey, true);
  }

  Future<void> markOverflowMenuOpened() async {
    if (prefs.getBool(overflowMenuOpenedPreferenceKey) == true) return;
    await prefs.setBool(overflowMenuOpenedPreferenceKey, true);
    AppAnalytics.safeLog(() => AppAnalytics.log('history_overflow_opened'));
  }

  void dismissOverflowHint() {
    if (!showOverflowHint.value) return;
    overflowHintTimer.value?.cancel();
    showOverflowHint.value = false;
  }

  useEffect(() {
    var disposed = false;

    Future<void> maybeShowOverflowHint() async {
      if (itemCount == 0) return;

      final hasSeenHint = prefs.getBool(overflowHintPreferenceKey) ?? false;
      final hasOpenedMenu =
          prefs.getBool(overflowMenuOpenedPreferenceKey) ?? false;
      if (hasSeenHint || hasOpenedMenu || showOverflowHint.value) return;

      await markOverflowHintSeen();
      if (disposed) return;

      AppAnalytics.safeLog(
        () => AppAnalytics.log('history_overflow_hint_shown'),
      );
      showOverflowHint.value = true;
      overflowHintTimer.value?.cancel();
      overflowHintTimer.value = Timer(overflowHintDuration, () {
        if (!disposed) {
          showOverflowHint.value = false;
        }
      });
    }

    unawaited(maybeShowOverflowHint());

    return () {
      disposed = true;
      overflowHintTimer.value?.cancel();
    };
  }, [itemCount]);

  return HistoryOverflowHintController(
    showOverflowHint: showOverflowHint,
    markOverflowMenuOpened: markOverflowMenuOpened,
    dismissOverflowHint: dismissOverflowHint,
  );
}

class HistoryOverflowHintController {
  const HistoryOverflowHintController({
    required this.showOverflowHint,
    required this.markOverflowMenuOpened,
    required this.dismissOverflowHint,
  });

  final ValueNotifier<bool> showOverflowHint;
  final Future<void> Function() markOverflowMenuOpened;
  final VoidCallback dismissOverflowHint;
}
