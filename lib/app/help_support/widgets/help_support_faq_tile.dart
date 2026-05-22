import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/app/help_support/models/help_support_faq_entry.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_expansion_card.dart';

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
      padding: const EdgeInsets.only(bottom: kAppSpace12),
      child: AppExpansionCard(
        key: ValueKey<String>('helpSupport.faq.$index'),
        title: Text(entry.question),
        children: [Text(entry.answer)],
      ),
    );
  }
}
