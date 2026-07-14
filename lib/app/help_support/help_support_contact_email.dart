import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';

({String recipient, String subject, String body}) buildHelpSupportContactEmail(
  AppLocalizations l10n, {
  required String supportId,
  required String? appVersion,
}) {
  final version = appVersion ?? '—';
  final trimmedSupportId = supportId.trim();

  final body = trimmedSupportId.isEmpty
      ? l10n.helpSupportContactEmailBodyNoSupportId(version)
      : l10n.helpSupportContactEmailBody(supportId, version);

  return (
    recipient: l10n.supportEmail,
    subject: l10n.helpSupportContactEmailSubject,
    body: body,
  );
}
