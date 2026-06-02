import 'package:flutter/foundation.dart';

class HelpSupportFaqEntry {
  const HelpSupportFaqEntry({
    required this.id,
    required this.question,
    required this.answer,
    this.linkLabel,
    this.onLinkTap,
  });

  final String id;
  final String question;
  final String answer;
  final String? linkLabel;
  final VoidCallback? onLinkTap;
}
