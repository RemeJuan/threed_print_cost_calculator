import 'package:flutter/widgets.dart';

/// A single accordion item. `body` is a widget so callers have full
/// control over the contents (text, form fields, lists, etc.).
class AccordionItem {
  final Widget header;
  final Widget body;
  final bool initiallyExpanded;

  /// If true the item is locked/disabled: it will be shown expanded by
  /// default and user taps to toggle it are disabled. Use this for
  /// premium-gated sections that non-premium users shouldn't collapse.
  final bool isLocked;

  /// Optional action widget displayed to the left of the chevron.
  /// Typically an [IconButton] or similar. If provided it will be
  /// shown in the header and can handle its own tap events.
  final Widget? action;

  AccordionItem({
    required this.header,
    required this.body,
    this.initiallyExpanded = false,
    this.isLocked = false,
    this.action,
  });
}
