import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:threed_print_cost_calculator/app/help_support/help_support_links.dart';
import 'package:threed_print_cost_calculator/core/analytics/app_analytics.dart';
import 'package:threed_print_cost_calculator/core/logging/app_logger.dart';
import 'package:threed_print_cost_calculator/app/help_support/models/help_support_faq_entry.dart';
import 'package:threed_print_cost_calculator/app/help_support/widgets/help_support_about_section.dart';
import 'package:threed_print_cost_calculator/app/help_support/widgets/help_support_faq_tile.dart';
import 'package:threed_print_cost_calculator/app/help_support/widgets/help_support_footer.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/app/help_support/widgets/help_support_section_header.dart';
import 'package:threed_print_cost_calculator/app/help_support/widgets/help_support_support_card.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/purchases/paywall_presenter.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_screen_header.dart';

class HelpSupportPage extends ConsumerStatefulWidget {
  const HelpSupportPage({super.key, this.initialFaqEntryId});

  static const String premiumFaqEntryId = 'premium';

  final String? initialFaqEntryId;

  @override
  ConsumerState<HelpSupportPage> createState() => _HelpSupportPageState();
}

class _HelpSupportPageState extends ConsumerState<HelpSupportPage> {
  late final Future<PackageInfo> _packageInfoFuture;
  final ScrollController _scrollController = ScrollController();
  final Map<String, GlobalKey> _faqKeys = <String, GlobalKey>{};
  bool _initialFaqRevealed = false;

  @override
  void initState() {
    super.initState();
    _packageInfoFuture = PackageInfo.fromPlatform();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final supportId = ref.watch(premiumStateProvider).userId;
    final visibleSupportId = supportId.isEmpty ? '—' : supportId;
    final faqEntries = _faqEntries(l10n);

    _scheduleInitialFaqReveal();

    return Scaffold(
      appBar: AppScreenHeader(title: l10n.needHelpTitle),
      body: ListView(
        key: const ValueKey<String>('helpSupport.page'),
        controller: _scrollController,
        padding: const EdgeInsets.fromLTRB(
          kAppSpace16,
          kAppSpace16,
          kAppSpace16,
          24,
        ),
        children: [
          HelpSupportSectionHeader(title: l10n.helpSupportSupportTitle),
          const SizedBox(height: kAppSpace12),
          HelpSupportSupportCard(
            supportId: visibleSupportId,
            packageInfoFuture: _packageInfoFuture,
            onEmailTap: () => _sendEmail(recipient: l10n.supportEmail),
            onCopySupportId: () => _copySupportId(l10n, visibleSupportId),
            onRoadmapTap: () => openUrl(
              helpSupportRoadmapUrl,
              logger: ref.read(appLoggerProvider),
            ),
          ),
          const SizedBox(height: kAppSpace12),
          SizedBox(
            width: double.infinity,
            child: AppPrimaryButton(
              key: const ValueKey<String>('helpSupport.contact.button'),
              onPressed: () => _contactSupport(l10n, supportId),
              icon: const Icon(Icons.email_outlined),
              label: l10n.helpSupportContactSupportButton,
            ),
          ),
          const SizedBox(height: 28),
          HelpSupportSectionHeader(title: l10n.helpSupportFaqTitle),
          const SizedBox(height: kAppSpace12),
          ...faqEntries.map(
            (entry) => HelpSupportFaqTile(
              entry: entry,
              initiallyExpanded: entry.id == widget.initialFaqEntryId,
              cardKey: _faqKeyFor(entry.id),
            ),
          ),
          const SizedBox(height: 28),
          HelpSupportSectionHeader(title: l10n.helpSupportAboutTitle),
          const SizedBox(height: kAppSpace12),
          const HelpSupportAboutSection(),
          const SizedBox(height: 12),
          HelpSupportFooter(),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  List<HelpSupportFaqEntry> _faqEntries(AppLocalizations l10n) {
    final isPremium = ref.watch(isPremiumProvider);

    return [
      HelpSupportFaqEntry(
        id: 'weight',
        question: l10n.helpSupportFaqWeightQuestion,
        answer: l10n.helpSupportFaqWeightAnswer,
      ),
      HelpSupportFaqEntry(
        id: 'electricity',
        question: l10n.helpSupportFaqElectricityQuestion,
        answer: l10n.helpSupportFaqElectricityAnswer,
      ),
      HelpSupportFaqEntry(
        id: 'wattage',
        question: l10n.helpSupportFaqWattageQuestion,
        answer: l10n.helpSupportFaqWattageAnswer,
      ),
      HelpSupportFaqEntry(
        id: HelpSupportPage.premiumFaqEntryId,
        question: l10n.helpSupportFaqPremiumQuestion,
        answer: l10n.helpSupportFaqPremiumAnswer,
        actionLabel: isPremium ? null : l10n.helpSupportFaqPremiumUpgradeCta,
        onActionTap: isPremium
            ? null
            : () {
                AppAnalytics.safeLog(
                  () => AppAnalytics.premiumFeatureTapped(
                    'faq_premium_card',
                    isPro: isPremium,
                    source: 'faq',
                  ),
                );
                ref
                    .read(paywallPresenterProvider)
                    .present(
                      'pro',
                      triggerFeature: 'faq_premium_card',
                      purchaseSource: 'faq',
                      source: 'faq',
                    );
              },
        linkLabel: l10n.helpSupportFaqPremiumComparisonCta,
        onLinkTap: () =>
            openUrl(helpSupportPlansUrl, logger: ref.read(appLoggerProvider)),
      ),
      HelpSupportFaqEntry(
        id: 'risk',
        question: l10n.helpSupportFaqRiskQuestion,
        answer: l10n.helpSupportFaqRiskAnswer,
      ),
      HelpSupportFaqEntry(
        id: 'labour',
        question: l10n.helpSupportFaqLabourQuestion,
        answer: l10n.helpSupportFaqLabourAnswer,
      ),
      HelpSupportFaqEntry(
        id: 'markup',
        question: l10n.helpSupportFaqMarkupQuestion,
        answer: l10n.helpSupportFaqMarkupAnswer,
      ),
      HelpSupportFaqEntry(
        id: 'setup',
        question: l10n.helpSupportFaqSetupQuestion,
        answer: l10n.helpSupportFaqSetupAnswer,
      ),
    ];
  }

  GlobalKey _faqKeyFor(String id) {
    return _faqKeys.putIfAbsent(id, () => GlobalKey());
  }

  void _scheduleInitialFaqReveal() {
    final targetId = widget.initialFaqEntryId;
    if (_initialFaqRevealed || targetId == null) {
      return;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _initialFaqRevealed) {
        return;
      }

      final targetContext = _faqKeys[targetId]?.currentContext;
      if (targetContext == null) {
        return;
      }

      _initialFaqRevealed = true;
      Scrollable.ensureVisible(
        targetContext,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeInOut,
        alignment: 0.1,
      );
    });
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
    PackageInfo? packageInfo;
    try {
      packageInfo = await _packageInfoFuture;
    } catch (_) {
      // Fallback to safe defaults if PackageInfo fetch fails
    }

    final String emailBody;

    if (supportId.isEmpty || supportId.trim().isEmpty) {
      emailBody = l10n.helpSupportContactEmailBodyNoSupportId(
        packageInfo?.version ?? '—',
      );
    } else {
      emailBody = l10n.helpSupportContactEmailBody(
        supportId,
        packageInfo?.version ?? '—',
      );
    }

    await _sendEmail(
      recipient: l10n.supportEmail,
      subject: l10n.helpSupportContactEmailSubject,
      body: emailBody,
    );
  }
}
