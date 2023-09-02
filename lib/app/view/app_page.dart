import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:threed_print_cost_calculator/app/view/header_actions.dart';
import 'package:threed_print_cost_calculator/app/view/support_dialog.dart';
import 'package:threed_print_cost_calculator/calculator/view/calculator_page.dart';
import 'package:threed_print_cost_calculator/history/history_page.dart';
import 'package:threed_print_cost_calculator/l10n/l10n.dart';
import 'package:threed_print_cost_calculator/settings/settings_page.dart';

class AppPage extends HookWidget {
  const AppPage({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedIndex = useState(0);
    final premium = useState<bool>(false);
    final userId = useState<String>('');
    final l10n = context.l10n;

    useEffect(() {
      Purchases.addCustomerInfoUpdateListener((info) {
        premium.value = info.entitlements.active.isNotEmpty;
        userId.value = info.originalAppUserId;
      });
    }, []);

    final pageController = usePageController(initialPage: selectedIndex.value);

    final pages = <Widget>[
      const CalculatorPage(),
      const HistoryPage(),
      const SettingsPage()
    ];

    final headings = [
      l10n.calculatorAppBarTitle,
      l10n.historyAppBarTitle,
      l10n.settingsAppBarTitle
    ];

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(headings[selectedIndex.value]),
        actions: const [HeaderActions()],
        leading: IconButton(
          icon: const Icon(Icons.help_outline),
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
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.calculate),
            label: 'Calculator',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.history),
            label: 'History',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
