import 'package:hooks_riverpod/hooks_riverpod.dart';

/// Provider that stores the currently open panel indices as a `Set<int>`.
/// Implemented as a Riverpod v3 `NotifierProvider` so it matches the
/// project's Riverpod 3 usage.
final accordionOpenPanelProvider =
    NotifierProvider<AccordionOpenNotifier, Set<int>>(
      AccordionOpenNotifier.new,
    );

/// Notifier that manages the currently-open panel indices.
class AccordionOpenNotifier extends Notifier<Set<int>> {
  @override
  Set<int> build() => <int>{};

  /// Toggle the given panel index. If the index is currently open, it
  /// will be removed (closed). Otherwise it will be added (opened).
  void toggle(int panelIndex) {
    final current = Set<int>.from(state);
    if (current.contains(panelIndex)) {
      current.remove(panelIndex);
    } else {
      current.add(panelIndex);
    }
    state = current;
  }

  /// Explicitly set the open panel indices.
  void setOpen(Set<int> indices) {
    state = Set<int>.from(indices);
  }

  /// Clear all open panels.
  void clear() {
    state = <int>{};
  }
}
