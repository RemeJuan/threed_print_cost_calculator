import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/app/header_actions.dart';
import 'package:threed_print_cost_calculator/app/help_support/help_support_page.dart';
import 'package:threed_print_cost_calculator/app/promo_history_tab_icon.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/history/history_page.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_page.dart';
import 'package:threed_print_cost_calculator/materials/widgets/materials_page.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/settings_page.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';
import 'package:threed_print_cost_calculator/shared/providers/pro_promotion_visibility.dart';
import 'package:threed_print_cost_calculator/shared/providers/whats_new_provider.dart';
import 'package:threed_print_cost_calculator/shared/components/whats_new_sheet.dart';

enum _AppTab { calculator, materials, history, settings }

class AppPage extends HookConsumerWidget with WidgetsBindingObserver {
  const AppPage({super.key});

  @override
  Widget build(context, ref) {
    final selectedTab = useState(_AppTab.calculator);
    final tapNavigationTargetIndex = useState<int?>(null);
    final whatsNewShown = useRef(false);
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

    final announcementAsync = ref.watch(currentAnnouncementProvider);

    useEffect(() {
      announcementAsync.whenData((announcement) {
        if (announcement == null || whatsNewShown.value) return;
        whatsNewShown.value = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          final dismiss = ref.read(dismissAnnouncementProvider);
          final locale = Localizations.localeOf(context).languageCode;
          showWhatsNewSheet(
            context,
            announcement: announcement,
            onDismiss: dismiss,
            wnId: announcement.id,
            locale: locale,
            isPremium: isPremium,
          );
        });
      });
      return null;
    }, [announcementAsync]);

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

    final tabs = <_AppTab>[
      _AppTab.calculator,
      if (isPremium) _AppTab.materials,
      if (showHistoryTab) _AppTab.history,
      _AppTab.settings,
    ];

    useEffect(() {
      if (tabs.contains(selectedTab.value)) {
        return null;
      }

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!tabs.contains(selectedTab.value)) {
          selectedTab.value = _AppTab.calculator;
        }
      });

      return null;
    }, [isPremium, showHistoryTab, selectedTab.value]);

    int tabToIndex(_AppTab tab) => tabs.indexOf(tab);
    _AppTab tabFromIndex(int index) => tabs[index];

    final pages = [
      const CalculatorPage(),
      if (isPremium) const MaterialsPage(),
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

    String titleForTab(_AppTab tab) => switch (tab) {
      _AppTab.calculator => l10n.calculatorAppBarTitle,
      _AppTab.materials => l10n.materialsAppBarTitle,
      _AppTab.history => l10n.historyAppBarTitle,
      _AppTab.settings => l10n.settingsAppBarTitle,
    };

    final renderedTab = tabs.contains(selectedTab.value)
        ? selectedTab.value
        : _AppTab.calculator;
    final selectedIndex = tabToIndex(renderedTab);

    useEffect(() {
      if (renderedTab != _AppTab.materials) {
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
      appBar: AppBar(
        centerTitle: true,
        title: Text(titleForTab(renderedTab)),
        actions: switch (renderedTab) {
          _AppTab.calculator => const [HeaderActions()],
          _AppTab.materials => [
            IconButton(
              tooltip: l10n.csvImportTitle,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CsvImportPage(),
                  ),
                );
              },
              icon: const Icon(
                Icons.file_upload_outlined,
                color: Colors.white54,
              ),
            ),
          ],
          _AppTab.history => const [],
          _AppTab.settings => const [],
        },
        leading: IconButton(
          icon: const Icon(Icons.help_outline, color: Colors.white54),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute<void>(builder: (_) => const HelpSupportPage()),
          ),
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
        items: tabs.map((tab) {
          final (Widget icon, String label) = switch (tab) {
            _AppTab.calculator => (
              const Icon(
                Icons.calculate,
                key: ValueKey<String>('nav.calculator.button'),
              ),
              l10n.calculatorNavLabel,
            ),
            _AppTab.materials => (
              const Icon(
                Icons.inventory_2_outlined,
                key: ValueKey<String>('nav.materials.button'),
              ),
              l10n.materialsNavLabel,
            ),
            _AppTab.history => (
              isPremium
                  ? const Icon(
                      Icons.history,
                      key: ValueKey<String>('nav.history.button'),
                    )
                  : const PromoHistoryTabIcon(),
              l10n.historyNavLabel,
            ),
            _AppTab.settings => (
              const Icon(
                Icons.settings,
                key: ValueKey<String>('nav.settings.button'),
              ),
              l10n.settingsNavLabel,
            ),
          };
          return BottomNavigationBarItem(icon: icon, label: label);
        }).toList(),
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
