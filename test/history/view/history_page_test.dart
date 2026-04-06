import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/history/history_page.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_notifier.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';

import '../../helpers/helpers.dart';

class _FakeHistoryPagedNotifier extends HistoryPagedNotifier {
  _FakeHistoryPagedNotifier(this._initialState);

  final HistoryPagedState _initialState;

  int refreshIfNeededCalls = 0;
  int loadMoreCalls = 0;
  int setQueryCalls = 0;
  String? lastQuery;

  @override
  HistoryPagedState build() => _initialState;

  @override
  Future<void> refreshIfNeeded() async {
    refreshIfNeededCalls += 1;
  }

  @override
  Future<void> loadMore() async {
    loadMoreCalls += 1;
    state = state.copyWith(
      hasMore: false,
      isLoading: false,
      page: state.page + 1,
    );
  }

  @override
  Future<void> refresh() async {
    state = state.copyWith(items: [], hasMore: true, page: 0);
  }

  @override
  Future<void> setQuery(String q) async {
    setQueryCalls += 1;
    lastQuery = q;
    state = state.copyWith(query: q);
  }
}

class _FakeCsvUtils extends CsvUtils {
  _FakeCsvUtils(super.ref);

  ExportRange? lastRange;

  @override
  Future<void> exportForRange(ExportRange range) async {
    lastRange = range;
  }
}

HistoryEntry _entry(
  String key,
  String name,
  DateTime date, {
  List<Map<String, dynamic>> materialUsages = const [],
}) {
  return HistoryEntry(
    key: key,
    model: HistoryModel(
      name: name,
      totalCost: 19.25,
      riskCost: 1.25,
      filamentCost: 12.5,
      electricityCost: 3.0,
      labourCost: 2.5,
      date: date,
      printer: 'Prusa MK4',
      material: 'PLA',
      weight: 123,
      materialUsages: materialUsages,
      timeHours: '06:20',
    ),
  );
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    await setupTest();
  });

  testWidgets('shows empty state and refresh wiring correctly', (tester) async {
    final notifier = _FakeHistoryPagedNotifier(
      HistoryPagedState.initial().copyWith(hasMore: false),
    );

    await tester.pumpApp(const HistoryPage(), [
      historyPagedProvider.overrideWith(() => notifier),
    ]);

    await tester.pumpAndSettle();

    expect(notifier.refreshIfNeededCalls, 1);
    expect(
      find.byKey(const ValueKey<String>('history.search.input')),
      findsOneWidget,
    );
    expect(find.text('No more records'), findsOneWidget);
  });

  testWidgets('renders populated history and debounces search input', (
    tester,
  ) async {
    final notifier = _FakeHistoryPagedNotifier(
      HistoryPagedState.initial().copyWith(
        items: [
          _entry('1', 'Benchy', DateTime.utc(2024, 1, 2)),
          _entry('2', 'Gear', DateTime.utc(2024, 1, 1)),
        ],
        hasMore: false,
      ),
    );

    await tester.pumpApp(const HistoryPage(), [
      historyPagedProvider.overrideWith(() => notifier),
    ]);

    await tester.pumpAndSettle();

    expect(find.text('Benchy'), findsOneWidget);
    expect(find.text('Gear'), findsOneWidget);
    expect(find.text('02 Jan 2024'), findsOneWidget);
    expect(find.text('01 Jan 2024'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey<String>('history.search.input')),
      'prusa',
    );
    await tester.pump(const Duration(milliseconds: 350));

    expect(notifier.setQueryCalls, 1);
    expect(notifier.lastQuery, 'prusa');
  });

  testWidgets('exports the selected history range', (tester) async {
    final notifier = _FakeHistoryPagedNotifier(
      HistoryPagedState.initial().copyWith(hasMore: false),
    );
    late _FakeCsvUtils csvUtils;

    await tester.pumpApp(const HistoryPage(), [
      historyPagedProvider.overrideWith(() => notifier),
      csvUtilsProvider.overrideWith((ref) {
        csvUtils = _FakeCsvUtils(ref);
        return csvUtils;
      }),
    ]);

    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const ValueKey<String>('history.export.button')),
    );
    await tester.pumpAndSettle();

    expect(find.text('Last 7 days'), findsOneWidget);

    await tester.tap(find.text('Last 7 days'));
    await tester.pumpAndSettle();

    expect(csvUtils.lastRange, ExportRange.last7Days);
  });
}
