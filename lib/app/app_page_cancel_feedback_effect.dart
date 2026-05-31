import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/app/app_page_modal_sheet_guard.dart';
import 'package:threed_print_cost_calculator/purchases/cancel_feedback_service.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_keys.dart';
import 'package:threed_print_cost_calculator/purchases/cancel_feedback_sheet.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

void useAppPageCancelFeedbackEffect({
  required BuildContext context,
  required WidgetRef ref,
}) {
  final cancelFeedbackHandledStateKey = useRef<String?>(null);
  final store = ref.read(premiumLocalStoreProvider);

  void reportCancelFeedbackEffectError(Object error, StackTrace stackTrace) {
    FlutterError.reportError(
      FlutterErrorDetails(
        exception: error,
        stack: stackTrace,
        library: 'app_page_cancel_feedback_effect',
        context: ErrorDescription('while handling app page cancel feedback'),
      ),
    );
  }

  ref.listen<PremiumState>(premiumStateProvider, (previous, next) async {
    if (next.isLoading || next.userId.isEmpty) return;

    final cancellationStateKey = next.cancellationStateKey;

    try {
      final isFirstResolvedStateForUser =
          previous?.isLoading != false || previous?.userId != next.userId;

      if (isFirstResolvedStateForUser) {
        final runCount =
            int.tryParse(store.readSync(runCountPreferenceKey) ?? '') ?? 0;
        await store.write(runCountPreferenceKey, (runCount + 1).toString());
      }

      if (cancellationStateKey == null ||
          cancelFeedbackHandledStateKey.value == cancellationStateKey) {
        return;
      }

      cancelFeedbackHandledStateKey.value = cancellationStateKey;

      final cancelFeedbackService = ref.read(cancelFeedbackServiceProvider);
      final shouldShowPrompt = await cancelFeedbackService.shouldShowPrompt(
        next,
      );
      if (!shouldShowPrompt) {
        return;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        try {
          if (!context.mounted) return;
          if (!canShowAppPageModalSheet(context)) {
            if (cancelFeedbackHandledStateKey.value == cancellationStateKey) {
              cancelFeedbackHandledStateKey.value = null;
            }
            return;
          }

          await cancelFeedbackService.markPromptShown(next);
          if (!context.mounted) return;

          await showCancelFeedbackSheet(
            context,
            onDismiss: () => cancelFeedbackService.dismissFeedback(next),
            onSubmitted: (reason) => cancelFeedbackService.submitFeedback(
              state: next,
              reason: reason.analyticsValue,
            ),
          );
        } catch (error, stackTrace) {
          if (cancelFeedbackHandledStateKey.value == cancellationStateKey) {
            cancelFeedbackHandledStateKey.value = null;
          }
          reportCancelFeedbackEffectError(error, stackTrace);
        }
      });
    } catch (error, stackTrace) {
      if (cancellationStateKey != null &&
          cancelFeedbackHandledStateKey.value == cancellationStateKey) {
        cancelFeedbackHandledStateKey.value = null;
      }
      reportCancelFeedbackEffectError(error, stackTrace);
    }
  });
}
