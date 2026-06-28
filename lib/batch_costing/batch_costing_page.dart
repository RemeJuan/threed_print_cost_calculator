import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_costing_page_actions.dart';
import 'package:threed_print_cost_calculator/batch_costing/helpers/batch_costing_page_state_sync.dart';
import 'package:threed_print_cost_calculator/batch_costing/providers/batch_costing_notifier.dart';
import 'package:threed_print_cost_calculator/batch_costing/widgets/batch_costing_item_card.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
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
              if (items.isNotEmpty) ...[
                Align(
                  alignment: AlignmentDirectional.center,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppTertiaryButton(
                        onPressed: () => _actions.addManualItem(context),
                        label: l10n.batchCostingReviewAddManualItemButton,
                        icon: const Icon(Icons.add),
                      ),
                      const SizedBox(width: kAppSpace8),
                      if (policy.isPremium)
                        Opacity(
                          opacity: batchImportAllowed ? 1 : 0.55,
                          child: AppTertiaryButton(
                            onPressed: () =>
                                _actions.openBatchGcodeImport(context),
                            label: batchImportLabel,
                            icon: const Icon(Icons.upload_file),
                          ),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: kAppSpace16),
              ],
              Expanded(
                child: items.isEmpty
                    ? _emptyState(
                        context,
                        l10n,
                        batchImportAllowed,
                        batchImportLabel,
                      )
                    : ListView.separated(
                        itemCount: items.length,
                        separatorBuilder: (context, _) =>
                            const SizedBox(height: kAppSpace12),
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return BatchCostingItemCard(
                            item: item,
                            quantityController: _stateSync.controllerFor(item),
                            initiallyExpanded: _stateSync.isExpanded(item.id),
                            onExpansionChanged: (expanded) {
                              setState(() {
                                _stateSync.setExpanded(item.id, expanded);
                              });
                            },
                            onEdit: () => _actions.editItem(context, item),
                          );
                        },
                      ),
              ),
              if (items.isNotEmpty) ...[
                const SizedBox(height: kAppSpace16),
                SafeArea(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      AppPrimaryButton(
                        onPressed: _actions.hasMissingFields(items)
                            ? null
                            : () =>
                                  _actions.continueToPrinterAssignment(context),
                        icon: const Icon(Icons.arrow_forward),
                        label: l10n.batchCostingReviewContinueButton,
                      ),
                      const SizedBox(height: kAppSpace12),
                      AppSecondaryButton(
                        onPressed: () =>
                            _actions.showStartNewBatchDialog(context),
                        label: l10n.batchCostingSummaryStartNewBatchButton,
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _emptyState(
    BuildContext context,
    AppLocalizations l10n,
    bool batchImportAllowed,
    String batchImportLabel,
  ) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 56,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            l10n.batchCostingReviewEmptyTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            l10n.batchCostingReviewEmptyBody,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 24),
          Opacity(
            opacity: batchImportAllowed ? 1 : 0.55,
            child: AppPrimaryButton(
              onPressed: () => _actions.openBatchGcodeImport(context),
              icon: const Icon(Icons.upload_file),
              label: batchImportLabel,
            ),
          ),
          const SizedBox(height: 12),
          AppSecondaryButton(
            onPressed: () => _actions.addManualItem(context),
            icon: const Icon(Icons.add),
            label: l10n.batchCostingReviewAddManualItemButton,
          ),
        ],
      ),
    );
  }
}
