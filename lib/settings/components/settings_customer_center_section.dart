import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/customer_center_presenter.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

class SettingsCustomerCenterSection extends ConsumerStatefulWidget {
  const SettingsCustomerCenterSection({super.key});

  @override
  ConsumerState<SettingsCustomerCenterSection> createState() =>
      _SettingsCustomerCenterSectionState();
}

class _SettingsCustomerCenterSectionState
    extends ConsumerState<SettingsCustomerCenterSection> {
  bool _isBusy = false;

  static bool get isSupportedPlatform => customerCenterSupportedPlatform();

  @override
  Widget build(BuildContext context) {
    if (!isSupportedPlatform) return const SizedBox.shrink();

    final l10n = AppLocalizations.of(context)!;
    return AppSurfaceCard(
      key: const ValueKey<String>('settings.customer-center.section'),
      padding: const EdgeInsets.all(kAppSpace12),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: const Icon(
          Icons.manage_accounts_outlined,
          color: ICON_PRIMARY,
        ),
        title: Text(
          l10n.managePurchasesLabel,
          key: const ValueKey<String>('settings.customer-center.title'),
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: TEXT_PRIMARY,
            fontWeight: FontWeight.w600,
          ),
        ),
        trailing: _isBusy
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : const Icon(Icons.chevron_right, color: ICON_MUTED),
        onTap: _isBusy ? null : _presentCustomerCenter,
      ),
    );
  }

  Future<void> _presentCustomerCenter() async {
    if (_isBusy) return;
    setState(() => _isBusy = true);

    try {
      await ref.read(customerCenterPresenterProvider).present();
      ref.read(appRefreshProvider.notifier).refresh();
    } catch (_) {
      if (mounted) {
        final l10n = AppLocalizations.of(context)!;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.managePurchasesError),
            action: SnackBarAction(
              label: l10n.retryButton,
              onPressed: _presentCustomerCenter,
            ),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBusy = false);
    }
  }
}

@visibleForTesting
bool customerCenterSupportedPlatform({
  bool isWeb = kIsWeb,
  TargetPlatform? platform,
}) {
  final targetPlatform = platform ?? defaultTargetPlatform;
  return !isWeb &&
      (targetPlatform == TargetPlatform.iOS ||
          targetPlatform == TargetPlatform.android);
}
