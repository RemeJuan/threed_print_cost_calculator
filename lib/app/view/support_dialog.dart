import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:threed_print_cost_calculator/app/view/app.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportDialog extends StatelessWidget {
  const SupportDialog({required this.userID, super.key});

  final String userID;

  @override
  Widget build(BuildContext context) {
    final linkFont = Theme.of(context).textTheme.displayMedium?.copyWith(
          fontSize: 12,
        );
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Need Help?',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'For any issues, please mail me at ',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  TextSpan(
                    text: 'google@remej.dev',
                    style: const TextStyle(
                      color: LIGHT_BLUE,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final uri =
                            'mailto:google@remej.dev?subject=3D%20Print%20Cost'
                            '%20Calculator%20Support&body=Support%20ID:'
                            '%20$userID';
                        try {
                          await launchUrl(Uri.parse(uri));
                        } catch (e) {
                          BotToast.showText(text: 'Could not open mail client');
                        }
                      },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Please include your Support ID: ',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const TextSpan(
                    text: '(click to copy) \n',
                    style: TextStyle(fontSize: 12),
                  ),
                  TextSpan(
                    text: userID,
                    style: const TextStyle(
                      color: LIGHT_BLUE,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        await Clipboard.setData(ClipboardData(text: userID));
                        BotToast.showText(
                          text: 'Support ID Copied',
                        );
                      },
                  ),
                ],
              ),
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
                        await launchUrl(Uri.parse(
                            'https://github.com/RemeJuan/threed_print_cost_calculator/blob/main/privacy_policy.md'));
                      },
                      child: Text(
                        'Privacy Policy',
                        style: linkFont,
                      ),
                    ),
                  ),
                  Text(
                    ' | ',
                    style: linkFont,
                  ),
                  Container(
                    alignment: Alignment.center,
                    child: RawMaterialButton(
                      onPressed: () async {
                        await launchUrl(Uri.parse(
                            'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/'));
                      },
                      child: Text(
                        'Terms of Use',
                        style: linkFont,
                      ),
                    ),
                  ),
                ]),
            const SizedBox(height: 16),
            Container(
              alignment: Alignment.center,
              child: RawMaterialButton(
                onPressed: BotToast.cleanAll,
                child: Text(
                  'Close',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 16,
                      ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
