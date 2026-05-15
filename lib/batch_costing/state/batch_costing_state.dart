import 'package:formz/formz.dart';

import 'package:threed_print_cost_calculator/batch_costing/model/batch_costing_item.dart';

class BatchCostingState with FormzMixin {
  final List<BatchCostingItem> items;

  BatchCostingState({List<BatchCostingItem>? items})
    : items = List.unmodifiable(items ?? const <BatchCostingItem>[]);

  BatchCostingState copyWith({List<BatchCostingItem>? items}) {
    return BatchCostingState(items: items ?? this.items);
  }

  @override
  List<FormzInput> get inputs => const [];
}
