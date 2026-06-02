import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/app/help_support/models/help_support_faq_entry.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_expansion_card.dart';

class HelpSupportFaqTile extends StatelessWidget {
  const HelpSupportFaqTile({
    required this.entry,
    this.initiallyExpanded = false,
    this.cardKey,
    super.key,
  });

  final HelpSupportFaqEntry entry;
  final bool initiallyExpanded;
  final Key? cardKey;

  @override
  Widget build(BuildContext context) {
    return Padding(
      key: ValueKey<String>('helpSupport.faq.${entry.id}'),
      padding: const EdgeInsets.only(bottom: kAppSpace12),
      child: AppExpansionCard(
        key: cardKey,
        initiallyExpanded: initiallyExpanded,
        title: Text(entry.question),
        children: [
          Text(entry.answer),
          if (entry.linkLabel != null && entry.onLinkTap != null) ...[
            const SizedBox(height: kAppSpace8),
            Align(
              alignment: Alignment.centerLeft,
              child: AppInlineButton(
                key: ValueKey<String>('helpSupport.faq.${entry.id}.link'),
                onPressed: entry.onLinkTap,
                label: entry.linkLabel!,
                padding: EdgeInsets.zero,
                minHeight: 0,
                maxLines: 2,
                textAlign: TextAlign.left,
              ),
            ),
          ],
          if (entry.actionLabel != null && entry.onActionTap != null) ...[
            const SizedBox(height: kAppSpace12),
            SizedBox(
              width: double.infinity,
              child: AppSecondaryButton(
                key: ValueKey<String>('helpSupport.faq.${entry.id}.action'),
                onPressed: entry.onActionTap,
                label: entry.actionLabel!,
                minHeight: 42,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
