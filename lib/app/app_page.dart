import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/app/app_page_announcement_effect.dart';
import 'package:threed_print_cost_calculator/app/app_page_cancel_feedback_effect.dart';
import 'package:threed_print_cost_calculator/app/app_page_shell_controller.dart';
import 'package:threed_print_cost_calculator/app/app_page_shell_config.dart';
import 'package:threed_print_cost_calculator/app/help_support/help_support_page.dart';
import 'package:threed_print_cost_calculator/app/widgets/update_prompt_banner.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_access_providers.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/providers/whats_new_provider.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_screen_header.dart';
import 'package:threed_print_cost_calculator/settings/interface_settings/interface_settings_repository.dart';

class AppPage extends HookConsumerWidget {
  const AppPage({super.key});

  @override
  Widget build(context, ref) {
    final l10n = AppLocalizations.of(context)!;
    final policy = ref.watch(premiumAccessPolicyProvider);
    final interfaceSettings = ref.watch(interfaceSettingsProvider);

    useEffect(() {
      registerAppProviderContainer(
        ProviderScope.containerOf(context, listen: false),
      );
      return null;
    }, const []);

    final announcementAsync = ref.watch(currentAnnouncementProvider);
    useAppPageAnnouncementEffect(
      context: context,
      ref: ref,
      announcementAsync: announcementAsync,
      isPremium: policy.isPremium,
    );
    useAppPageCancelFeedbackEffect(context: context, ref: ref);

    final tabs = buildAppPageShellTabOrder(policy, interfaceSettings);
    final controller = useAppPageShellController(
      ref: ref,
      tabs: tabs,
      onMaterialsOpened: () =>
          AppAnalytics.safeLog(AppAnalytics.materialsViewOpened),
    );

    final shellTabs = buildAppPageShellTabs(
      context: context,
      l10n: l10n,
      policy: policy,
      tabOrder: tabs,
      showGcodeAction: interfaceSettings.showGcodeAction,
      onHistoryLoaded: () async {
        controller.returnToCalculator();
        BotToast.showText(text: l10n.historyLoadSuccessMessage);
      },
    );

    final renderedShellTab = shellTabs[controller.selectedIndex];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppScreenHeader(
        title: renderedShellTab.title,
        actions: renderedShellTab.actions,
        leading: IconButton(
          icon: const Icon(Icons.help_outline, color: ICON_MUTED),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const HelpSupportPage()),
          ),
        ),
      ),
      body: Column(
        children: [
          const UpdatePromptBanner(),
          Expanded(
            child: PageView(
              controller: controller.pageController,
              onPageChanged: controller.onPageChanged,
              children: shellTabs.map((tab) => tab.page).toList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: SHELL_BACKGROUND,
          border: Border(top: BorderSide(color: SHELL_BORDER)),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          currentIndex: controller.selectedIndex,
          onTap: controller.onNavigationTap,
          items: shellTabs.map((tab) => tab.navigationItem).toList(),
        ),
      ),
    );
  }
}
