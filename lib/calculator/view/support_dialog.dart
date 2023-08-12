import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SupportDialog extends StatelessWidget {
  const SupportDialog({required this.userID, super.key});

  final String userID;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Need Help?',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            RichText(
              text: TextSpan(
                children: [
                  const TextSpan(text: 'Please log all support issues '),
                  TextSpan(
                    text: 'HERE',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final uri =
                            'https://github.com/RemeJuan/threed_print_cost_calculator/issues/new';
                        try {
                          await launchUrl(Uri.parse(uri));
                        } catch (e) {
                          ClipboardData(text: uri);
                          BotToast.showText(
                            text:
                                'Could not open link, it has been copied to your clipboard',
                          );
                        }
                      },
                  )
                ],
              ),
            ),
            const SizedBox(height: 16),
            RichText(
                text: TextSpan(
              children: [
                const TextSpan(text: 'Please include your Support ID: '),
                const TextSpan(
                  text: '(click to copy) \n',
                  style: TextStyle(fontSize: 12),
                ),
                TextSpan(
                  text: userID,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () async {
                      ClipboardData(text: userID);
                      BotToast.showText(
                        text: 'Support ID Copied',
                      );
                    },
                )
              ],
            )),
            Container(
              alignment: Alignment.center,
              child: const TextButton(
                onPressed: BotToast.cleanAll,
                child: Text('Close'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
