import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/app/app_page_announcement_effect.dart';
import 'package:threed_print_cost_calculator/app/app_page_cancel_feedback_effect.dart';
import 'package:threed_print_cost_calculator/app/app_page_shell_config.dart';
import 'package:threed_print_cost_calculator/app/help_support/help_support_page.dart';
import 'package:threed_print_cost_calculator/app/widgets/update_prompt_banner.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_screen_header.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/providers/pro_promotion_visibility.dart';
import 'package:threed_print_cost_calculator/shared/providers/whats_new_provider.dart';

class AppPage extends HookConsumerWidget {
  const AppPage({super.key});

  @override
  Widget build(context, ref) {
    final selectedTab = useState(AppPageTab.calculator);
    final tapNavigationTargetIndex = useState<int?>(null);
    final l10n = AppLocalizations.of(context)!;
    final prefs = ref.read(sharedPreferencesProvider);
    final premiumState = ref.watch(premiumStateProvider);
    final isPremium = premiumState.isPremium;
    final showHistoryTab = ref.watch(shouldShowHistoryTabProvider);
    final showHistoryTeaser = ref.watch(shouldShowHistoryTeaserProvider);

    useEffect(() {
      registerAppProviderContainer(
        ProviderScope.containerOf(context, listen: false),
      );
      return null;
    }, const []);

    ref.listen(pendingTabNavigationProvider, (prev, AppPageTab? next) {
      if (next != null && next != selectedTab.value) {
        selectedTab.value = next;
        ref.read(pendingTabNavigationProvider.notifier).navigate(null);
      }
    });

    final announcementAsync = ref.watch(currentAnnouncementProvider);

    useAppPageAnnouncementEffect(
      context: context,
      ref: ref,
      announcementAsync: announcementAsync,
      isPremium: isPremium,
    );
    useAppPageCancelFeedbackEffect(context: context, ref: ref, prefs: prefs);

    final pageController = usePageController(initialPage: 0);

    useEffect(() {
      if (showHistoryTab || selectedTab.value != AppPageTab.history) {
        return null;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (selectedTab.value == AppPageTab.history) {
          selectedTab.value = AppPageTab.calculator;
        }
      });

      return null;
    }, [showHistoryTab, selectedTab.value]);

    final shellTabs = buildAppPageShellTabs(
      context: context,
      l10n: l10n,
      isPremium: isPremium,
      showHistoryTab: showHistoryTab,
      showHistoryTeaser: showHistoryTeaser,
      onHistoryLoaded: () async {
        tapNavigationTargetIndex.value = 0;
        selectedTab.value = AppPageTab.calculator;
        pageController.jumpToPage(0);

        BotToast.showText(text: l10n.historyLoadSuccessMessage);
      },
    );
    final tabs = shellTabs.map((tab) => tab.tab).toList();

    useEffect(() {
      if (tabs.contains(selectedTab.value)) {
        return null;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!tabs.contains(selectedTab.value)) {
          selectedTab.value = AppPageTab.calculator;
        }
      });

      return null;
    }, [isPremium, showHistoryTab, selectedTab.value]);

    int tabToIndex(AppPageTab tab) => tabs.indexOf(tab);
    AppPageTab tabFromIndex(int index) => tabs[index];

    final renderedTab = tabs.contains(selectedTab.value)
        ? selectedTab.value
        : AppPageTab.calculator;
    final selectedIndex = tabToIndex(renderedTab);
    final renderedShellTab = shellTabs[selectedIndex];

    useEffect(() {
      if (renderedTab != AppPageTab.materials) {
        return null;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        AppAnalytics.safeLog(AppAnalytics.materialsViewOpened);
      });

      return null;
    }, [renderedTab]);

    useEffect(() {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pageController.hasClients &&
            pageController.page?.round() != selectedIndex) {
          pageController.jumpToPage(selectedIndex);
        }
      });

      return null;
    }, [selectedIndex]);

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
              controller: pageController,
              onPageChanged: (index) {
                final tapTargetIndex = tapNavigationTargetIndex.value;
                if (tapTargetIndex != null) {
                  if (index == tapTargetIndex) {
                    tapNavigationTargetIndex.value = null;
                  }
                  return;
                }

                selectedTab.value = tabFromIndex(index);
              },
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
          currentIndex: selectedIndex,
          onTap: (index) {
            final targetTab = tabFromIndex(index);
            final targetIndex = tabToIndex(targetTab);

            if (targetIndex == selectedIndex) {
              return;
            }

            tapNavigationTargetIndex.value = targetIndex;
            selectedTab.value = targetTab;
            pageController.animateToPage(
              targetIndex,
              duration: const Duration(milliseconds: 500),
              curve: Curves.ease,
            );
          },
          items: shellTabs.map((tab) => tab.navigationItem).toList(),
        ),
      ),
    );
  }
}
