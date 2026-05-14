import 'package:url_launcher/url_launcher.dart';

const String helpSupportWebsiteUrl = 'https://printcostcalc.app';
const String helpSupportRoadmapUrl = 'https://printcostcalc.app/roadmap';
const String helpSupportXUrl = 'https://x.com/PrintCostCalc';
const String helpSupportInstagramUrl =
    'https://www.instagram.com/3dprintcostcalculator';
const String helpSupportThreadsUrl =
    'https://www.threads.com/@3dprintcostcalculator';
const String helpSupportMastodonUrl = 'https://mastodon.social/@printcostcalc';
const String helpSupportPrivacyUrl = 'https://printcostcalc.app/privacy.html';
const String helpSupportTermsUrl =
    'https://www.apple.com/legal/internet-services/itunes/dev/stdeula/';

Future<void> openUrl(String value) async {
  final uri = Uri.tryParse(value);
  if (uri == null) return;
  await launchUrl(uri, mode: LaunchMode.externalApplication);
}
