import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/app/header_actions.dart';
import 'package:threed_print_cost_calculator/app/promo_history_tab_icon.dart';
import 'package:threed_print_cost_calculator/app/support_dialog.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/history/history_page.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/settings_page.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/providers/pro_promotion_visibility.dart';

enum _AppTab { calculator, history, settings }

class AppPage extends HookConsumerWidget with WidgetsBindingObserver {
  const AppPage({super.key});

  @override
  Widget build(context, ref) {
    final selectedTab = useState(_AppTab.calculator);
    final tapNavigationTargetIndex = useState<int?>(null);
    final l10n = AppLocalizations.of(context)!;
    final prefs = ref.read(sharedPreferencesProvider);
    final premiumState = ref.watch(premiumStateProvider);
    final isPremium = premiumState.isPremium;
    final showHistoryTab = ref.watch(shouldShowHistoryTabProvider);
    final showHistoryTeaser = ref.watch(shouldShowHistoryTeaserProvider);

    ref.listen<PremiumState>(premiumStateProvider, (previous, next) async {
      if (next.isLoading || next.userId.isEmpty) return;
      if (previous?.isLoading == false && previous?.userId == next.userId) {
        return;
      }

      final runCount = prefs.getInt('run_count') ?? 0;
      await prefs.setInt('run_count', runCount + 1);
    });

    final pageController = usePageController(initialPage: 0);

    useEffect(() {
      if (showHistoryTab || selectedTab.value != _AppTab.history) {
        return null;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (selectedTab.value == _AppTab.history) {
          selectedTab.value = _AppTab.calculator;
        }
      });

      return null;
    }, [showHistoryTab, selectedTab.value]);

    int tabToIndex(_AppTab tab) {
      return switch (tab) {
        _AppTab.calculator => 0,
        _AppTab.history => 1,
        _AppTab.settings => showHistoryTab ? 2 : 1,
      };
    }

    _AppTab tabFromIndex(int index) {
      if (index == 0) return _AppTab.calculator;
      if (showHistoryTab && index == 1) return _AppTab.history;
      return _AppTab.settings;
    }

    final pages = <Widget>[
      const CalculatorPage(),
      if (showHistoryTab)
        HistoryPage(
          mode: showHistoryTeaser
              ? HistoryPageMode.teaser
              : HistoryPageMode.full,
          onHistoryLoaded: () async {
            tapNavigationTargetIndex.value = 0;
            selectedTab.value = _AppTab.calculator;
            pageController.jumpToPage(0);

            ScaffoldMessenger.of(context)
              ..hideCurrentSnackBar()
              ..showSnackBar(
                SnackBar(content: Text(l10n.historyLoadSuccessMessage)),
              );
          },
        ),
      const SettingsPage(),
    ];

    final headings = [
      l10n.calculatorAppBarTitle,
      if (showHistoryTab) l10n.historyAppBarTitle,
      l10n.settingsAppBarTitle,
    ];

    final selectedIndex = tabToIndex(selectedTab.value);

    final isHistoryTeaserSelected =
        showHistoryTeaser && selectedTab.value == _AppTab.history;

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
      appBar: AppBar(
        centerTitle: true,
        title: Text(headings[selectedIndex]),
        actions: isHistoryTeaserSelected ? const [] : const [HeaderActions()],
        leading: IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white54),
          onPressed: () {
            BotToast.showCustomNotification(
              duration: const Duration(minutes: 5),
              toastBuilder: (_) => SupportDialog(userID: premiumState.userId),
            );
          },
        ),
      ),
      body: PageView(
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
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
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
        items: <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.calculate,
              key: ValueKey<String>('nav.calculator.button'),
            ),
            label: l10n.calculatorNavLabel,
          ),
          if (showHistoryTab)
            BottomNavigationBarItem(
              icon: isPremium
                  ? const Icon(
                      Icons.history,
                      key: ValueKey<String>('nav.history.button'),
                    )
                  : const PromoHistoryTabIcon(),
              label: l10n.historyNavLabel,
            ),
          BottomNavigationBarItem(
            icon: const Icon(
              Icons.settings,
              key: ValueKey<String>('nav.settings.button'),
            ),
            label: l10n.settingsNavLabel,
          ),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);

    switch (state) {
      case AppLifecycleState.resumed:
        break;
      case AppLifecycleState.detached:
      case AppLifecycleState.inactive:
      case AppLifecycleState.hidden:
      case AppLifecycleState.paused:
        break;
    }
  }
}
