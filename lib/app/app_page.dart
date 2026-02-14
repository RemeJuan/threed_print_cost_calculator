import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/app/header_actions.dart';
import 'package:threed_print_cost_calculator/app/support_dialog.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/history/history_page.dart';
import 'package:threed_print_cost_calculator/settings/settings_page.dart';

class AppPage extends HookConsumerWidget with WidgetsBindingObserver {
  const AppPage({super.key});

  @override
  Widget build(context, ref) {
    final selectedIndex = useState(0);
    final premium = useState<bool>(false);
    final userId = useState<String>('');
    final l10n = S.of(context);

    useEffect(() {
      Purchases.addCustomerInfoUpdateListener((info) async {
        premium.value = info.entitlements.active.isNotEmpty;
        userId.value = info.originalAppUserId;

        final prefs = await SharedPreferences.getInstance();
        final runCount = prefs.getInt('run_count') ?? 0;
        await prefs.setInt('run_count', runCount + 1);
      });

      return null;
    }, []);

    final pageController = usePageController(initialPage: selectedIndex.value);

    final pages = <Widget>[
      const CalculatorPage(),
      if (premium.value) const HistoryPage(),
      const SettingsPage(),
    ];

    final headings = [
      l10n.calculatorAppBarTitle,
      if (premium.value) l10n.historyAppBarTitle,
      l10n.settingsAppBarTitle,
    ];

    useEffect(() {
      if (!context.mounted) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(calculatorProvider.notifier)
          ..init()
          ..submit();
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
              toastBuilder: (_) => SupportDialog(userID: userId.value),
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
            icon: const Icon(Icons.calculate),
            label: l10n.calculatorNavLabel,
          ),
          if (premium.value)
            BottomNavigationBarItem(
              icon: const Icon(Icons.history),
              label: l10n.historyNavLabel,
            ),
          BottomNavigationBarItem(
            icon: const Icon(Icons.settings),
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
