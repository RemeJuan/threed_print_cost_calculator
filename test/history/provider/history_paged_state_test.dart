import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_state.dart';

HistoryEntry _entry(String key) => HistoryEntry(
  key: key,
  model: HistoryModel(
    name: key,
    totalCost: 1,
    riskCost: 0,
    filamentCost: 0,
    electricityCost: 0,
    labourCost: 0,
    date: DateTime.utc(2024),
    printer: 'p',
    material: 'm',
    weight: 1,
    timeHours: '01:00',
  ),
);

void main() {
  test('markStale only flips stale flag', () {
    final state = HistoryPagedState.initial();
    final stale = state.markStale();

    expect(stale.isStale, isTrue);
    expect(stale.items, isEmpty);
    expect(stale.page, 0);
    expect(stale.hasLoadedOnce, isFalse);
  });

  test('applyPageResult appends and stops at terminal page', () {
    final first = HistoryPagedState.initial().startLoading().applyPageResult(
      reset: true,
      pageEntries: [_entry('a')],
      totalCount: 2,
      nextPage: 0,
    );
    final second = first.startLoading().applyPageResult(
      reset: false,
      pageEntries: [_entry('b')],
      totalCount: 2,
      nextPage: 1,
    );

    expect(first.items.map((e) => e.key), ['a']);
    expect(first.hasMore, isTrue);
    expect(second.items.map((e) => e.key), ['a', 'b']);
    expect(second.hasMore, isFalse);
    expect(second.isStale, isFalse);
  });

  test(
    'copyWith preserves error when omitted and clears when explicit null',
    () {
      final state = HistoryPagedState.initial().copyWith(error: 'boom');

      final preserved = state.copyWith(isLoading: true);
      final cleared = state.copyWith(error: null);

      expect(preserved.error, 'boom');
      expect(cleared.error, isNull);
    },
  );
}
