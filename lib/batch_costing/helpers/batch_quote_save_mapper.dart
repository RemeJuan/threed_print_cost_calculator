import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_summary_calculator.dart';
import 'package:threed_print_cost_calculator/batch_costing/state/batch_costing_state.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';

typedef BatchQuoteClock = DateTime Function();

HistoryModel mapBatchQuoteHistoryModel({
  required String name,
  required BatchCostingState state,
  required BatchSummaryResult summary,
  BatchQuoteClock clock = DateTime.now,
}) {
  return HistoryModel.batchQuote(
    name: name,
    date: clock(),
    state: state,
    summary: summary,
  );
}
