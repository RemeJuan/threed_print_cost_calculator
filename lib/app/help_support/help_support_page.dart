import 'package:bot_toast/bot_toast.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:hugeicons/hugeicons.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/components/settings_version_tap_target.dart';
import 'package:url_launcher/url_launcher.dart';

class HelpSupportPage extends ConsumerStatefulWidget {
  const HelpSupportPage({super.key});

  @override
  ConsumerState<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends ConsumerState<HelpSupportPage> {
  late final Future<PackageInfo> _packageInfoFuture;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final supportId = ref.watch(premiumStateProvider).userId;
    final visibleSupportId = supportId.isEmpty ? '—' : supportId;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.needHelpTitle)),
      body: ListView(
        key: const ValueKey<String>('helpSupport.page'),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          _sectionHeader(context, l10n.helpSupportSupportTitle),
          const SizedBox(height: 12),
          _supportCard(context, l10n, visibleSupportId),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              key: const ValueKey<String>('helpSupport.contact.button'),
              onPressed: () => _contactSupport(l10n, visibleSupportId),
              icon: const Icon(Icons.email_outlined),
              label: Text(l10n.helpSupportContactSupportButton),
            ),
          ),
          const SizedBox(height: 28),
          _sectionHeader(context, l10n.helpSupportFaqTitle),
          const SizedBox(height: 12),
          ..._faqEntries(
            l10n,
          ).asMap().entries.map((entry) => _faqTile(entry.key, entry.value)),
          const SizedBox(height: 28),
          _sectionHeader(context, l10n.helpSupportAboutTitle),
          const SizedBox(height: 12),
          ..._aboutBlocks(l10n),
          const SizedBox(height: 12),
          _aboutFooter(context, l10n),
        ],
      ),
    );
  }

  Widget _sectionHeader(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }

  Widget _supportCard(
    BuildContext context,
    AppLocalizations l10n,
    String supportId,
  ) {
    final theme = Theme.of(context);
    final email = l10n.supportEmail;

    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Text(
              l10n.helpSupportSupportIntro,
              style: theme.textTheme.bodyMedium,
            ),
          ),
          _supportRow(
            title: l10n.helpSupportEmailLabel,
            subtitle: email,
            icon: Icons.mark_email_unread_outlined,
            onTap: () => _sendEmail(recipient: email),
            key: const ValueKey<String>('helpSupport.support.email'),
          ),
          const Divider(height: 1),
          _supportIdRow(l10n, supportId),
          const Divider(height: 1),
          _versionRow(),
        ],
      ),
    );
  }

  Widget _supportRow({
    required Key key,
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return ListTile(
      key: key,
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text(title),
      subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      trailing: Icon(icon, size: 18),
      onTap: onTap,
    );
  }

  Widget _supportIdRow(AppLocalizations l10n, String supportId) {
    final canCopy = supportId != '—';

    return ListTile(
      key: const ValueKey<String>('helpSupport.support.id'),
      dense: true,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 2),
      title: Text.rich(
        TextSpan(
          children: [
            TextSpan(text: '${l10n.helpSupportSupportIdLabel} '),
            TextSpan(text: supportId),
          ],
        ),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      onTap: canCopy ? () => _copySupportId(l10n, supportId) : null,
      trailing: IconButton(
        icon: const Icon(Icons.copy_outlined, size: 18),
        tooltip: l10n.helpSupportCopySupportIdTooltip,
        onPressed: canCopy ? () => _copySupportId(l10n, supportId) : null,
      ),
    );
  }

  Widget _versionRow() {
    return FutureBuilder<PackageInfo>(
      future: _packageInfoFuture,
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '—';

        return Stack(
          children: [
            ListTile(
              key: const ValueKey<String>('helpSupport.support.version'),
              dense: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 2,
              ),
              title: Text(
                AppLocalizations.of(context)!.helpSupportAppVersionRow(version),
              ),
            ),
            Positioned.fill(
              child: Opacity(
                opacity: 0,
                child: SettingsVersionTapTarget(
                  tapTargetKey: const ValueKey<String>(
                    'support.version.tapTarget',
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _faqTile(int index, _FaqEntry entry) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        margin: EdgeInsets.zero,
        clipBehavior: Clip.antiAlias,
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

  List<Widget> _aboutBlocks(AppLocalizations l10n) {
    return [
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(l10n.helpSupportAboutIntro),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            l10n.helpSupportTrustNoAccounts,
            l10n.helpSupportTrustNoCloudSync,
            l10n.helpSupportTrustNoTracking,
            l10n.helpSupportTrustLocalData,
          ].map(_trustChip).toList(growable: false),
        ),
      ),
      Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Text(l10n.helpSupportAboutCalculator),
      ),
      Text(l10n.helpSupportAboutOutcome),
    ];
  }

  Widget _aboutFooter(BuildContext context, AppLocalizations l10n) {
    final theme = Theme.of(context);
    final muted = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _footerIconButton(
              key: const ValueKey<String>('helpSupport.footer.website'),
              tooltip: l10n.helpSupportWebsiteLabel,
              icon: const Icon(Icons.public_outlined, size: 18),
              onPressed: () => _openUrl(_supportWebsite()),
            ),
            const SizedBox(width: 8),
            _footerIconButton(
              key: const ValueKey<String>('helpSupport.footer.x'),
              tooltip: l10n.helpSupportXTwitterLabel,
              icon: HugeIcon(icon: HugeIcons.strokeRoundedNewTwitter, size: 18),
              onPressed: () => _openUrl('https://x.com/PrintCostCalc'),
            ),
            const SizedBox(width: 8),
            _footerIconButton(
              key: const ValueKey<String>('helpSupport.footer.threads'),
              tooltip: l10n.helpSupportThreadsLabel,
              icon: HugeIcon(icon: HugeIcons.strokeRoundedThreads, size: 18),
              onPressed: () =>
                  _openUrl('https://www.threads.com/@printcostcalc'),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _footerLegalLink(
              key: const ValueKey<String>('helpSupport.footer.privacy'),
              label: l10n.helpSupportPrivacyPolicyLabel,
              style: muted,
              onPressed: () =>
                  _openUrl('https://printcostcalc.app/privacy.html'),
            ),
            Text(l10n.separator, style: muted),
            _footerLegalLink(
              key: const ValueKey<String>('helpSupport.footer.terms'),
              label: l10n.helpSupportTermsOfUseLabel,
              style: muted,
              onPressed: () => _openUrl(
                'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _footerIconButton({
    required Key key,
    required String tooltip,
    required Widget icon,
    required VoidCallback onPressed,
  }) {
    return IconButton.filledTonal(
      key: key,
      tooltip: tooltip,
      icon: icon,
      onPressed: onPressed,
    );
  }

  Widget _footerLegalLink({
    required Key key,
    required String label,
    required TextStyle? style,
    required VoidCallback onPressed,
  }) {
    return TextButton(
      key: key,
      onPressed: onPressed,
      style: TextButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(label, style: style),
    );
  }

  Widget _trustChip(String label) {
    return Chip(
      label: Text(label),
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  List<_FaqEntry> _faqEntries(AppLocalizations l10n) {
    return [
      _FaqEntry(
        question: l10n.helpSupportFaqWeightQuestion,
        answer: l10n.helpSupportFaqWeightAnswer,
      ),
      _FaqEntry(
        question: l10n.helpSupportFaqElectricityQuestion,
        answer: l10n.helpSupportFaqElectricityAnswer,
      ),
      _FaqEntry(
        question: l10n.helpSupportFaqRiskQuestion,
        answer: l10n.helpSupportFaqRiskAnswer,
      ),
      _FaqEntry(
        question: l10n.helpSupportFaqLabourQuestion,
        answer: l10n.helpSupportFaqLabourAnswer,
      ),
      _FaqEntry(
        question: l10n.helpSupportFaqMarkupQuestion,
        answer: l10n.helpSupportFaqMarkupAnswer,
      ),
      _FaqEntry(
        question: l10n.helpSupportFaqSetupQuestion,
        answer: l10n.helpSupportFaqSetupAnswer,
      ),
    ];
  }

  String _supportWebsite() => 'https://printcostcalc.app';

  Future<void> _openUrl(String value) async {
    final uri = Uri.tryParse(value);
    if (uri == null) return;
    await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  Future<void> _sendEmail({
    required String recipient,
    String? subject,
    String? body,
  }) async {
    try {
      await FlutterEmailSender.send(
        Email(
          recipients: [recipient],
          subject: subject ?? '',
          body: body ?? '',
          isHTML: false,
        ),
      );
    } catch (_) {
      if (!mounted) return;
      BotToast.showText(text: AppLocalizations.of(context)!.mailClientError);
    }
  }

  Future<void> _copySupportId(AppLocalizations l10n, String supportId) async {
    await Clipboard.setData(ClipboardData(text: supportId));
    if (!mounted) return;
    BotToast.showText(text: l10n.supportIdCopied);
  }

  Future<void> _contactSupport(AppLocalizations l10n, String supportId) async {
    final packageInfo = await _packageInfoFuture;
    await _sendEmail(
      recipient: l10n.supportEmail,
      subject: l10n.helpSupportContactEmailSubject,
      body: l10n.helpSupportContactEmailBody(supportId, packageInfo.version),
    );
  }
}

class _FaqEntry {
  const _FaqEntry({required this.question, required this.answer});

  final String question;
  final String answer;
}
