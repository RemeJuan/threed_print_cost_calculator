import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_costing_page_actions.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_costing_page_state_sync.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_costing_empty_state.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_costing_page_footer_actions.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_costing_page_header_actions.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_costing_page_item_list.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_screen_header.dart';
import 'package:threed_print_cost_calculator/shared/widgets/home_button.dart';

class BatchCostingPage extends ConsumerStatefulWidget {
  const BatchCostingPage({super.key});

  @override
  ConsumerState<BatchCostingPage> createState() => _BatchCostingPageState();
}

class _BatchCostingPageState extends ConsumerState<BatchCostingPage> {
  final BatchCostingPageStateSync _stateSync = BatchCostingPageStateSync();
  late final BatchCostingPageActions _actions = BatchCostingPageActions(ref);

  @override
  void initState() {
    super.initState();
    ref.listenManual(batchCostingProvider, (prev, next) {
      _stateSync.sync(next.items);
    });
  }

  @override
  void dispose() {
    _stateSync.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final batchState = ref.watch(batchCostingProvider);
    final items = batchState.items;
    final policy = ref.watch(premiumAccessPolicyProvider);
    final batchImportAllowed = policy.batchGcodeImport().allowed;
    final batchImportLabel = batchImportAllowed
        ? l10n.batchCostingReviewImportGcodeButton
        : l10n.batchCostingReviewImportGcodeButtonPremium;

    if (_stateSync.needsInitialSync) {
      _stateSync.sync(items);
    }

    return Scaffold(
      appBar: AppScreenHeader(
        title: l10n.batchCostingReviewAppBarTitle,
        actions: [homeButton(context)],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(kAppSpace16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l10n.batchCostingReviewSubtitle,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: kAppSpace16),
              BatchCostingPageHeaderActions(
                hasItems: items.isNotEmpty,
                isPremium: policy.isPremium,
                batchImportAllowed: batchImportAllowed,
                addManualLabel: l10n.batchCostingReviewAddManualItemButton,
                importLabel: batchImportLabel,
                onAddManual: () => _actions.addManualItem(context),
                onImport: () => _actions.openBatchGcodeImport(context),
              ),
              if (items.isNotEmpty) const SizedBox(height: kAppSpace16),
              Expanded(
                child: items.isEmpty
                    ? BatchCostingEmptyState(
                        title: l10n.batchCostingReviewEmptyTitle,
                        body: l10n.batchCostingReviewEmptyBody,
                        importLabel: batchImportLabel,
                        addManualLabel:
                            l10n.batchCostingReviewAddManualItemButton,
                        batchImportAllowed: batchImportAllowed,
                        onImport: () => _actions.openBatchGcodeImport(context),
                        onAddManual: () => _actions.addManualItem(context),
                      )
                    : BatchCostingPageItemList(
                        items: items,
                        controllerFor: _stateSync.controllerFor,
                        isExpanded: _stateSync.isExpanded,
                        onExpansionChanged: (item, expanded) {
                          setState(() {
                            _stateSync.setExpanded(item.id, expanded);
                          });
                        },
                        onEdit: (item) => _actions.editItem(context, item),
                      ),
              ),
              if (items.isNotEmpty) ...[
                const SizedBox(height: kAppSpace16),
                BatchCostingPageFooterActions(
                  continueEnabled: !_actions.hasMissingFields(items),
                  onContinue: () =>
                      _actions.continueToPrinterAssignment(context),
                  onStartNewBatch: () =>
                      _actions.showStartNewBatchDialog(context),
                  continueLabel: l10n.batchCostingReviewContinueButton,
                  startNewBatchLabel:
                      l10n.batchCostingSummaryStartNewBatchButton,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
