import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/shared/utils/debounce_constants.dart';

import '../provider/history_paged_notifier.dart';

void useHistorySearchQuery({
  required WidgetRef ref,
  required TextEditingController controller,
}) {
  final debounceTimer = useRef<Timer?>(null);

  useEffect(() {
    void listener() {
      debounceTimer.value?.cancel();
      debounceTimer.value = Timer(debounce300ms, () {
        ref.read(historyPagedProvider.notifier).setQuery(controller.text);
      });
    }

    controller.addListener(listener);

    return () {
      controller.removeListener(listener);
      debounceTimer.value?.cancel();
    };
  }, [controller]);
}
