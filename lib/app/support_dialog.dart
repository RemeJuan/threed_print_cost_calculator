import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_email_sender/flutter_email_sender.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/purchases/premium_state_notifier.dart';
import 'package:threed_print_cost_calculator/shared/components/settings_version_tap_target.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportDialog extends ConsumerWidget {
  const SupportDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userId = ref.watch(premiumStateProvider.select((v) => v.userId));
    final l10n = AppLocalizations.of(context)!;
    final linkFont = Theme.of(
      context,
    ).textTheme.displayMedium?.copyWith(fontSize: 12);
    return Dialog(
      child: // Replace fixed height SizedBox with a ConstrainedBox + SingleChildScrollView
      ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.needHelpTitle,
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 16),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: l10n.supportEmailPrefix,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    TextSpan(
                      text: l10n.supportEmail,
                      style: const TextStyle(
                        color: LIGHT_BLUE,
                        decoration: TextDecoration.underline,
                      ),
                      recognizer: TapGestureRecognizer()
                        ..onTap = () async {
                          try {
                            await FlutterEmailSender.send(
                              Email(
                                recipients: [l10n.supportEmail],
                                subject: l10n.supportEmailSubject,
                                body: '${l10n.supportIdLabel}$userId',
                                isHTML: false,
                              ),
                            );
                          } catch (e) {
                            BotToast.showText(text: l10n.mailClientError);
                          }
                        },
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              // New explanatory paragraph about material weight/cost
              Text(
                l10n.materialWeightExplanation,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.supportIdLabel,
                        style: Theme.of(context).textTheme.displaySmall,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        l10n.clickToCopy,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  GestureDetector(
                    onTap: () async {
                      await Clipboard.setData(ClipboardData(text: userId));
                      BotToast.showText(text: l10n.supportIdCopied);
                    },
                    child: Text(
                      userId,
                      style: const TextStyle(
                        color: LIGHT_BLUE,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  RawMaterialButton(
                    onPressed: () async {
                      await launchUrl(Uri.parse('https://printcostcalc.app'));
                    },
                    child: Text(l10n.websiteLink, style: linkFont),
                  ),
                  Text(l10n.separator, style: linkFont),
                  RawMaterialButton(
                    onPressed: () async {
                      await launchUrl(
                        Uri.parse('https://printcostcalc.app/privacy.html'),
                      );
                    },
                    child: Text(l10n.privacyPolicyLink, style: linkFont),
                  ),
                  Text(l10n.separator, style: linkFont),
                  RawMaterialButton(
                    onPressed: () async {
                      await launchUrl(
                        Uri.parse(
                          'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                        ),
                      );
                    },
                    child: Text(l10n.termsOfUseLink, style: linkFont),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Center(
                child: const SettingsVersionTapTarget(
                  tapTargetKey: ValueKey<String>('support.version.tapTarget'),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                alignment: Alignment.center,
                child: RawMaterialButton(
                  onPressed: BotToast.cleanAll,
                  child: Text(
                    l10n.closeButton,
                    style: Theme.of(
                      context,
                    ).textTheme.displayMedium?.copyWith(fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
