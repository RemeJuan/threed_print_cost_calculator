import 'package:bot_toast/bot_toast.dart';
import 'package:riverpod/riverpod.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/database/services/material_stock_service.dart';
import 'package:threed_print_cost_calculator/history/model/history_model.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_policy.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/purchases/premium_upsell_helper.dart';

final calculatorSaveCoordinatorProvider = Provider<CalculatorSaveCoordinator>(
  CalculatorSaveCoordinator.new,
);

class CalculatorSaveCoordinator {
  CalculatorSaveCoordinator(this.ref);

  final Ref ref;

  Future<void> savePrint(
    HistoryModel value, {
    required String errorMessage,
    required String successMessage,
  }) async {
    final count = await ref.read(historyRepositoryProvider).countHistory();
    final access = ref
        .read(premiumAccessPolicyProvider)
        .canSaveHistoryItem(count);
    if (!access.allowed) {
      final upgraded = await requirePremium(
        ref.read(paywallPresenterProvider),
        FeatureAccess(
          allowed: access.allowed,
          feature: PremiumFeature.saveToHistory,
          denyReason: access.denyReason,
        ),
        purchaseSource: 'save_history',
        recheck: () async {
          final c = await ref.read(historyRepositoryProvider).countHistory();
          return ref
              .read(premiumAccessPolicyProvider)
              .canSaveHistoryItem(c)
              .allowed;
        },
      );
      if (!upgraded) return;
    }

    try {
      await ref.read(historyRepositoryProvider).saveHistory(value);
    } catch (_) {
      BotToast.showText(text: errorMessage);
      return;
    }

    try {
      await ref.read(materialStockServiceProvider).deductForSavedHistory(value);
    } catch (error, stackTrace) {
      ref
          .read(appLoggerProvider)
          .warn(
            AppLogCategory.db,
            'History saved but material stock deduction failed',
            error: error,
            stackTrace: stackTrace,
          );
    }

    BotToast.showText(text: successMessage);
  }
}
