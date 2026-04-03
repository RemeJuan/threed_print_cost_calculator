import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/app/header_actions.dart';
import 'package:threed_print_cost_calculator/app/support_dialog.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/history/history_page.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/settings/settings_page.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

class AppPage extends HookConsumerWidget with WidgetsBindingObserver {
  const AppPage({super.key});

  @override
  Widget build(context, ref) {
    final selectedIndex = useState(0);
    final l10n = S.of(context);
    final prefs = ref.read(sharedPreferencesProvider);
    final premiumState = ref.watch(premiumStateProvider);
    final isPremium = premiumState.isPremium;

    ref.listen<PremiumState>(premiumStateProvider, (previous, next) async {
      if (next.isLoading || next.userId.isEmpty) return;
      if (previous?.isLoading == false && previous?.userId == next.userId) {
        return;
      }

      final runCount = prefs.getInt('run_count') ?? 0;
      await prefs.setInt('run_count', runCount + 1);
    });

    final pageController = usePageController(initialPage: selectedIndex.value);

    final pages = <Widget>[
      const CalculatorPage(),
      if (isPremium) const HistoryPage(),
      const SettingsPage(),
    ];

    final headings = [
      l10n.calculatorAppBarTitle,
      if (isPremium) l10n.historyAppBarTitle,
      l10n.settingsAppBarTitle,
    ];

    useEffect(() {
      if (selectedIndex.value < pages.length) return null;
      selectedIndex.value = pages.length - 1;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (pageController.hasClients) {
          pageController.jumpToPage(selectedIndex.value);
        }
      });
      return null;
    }, [pages.length]);

    useEffect(() {
      if (!context.mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final notifier = ref.read(calculatorProvider.notifier);
        await notifier.init();
        notifier.submit();
      });

      return null;
    }, [selectedIndex.value]);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(headings[selectedIndex.value]),
        actions: const [HeaderActions()],
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
        onPageChanged: (index) => selectedIndex.value = index,
        controller: pageController,
        children: pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex.value,
        onTap: (index) {
          selectedIndex.value = index;
          pageController.animateToPage(
            index,
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
          if (isPremium)
            BottomNavigationBarItem(
              icon: const Icon(
                Icons.history,
                key: ValueKey<String>('nav.history.button'),
              ),
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
