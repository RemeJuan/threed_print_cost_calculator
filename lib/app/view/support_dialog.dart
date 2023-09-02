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
                  const TextSpan(text: 'For any issues, please mail me at '),
                  TextSpan(
                    text: 'google@remej.dev',
                    style: const TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () async {
                        final uri =
                            'mailto:google@remej.dev?subject=3D%20Print%20Cost%20Calculator%20Support&body=Support%20ID:%20$userID';
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
                        await Clipboard.setData(ClipboardData(text: userID));
                        BotToast.showText(
                          text: 'Support ID Copied',
                        );
                      },
                  ),
                ],
              ),
            ),
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
