import 'dart:async';

import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/database/repositories/materials_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/printers_repository.dart';
import 'package:threed_print_cost_calculator/database/repositories/settings_repository.dart';
import 'package:threed_print_cost_calculator/history/provider/history_paged_notifier.dart';
import 'package:threed_print_cost_calculator/history/provider/history_providers.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/settings/providers/materials_notifier.dart';
import 'package:threed_print_cost_calculator/settings/providers/printers_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/pro_promotion_visibility.dart';

import 'package:threed_print_cost_calculator/shared/test_tools/enable_premium_code_dialog.dart';
import 'package:threed_print_cost_calculator/shared/test_tools/test_data_confirmation_dialog.dart';
import 'package:threed_print_cost_calculator/shared/test_tools/test_data_service.dart';
import 'package:threed_print_cost_calculator/shared/test_tools/test_data_tools_dialog.dart';

class SettingsVersionTapTarget extends ConsumerStatefulWidget {
  const SettingsVersionTapTarget({super.key, this.tapTargetKey});

  final Key? tapTargetKey;

  @override
  ConsumerState<SettingsVersionTapTarget> createState() =>
      _SettingsVersionTapTargetState();
}

class _SettingsVersionTapTargetState
    extends ConsumerState<SettingsVersionTapTarget> {
  static const int _requiredTaps = 5;
  static const Duration _timeout = Duration(seconds: 3);

  final Future<PackageInfo> _packageInfo = PackageInfo.fromPlatform();
  Timer? _timer;
  int _tapCount = 0;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _handleTap() {
    _tapCount += 1;
    _timer?.cancel();
    _timer = Timer(_timeout, () {
      if (!mounted) return;
      setState(() {
        _tapCount = 0;
      });
    });

    if (_tapCount < _requiredTaps) {
      setState(() {});
      return;
    }

    _tapCount = 0;
    _timer?.cancel();
    setState(() {});
    unawaited(_openToolsDialog());
  }

  Future<void> _openToolsDialog() async {
    final container =
        appProviderContainer ??
        ProviderScope.containerOf(context, listen: false);
    final l10n = AppLocalizations.of(context)!;
    final messenger = ScaffoldMessenger.maybeOf(context);

    final action = await _showToolsDialog();

    if (action == null) return;
    switch (action) {
      case TestDataAction.seed:
        await _confirmAndRun(
          container: container,
          messenger: messenger,
          title: l10n.seedTestDataConfirmTitle,
          body: l10n.seedTestDataConfirmBody,
          confirmLabel: l10n.seedTestDataButton,
          run: () => container.read(testDataServiceProvider).seed(),
          successMessage: l10n.testDataSeededMessage,
          failureMessage: l10n.testDataActionFailedMessage,
        );
      case TestDataAction.purge:
        await _confirmAndRun(
          container: container,
          messenger: messenger,
          title: l10n.purgeLocalDataConfirmTitle,
          body: l10n.purgeLocalDataConfirmBody,
          confirmLabel: l10n.purgeLocalDataButton,
          run: () => container.read(testDataServiceProvider).purge(),
          successMessage: l10n.testDataPurgedMessage,
          failureMessage: l10n.testDataActionFailedMessage,
        );
      case TestDataAction.enablePremium:
        await _enablePremiumFlow(
          container: container,
          messenger: messenger,
          l10n: l10n,
        );
    }
  }

  Widget _toastDialog(Widget child) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (_) => Material(
            type: MaterialType.transparency,
            child: Center(child: child),
          ),
        ),
      ],
    );
  }

  Future<TestDataAction?> _showToolsDialog() async {
    final completer = Completer<TestDataAction?>();
    BotToast.cleanAll();
    late final CancelFunc cancel;
    cancel = BotToast.showCustomNotification(
      duration: const Duration(minutes: 5),
      onlyOne: true,
      toastBuilder: (_) => _toastDialog(
        TestDataToolsDialog(
          onAction: (action) {
            if (!completer.isCompleted) completer.complete(action);
            cancel();
          },
        ),
      ),
    );

    return completer.future;
  }

  Future<bool> _showConfirmationDialog({
    required String title,
    required String body,
    required String confirmLabel,
  }) async {
    final completer = Completer<bool>();
    BotToast.cleanAll();
    late final CancelFunc cancel;
    cancel = BotToast.showCustomNotification(
      duration: const Duration(minutes: 5),
      onlyOne: true,
      toastBuilder: (_) => _toastDialog(
        TestDataConfirmationDialog(
          title: title,
          body: body,
          confirmLabel: confirmLabel,
          onDecision: (confirmed) {
            if (!completer.isCompleted) completer.complete(confirmed);
            cancel();
          },
        ),
      ),
    );

    return completer.future;
  }

  Future<bool> _showEnablePremiumDialog() async {
    final completer = Completer<bool>();
    BotToast.cleanAll();
    late final CancelFunc cancel;
    cancel = BotToast.showCustomNotification(
      duration: const Duration(minutes: 5),
      onlyOne: true,
      toastBuilder: (_) => _toastDialog(
        EnablePremiumCodeDialog(
          onSubmit: (code) async => code == _expectedCode(),
          onAccepted: () {
            if (!completer.isCompleted) completer.complete(true);
            cancel();
          },
          onCancelled: () {
            if (!completer.isCompleted) completer.complete(false);
            cancel();
          },
        ),
      ),
    );

    return completer.future;
  }

  Future<void> _enablePremiumFlow({
    required ProviderContainer container,
    required ScaffoldMessengerState? messenger,
    required AppLocalizations l10n,
  }) async {
    final codeOk = await _showEnablePremiumDialog();

    if (!codeOk) return;

    final result = await container
        .read(testDataServiceProvider)
        .enablePremiumAndSeed();

    if (result.success) {
      await _refreshAppState(container);
      messenger?.showSnackBar(
        SnackBar(content: Text(l10n.testDataSeededMessage)),
      );
      return;
    }

    messenger?.showSnackBar(
      SnackBar(content: Text(l10n.testDataActionFailedMessage)),
    );
  }

  String _expectedCode() {
    final now = DateTime.now();
    return '${now.year.toString().padLeft(4, '0')}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _confirmAndRun({
    required ProviderContainer container,
    required ScaffoldMessengerState? messenger,
    required String title,
    required String body,
    required String confirmLabel,
    required Future<TestDataOperationResult> Function() run,
    required String successMessage,
    required String failureMessage,
  }) async {
    final confirmed = await _showConfirmationDialog(
      title: title,
      body: body,
      confirmLabel: confirmLabel,
    );

    if (!confirmed) return;

    final result = await run();

    if (result.success) {
      await _refreshAppState(container);
      messenger?.showSnackBar(SnackBar(content: Text(successMessage)));
      return;
    }

    messenger?.showSnackBar(SnackBar(content: Text(failureMessage)));
  }

  Future<void> _refreshAppState(ProviderContainer container) async {
    container.read(appRefreshProvider.notifier).refresh();
    container.invalidate(settingsStreamProvider);
    container.invalidate(printersStreamProvider);
    container.invalidate(materialsStreamProvider);
    container.refresh(hideProPromotionsProvider);
    container.invalidate(printersProvider);
    container.invalidate(materialsProvider);
    container.invalidate(calculatorProvider);
    container.invalidate(historyPagedProvider);
    container.invalidate(historyRecordsProvider);

    await container.read(historyPagedProvider.notifier).refresh();
    final calculator = container.read(calculatorProvider.notifier);
    await calculator.init();
    calculator.submit();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return FutureBuilder<PackageInfo>(
      future: _packageInfo,
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '';
        return GestureDetector(
          key:
              widget.tapTargetKey ??
              const ValueKey<String>('settings.version.tapTarget'),
          behavior: HitTestBehavior.opaque,
          onTap: _handleTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: SizedBox(
              width: double.infinity,
              child: Center(
                child: Text(
                  l10n.versionLabel(version),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
