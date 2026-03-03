/// Utility functions for formatting localized label strings.
///
/// We occasionally receive localized strings that include a literal `#` placeholder
/// (for example from `Intl.plural` patterns). This helper replaces `#` with the
/// provided count when present.
library;

String formatCountLabel(String rawLabel, int count) {
  if (rawLabel.contains('#')) {
    return rawLabel.replaceAll('#', count.toString());
  }
  return rawLabel;
}
