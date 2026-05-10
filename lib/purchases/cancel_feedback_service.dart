import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/database/repositories/history_repository.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/services/app_usage_service.dart';

const cancelFeedbackPromptShownStatePreferenceKey =
    'cancel_feedback_prompt_shown_state';
const cancelFeedbackPromptSubmittedStatePreferenceKey =
    'cancel_feedback_prompt_submitted_state';

final cancelFeedbackServiceProvider = Provider<CancelFeedbackService>(
  CancelFeedbackService.new,
);

class CancelFeedbackService {
  CancelFeedbackService(this.ref);

  final Ref ref;

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);
  HistoryRepository get _historyRepository =>
      ref.read(historyRepositoryProvider);
  AppUsageService get _usageService => ref.read(appUsageServiceProvider);

  Future<bool> shouldShowPrompt(PremiumState state) async {
    final stateKey = state.cancellationStateKey;
    if (stateKey == null) return false;

    final shownState = _prefs.getString(
      cancelFeedbackPromptShownStatePreferenceKey,
    );
    final submittedState = _prefs.getString(
      cancelFeedbackPromptSubmittedStatePreferenceKey,
    );

    return shownState != stateKey && submittedState != stateKey;
  }

  Future<void> markPromptShown(PremiumState state) async {
    final stateKey = state.cancellationStateKey;
    if (stateKey == null) return;

    await _prefs.setString(
      cancelFeedbackPromptShownStatePreferenceKey,
      stateKey,
    );
  }

  Future<void> submitFeedback({
    required PremiumState state,
    required String reason,
  }) async {
    final payload = await _buildPayload(state);
    await AppAnalytics.trialCancelFeedbackSubmitted(
      reason: reason,
      platform: payload.platform,
      appVersion: payload.appVersion,
      daysIntoTrial: payload.daysIntoTrial,
      entitlementType: payload.entitlementType,
      calculationCountBucket: payload.calculationCountBucket,
      hasUsedGcodeImport: payload.hasUsedGcodeImport,
      hasSavedHistory: payload.hasSavedHistory,
    );

    final stateKey = state.cancellationStateKey;
    if (stateKey != null) {
      await _prefs.setString(
        cancelFeedbackPromptSubmittedStatePreferenceKey,
        stateKey,
      );
    }
  }

  Future<void> dismissFeedback(PremiumState state) async {
    final payload = await _buildPayload(state);
    await AppAnalytics.trialCancelFeedbackDismissed(
      platform: payload.platform,
      appVersion: payload.appVersion,
      daysIntoTrial: payload.daysIntoTrial,
      entitlementType: payload.entitlementType,
      calculationCountBucket: payload.calculationCountBucket,
      hasUsedGcodeImport: payload.hasUsedGcodeImport,
      hasSavedHistory: payload.hasSavedHistory,
    );
  }

  Future<_CancelFeedbackPayload> _buildPayload(PremiumState state) async {
    final appVersion = await _readAppVersion();
    final historyCount = await _historyRepository.countHistory();
    final calculationCount = max(historyCount, _usageService.calculationCount);
    final hasSavedHistory = historyCount > 0;
    final hasUsedGcodeImport =
        _usageService.hasUsedGcodeImport ||
        ref.read(calculatorProvider).importedFromGcode ||
        await _historyRepository.hasImportedFromGcodeHistory();

    return _CancelFeedbackPayload(
      platform: _platformValue(state),
      appVersion: appVersion,
      daysIntoTrial: _daysIntoTrial(state),
      entitlementType: state.entitlementType,
      calculationCountBucket: AppUsageService.calculationCountBucket(
        calculationCount,
      ),
      hasUsedGcodeImport: hasUsedGcodeImport,
      hasSavedHistory: hasSavedHistory,
    );
  }

  Future<String> _readAppVersion() async {
    final info = await PackageInfo.fromPlatform();
    if (info.buildNumber.isEmpty) return info.version;
    return '${info.version}+${info.buildNumber}';
  }

  int _daysIntoTrial(PremiumState state) {
    if (state.entitlementType != 'trial') return 0;
    final originalPurchaseDate = state.originalPurchaseDate;
    if (originalPurchaseDate == null) return 0;

    final now = DateTime.now();
    if (originalPurchaseDate.isAfter(now)) return 0;
    return now.difference(originalPurchaseDate).inDays;
  }

  String _platformValue(PremiumState state) {
    if (state.platform != 'unknown') return state.platform;

    return switch (defaultTargetPlatform) {
      TargetPlatform.android => 'android',
      TargetPlatform.iOS => 'ios',
      TargetPlatform.macOS => 'macos',
      TargetPlatform.windows => 'windows',
      TargetPlatform.linux => 'linux',
      TargetPlatform.fuchsia => 'fuchsia',
    };
  }
}

class _CancelFeedbackPayload {
  const _CancelFeedbackPayload({
    required this.platform,
    required this.appVersion,
    required this.daysIntoTrial,
    required this.entitlementType,
    required this.calculationCountBucket,
    required this.hasUsedGcodeImport,
    required this.hasSavedHistory,
  });

  final String platform;
  final String appVersion;
  final int daysIntoTrial;
  final String entitlementType;
  final String calculationCountBucket;
  final bool hasUsedGcodeImport;
  final bool hasSavedHistory;
}
