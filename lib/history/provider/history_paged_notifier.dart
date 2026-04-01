import 'package:flutter/foundation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:sembast/sembast.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/history/index/printer_index.dart';

const int _pageSize = 25;

class HistoryPagedState {
  // Use MapEntry<key, valueMap> so the UI can access .key and .value like a RecordSnapshot.
  final List<MapEntry<dynamic, Map<String, dynamic>>> items;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  final String query;
  final int page;

  const HistoryPagedState({
    required this.items,
    required this.hasMore,
    required this.isLoading,
    this.error,
    required this.query,
    required this.page,
  });

  factory HistoryPagedState.initial() => const HistoryPagedState(
    items: <MapEntry<dynamic, Map<String, dynamic>>>[],
    hasMore: true,
    isLoading: false,
    error: null,
    query: '',
    page: 0,
  );

  HistoryPagedState copyWith({
    List<MapEntry<dynamic, Map<String, dynamic>>>? items,
    bool? hasMore,
    bool? isLoading,
    String? error,
    String? query,
    int? page,
  }) {
    return HistoryPagedState(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      query: query ?? this.query,
      page: page ?? this.page,
    );
  }
}

// Notifier that manages paged history loading and query changes.
class HistoryPagedNotifier extends Notifier<HistoryPagedState> {
  int _loadGeneration = 0; // generation counter to prevent stale updates

  @override
  HistoryPagedState build() => HistoryPagedState.initial();

  Database get _db => ref.read(databaseProvider);

  StoreRef<Object?, Map<String, Object?>> get _store =>
      stringMapStoreFactory.store('history')
          as StoreRef<Object?, Map<String, Object?>>;

  Future<void> setQuery(String q) async {
    state = state.copyWith(
      query: q,
      page: 0,
      items: [],
      hasMore: true,
      error: null,
    );
    _loadGeneration++;
    final currentGen = _loadGeneration;
    await _loadPage(reset: true, generation: currentGen);
  }

  Future<void> refresh() async {
    state = state.copyWith(page: 0, items: [], hasMore: true, error: null);
    _loadGeneration++;
    final currentGen = _loadGeneration;
    await _loadPage(reset: true, generation: currentGen);
  }

  Future<void> loadMore() async {
    if (state.isLoading) return;
    if (!state.hasMore) return;
    _loadGeneration++;
    final currentGen = _loadGeneration;
    await _loadPage(reset: false, generation: currentGen);
  }

  Future<void> _loadPage({required bool reset, required int generation}) async {
    try {
      final nextPage = reset ? 0 : state.page + 1;
      state = state.copyWith(isLoading: true, error: null);

      final offset = nextPage * _pageSize;
      // (finder would be built when needed) -- not used directly here.

      int totalCount = 0;
      final pageEntries = <MapEntry<dynamic, Map<String, dynamic>>>[];

      final q = state.query.trim();
      if (q.isEmpty) {
        // Empty query: do DB-side pagination (count + paged find)
        totalCount = await _store.count(_db);
        final records = await _store.find(
          _db,
          finder: Finder(
            sortOrders: [SortOrder('date', false)],
            limit: _pageSize,
            offset: offset,
          ),
        );
        for (final r in records) {
          final value = Map<String, dynamic>.from(r.value as Map);
          pageEntries.add(MapEntry(r.key, value));
        }
      } else {
        // Non-empty: prefer printer index if it returns matches
        // Wrap ref.read to match ReaderFunc: a generic function that accepts an object
        // and delegates to ref.read with the correct generic type.
        final indexHelpers = PrinterIndexHelpers.fromRef(ref);
        final indexKeys = await indexHelpers.getKeysMatchingPrinter(q);
        queryCount++;

        if (indexKeys.isNotEmpty) {
          final allEntries = await _findEntriesByKeys(indexKeys);
          queryCount++;
          totalCount = allEntries.length;
          final slice = allEntries.skip(offset).take(_pageSize).toList();
          pageEntries.addAll(slice);
        } else {
          // No index matches; fall back to scanning all records and filter by name/printer
          final all = await _store.find(
            _db,
            finder: Finder(sortOrders: [SortOrder('date', false)]),
          );
          final qLower = q.toLowerCase();
          final filtered = all.where((r) {
            final item = r.value as Map<String, dynamic>;
            final name = (item['name']?.toString() ?? '').toLowerCase();
            final printer = (item['printer']?.toString() ?? '').toLowerCase();
            return name.contains(qLower) || printer.contains(qLower);
          }).toList();
          totalCount = filtered.length;
          for (final r in filtered.skip(offset).take(_pageSize)) {
            pageEntries.add(
              MapEntry(r.key, Map<String, dynamic>.from(r.value as Map)),
            );
          }
        }
      }

      // Ensure generation matches before applying results — otherwise this load is stale
      if (generation != _loadGeneration) return;

      final combined = reset ? pageEntries : [...state.items, ...pageEntries];
      final hasMore = combined.length < totalCount;

      state = state.copyWith(
        items: combined,
        isLoading: false,
        hasMore: hasMore,
        page: nextPage,
      );
    } catch (e, st) {
      if (kDebugMode) print('HistoryPagedNotifier._loadPage error: $e\n$st');
      // Only update state for the generation that started this load — ignore
      // stale failures from earlier loads.
      if (generation != _loadGeneration) return;
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<List<MapEntry<dynamic, Map<String, dynamic>>>> _findEntriesByKeys(
    Iterable<dynamic> keys,
  ) async {
    final uniqueKeys = <dynamic>[];
    final seenKeys = <dynamic>{};
    for (final key in keys) {
      if (seenKeys.add(key)) {
        uniqueKeys.add(key);
      }
    }

    if (uniqueKeys.isEmpty) {
      return const <MapEntry<dynamic, Map<String, dynamic>>>[];
    }

    final records = await _store.records(uniqueKeys).getSnapshots(_db);

    final entries = records
        .whereType<RecordSnapshot<Object?, Map<String, Object?>>>()
        .map(
          (record) => MapEntry(
            record.key,
            Map<String, dynamic>.from(record.value as Map),
          ),
        )
        .toList();

    entries.sort((a, b) {
      final aDate = _parseDate(a.value['date']);
      final bDate = _parseDate(b.value['date']);
      return bDate.compareTo(aDate);
    });

    return entries;
  }

  DateTime _parseDate(dynamic dateVal) {
    try {
      if (dateVal is DateTime) return dateVal.toUtc();
      return DateTime.parse(dateVal.toString()).toUtc();
    } catch (_) {
      return DateTime.fromMillisecondsSinceEpoch(0);
    }
  }
}

final historyPagedProvider =
    NotifierProvider<HistoryPagedNotifier, HistoryPagedState>(
      HistoryPagedNotifier.new,
    );
