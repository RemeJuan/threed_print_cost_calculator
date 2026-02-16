import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportDialog extends StatelessWidget {
  const SupportDialog({required this.userID, super.key});

  final String userID;

  @override
  Widget build(BuildContext context) {
    final l10n = S.of(context);
    final linkFont = Theme.of(
      context,
    ).textTheme.displayMedium?.copyWith(fontSize: 12);
    return Dialog(
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.55,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
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
                          final uri =
                              'mailto:${l10n.supportEmail}?subject=3D%20Print%20Cost'
                              '%20Calculator%20Support&body=Support%20ID:'
                              '%20$userID';
                          try {
                            await launchUrl(Uri.parse(uri));
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
                      await Clipboard.setData(ClipboardData(text: userID));
                      BotToast.showText(text: l10n.supportIdCopied);
                    },
                    child: Text(
                      userID,
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
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    alignment: Alignment.center,
                    child: RawMaterialButton(
                      onPressed: () async {
                        await launchUrl(
                          Uri.parse(
                            'https://github.com/RemeJuan/threed_print_cost_calculator/blob/main/privacy_policy.md',
                          ),
                        );
                      },
                      child: Text(l10n.privacyPolicyLink, style: linkFont),
                    ),
                  ),
                  Text(l10n.separator, style: linkFont),
                  Container(
                    alignment: Alignment.center,
                    child: RawMaterialButton(
                      onPressed: () async {
                        await launchUrl(
                          Uri.parse(
                            'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/',
                          ),
                        );
                      },
                      child: Text(l10n.termsOfUseLink, style: linkFont),
                    ),
                  ),
                ],
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
