import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/app/help_support/models/help_support_faq_entry.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

class HelpSupportFaqTile extends StatelessWidget {
  const HelpSupportFaqTile({
    required this.index,
    required this.entry,
    super.key,
  });

  final int index;
  final HelpSupportFaqEntry entry;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: AppSurfaceCard(
        padding: EdgeInsets.zero,
        child: ExpansionTile(
          key: ValueKey<String>('helpSupport.faq.$index'),
          tilePadding: const EdgeInsets.symmetric(horizontal: 16),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          visualDensity: VisualDensity.compact,
          title: Text(entry.question),
          children: [
            Padding(padding: EdgeInsets.zero, child: Text(entry.answer)),
          ],
        ),
      ),
    );
  }
}
