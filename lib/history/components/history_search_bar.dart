import 'package:material_ui/material_ui.dart';
import 'package:threed_print_cost_calculator/history/components/history_toolbar.dart';

class HistorySearchBar extends StatelessWidget {
  const HistorySearchBar({
    required this.controller,
    this.onExportPressed,
    super.key,
  });

  final TextEditingController controller;
  final VoidCallback? onExportPressed;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: HistoryToolbar(
        controller: controller,
        onExportPressed: onExportPressed,
      ),
    );
  }
}
