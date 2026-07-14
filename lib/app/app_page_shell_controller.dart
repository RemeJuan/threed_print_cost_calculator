import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/app/app_page_shell_config.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

class AppPageShellController {
  const AppPageShellController({
    required this.renderedTab,
    required this.selectedIndex,
    required this.pageController,
    required this.onPageChanged,
    required this.onNavigationTap,
    required this.returnToCalculator,
  });

  final AppPageTab renderedTab;
  final int selectedIndex;
  final PageController pageController;
  final ValueChanged<int> onPageChanged;
  final ValueChanged<int> onNavigationTap;
  final VoidCallback returnToCalculator;
}

AppPageShellController useAppPageShellController({
  required WidgetRef ref,
  required List<AppPageTab> tabs,
  required VoidCallback onMaterialsOpened,
}) {
  // ignore: deprecated_member_use
  final isMounted = useIsMounted();
  final selectedTab = useState(AppPageTab.calculator);
  final tapNavigationTargetIndex = useState<int?>(null);
  final pageController = usePageController(initialPage: 0);

  ref.listen(pendingTabNavigationProvider, (prev, next) {
    if (next == null) return;
    if (next != selectedTab.value) {
      selectedTab.value = next;
    }
    ref.read(pendingTabNavigationProvider.notifier).navigate(null);
  });

  useEffect(() {
    if (tabs.contains(selectedTab.value)) return null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isMounted()) return;
      if (tabs.contains(selectedTab.value)) return;
      selectedTab.value = AppPageTab.calculator;
    });
    return null;
  }, [...tabs, selectedTab.value]);

  final renderedTab = tabs.contains(selectedTab.value)
      ? selectedTab.value
      : AppPageTab.calculator;
  final selectedIndex = tabs.indexOf(renderedTab);

  useEffect(() {
    if (renderedTab != AppPageTab.materials) return null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isMounted()) return;
      if (!pageController.hasClients) return;
      onMaterialsOpened();
    });
    return null;
  }, [renderedTab]);

  useEffect(() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!isMounted()) return;
      if (!pageController.hasClients) return;
      if (tapNavigationTargetIndex.value != null) return;
      if (pageController.page?.round() != selectedIndex) {
        pageController.jumpToPage(selectedIndex);
      }
    });
    return null;
  }, [selectedIndex, tapNavigationTargetIndex.value]);

  void onPageChanged(int index) {
    final tapTargetIndex = tapNavigationTargetIndex.value;
    if (tapTargetIndex != null) {
      if (index == tapTargetIndex) tapNavigationTargetIndex.value = null;
      return;
    }
    selectedTab.value = tabs[index];
  }

  void onNavigationTap(int index) {
    if (index == selectedIndex) return;
    tapNavigationTargetIndex.value = index;
    selectedTab.value = tabs[index];
    pageController.animateToPage(
      index,
      duration: const Duration(milliseconds: 500),
      curve: Curves.ease,
    );
  }

  void returnToCalculator() {
    tapNavigationTargetIndex.value = 0;
    selectedTab.value = AppPageTab.calculator;
    if (pageController.hasClients) pageController.jumpToPage(0);
  }

  return AppPageShellController(
    renderedTab: renderedTab,
    selectedIndex: selectedIndex,
    pageController: pageController,
    onPageChanged: onPageChanged,
    onNavigationTap: onNavigationTap,
    returnToCalculator: returnToCalculator,
  );
}
