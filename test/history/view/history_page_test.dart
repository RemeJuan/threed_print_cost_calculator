import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/history/history_page.dart';
import 'package:threed_print_cost_calculator/history/components/history_export_preview_sheet.dart';
import 'package:threed_print_cost_calculator/history/components/history_teaser_state.dart';
import 'package:threed_print_cost_calculator/history/model/history_entry.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_notifier.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/pro_promotion_visibility.dart';
import 'package:threed_print_cost_calculator/shared/utils/csv_utils.dart';

import '../../helpers/helpers.dart';
import '../../helpers/lower_level_test_fakes.dart';

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
  Future<void> exportForRange(
    ExportRange range, {
    required String csvHeader,
    required String shareText,
  }) async {
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
    SharedPreferences.setMockInitialValues({});
    final notifier = _FakeHistoryPagedNotifier(
      HistoryPagedState.initial().copyWith(hasLoadedOnce: true, hasMore: false),
    );
    final paywallPresenter = FakePaywallPresenter();

    await tester.pumpApp(const HistoryPage(mode: HistoryPageMode.full), [
      historyPagedProvider.overrideWith(() => notifier),
      paywallPresenterProvider.overrideWithValue(paywallPresenter),
    ]);

    await tester.pumpAndSettle();

    expect(notifier.refreshIfNeededCalls, 1);
    expect(
      find.byKey(const ValueKey<String>('history.search.input')),
      findsOneWidget,
    );
    expect(find.text('No saved prints yet'), findsOneWidget);
    expect(find.text('Re-use past prints in the calculator'), findsOneWidget);
    expect(find.text('Re-use past prints instantly'), findsOneWidget);
    expect(find.text('Unlock advanced edits and exports'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('history.upsell.banner')),
    );
    await tester.pump();

    expect(paywallPresenter.calls, 1);
    expect(paywallPresenter.lastOfferingId, 'pro');
  });

  testWidgets('premium users do not see the history upsell', (tester) async {
    final notifier = _FakeHistoryPagedNotifier(
      HistoryPagedState.initial().copyWith(
        items: [_entry('1', 'Benchy', DateTime.utc(2024, 1, 2))],
        hasMore: false,
      ),
    );

    await tester.pumpApp(const HistoryPage(mode: HistoryPageMode.full), [
      historyPagedProvider.overrideWith(() => notifier),
      isPremiumProvider.overrideWithValue(true),
    ]);

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('history.upsell.banner')),
      findsNothing,
    );
    expect(find.text('Re-use past prints instantly'), findsNothing);
  });

  testWidgets('shows overflow hint once and dismisses it after menu open', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final notifier = _FakeHistoryPagedNotifier(
      HistoryPagedState.initial().copyWith(
        items: [_entry('1', 'Benchy', DateTime.utc(2024, 1, 2))],
        hasMore: false,
      ),
    );
    final paywallPresenter = FakePaywallPresenter();

    await tester.pumpApp(const HistoryPage(mode: HistoryPageMode.full), [
      historyPagedProvider.overrideWith(() => notifier),
      paywallPresenterProvider.overrideWithValue(paywallPresenter),
    ]);

    await tester.pumpAndSettle();

    expect(find.text('More actions in ⋯'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey<String>('history.item.Benchy.menu')),
    );
    await tester.pumpAndSettle();

    expect(find.text('More actions in ⋯'), findsNothing);
    expect(
      find.byKey(const ValueKey<String>('history.upsell.banner')),
      findsOneWidget,
    );

    await tester.pumpApp(const HistoryPage(mode: HistoryPageMode.full), [
      historyPagedProvider.overrideWith(() => notifier),
      paywallPresenterProvider.overrideWithValue(paywallPresenter),
    ]);

    await tester.pumpAndSettle();

    expect(find.text('More actions in ⋯'), findsNothing);
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

    await tester.pumpApp(const HistoryPage(mode: HistoryPageMode.full), [
      historyPagedProvider.overrideWith(() => notifier),
      shouldShowProPromotionProvider.overrideWithValue(false),
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

    await tester.pumpApp(const HistoryPage(mode: HistoryPageMode.full), [
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

  testWidgets('renders teaser state with sample export preview', (
    tester,
  ) async {
    await tester.pumpApp(const HistoryPage(mode: HistoryPageMode.teaser));

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('history.teaser.state')),
      findsOneWidget,
    );
    expect(find.text('Save & export history with Pro'), findsOneWidget);
    expect(
      find.byKey(const ValueKey<String>('history.export.preview.entry')),
      findsOneWidget,
    );

    await tester.tap(
      find.byKey(const ValueKey<String>('history.export.preview.entry')),
    );
    await tester.pumpAndSettle();

    expect(find.text('[Sample]'), findsWidgets);
    final csvPreviewFinder = find.byKey(
      const ValueKey<String>('history.export.preview.csv'),
    );
    expect(csvPreviewFinder, findsOneWidget);

    final csvPreview =
        tester.widget<SelectableText>(csvPreviewFinder).data ?? '';
    expect(csvPreview, contains('Bambu Lab A1'));
    expect(csvPreview, contains('Prusa MK4S'));

    await tester.tap(
      find.byKey(
        const ValueKey<String>('history.export.preview.download.button'),
      ),
    );
    await tester.pump();

    expect(find.byType(HistoryExportPreviewSheet), findsOneWidget);
    expect(find.byType(HistoryTeaserState), findsOneWidget);
  });

  testWidgets('premium history mode shows full controls without teaser', (
    tester,
  ) async {
    final notifier = _FakeHistoryPagedNotifier(
      HistoryPagedState.initial().copyWith(hasMore: false),
    );

    await tester.pumpApp(const HistoryPage(mode: HistoryPageMode.full), [
      historyPagedProvider.overrideWith(() => notifier),
    ]);

    await tester.pumpAndSettle();

    expect(
      find.byKey(const ValueKey<String>('history.teaser.state')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('history.export.preview.entry')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey<String>('history.export.button')),
      findsOneWidget,
    );
  });
}
