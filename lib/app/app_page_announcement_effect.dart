import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/app/app_page_modal_sheet_guard.dart';
import 'package:threed_print_cost_calculator/shared/components/whats_new_sheet.dart';
import 'package:threed_print_cost_calculator/shared/models/whats_new_announcement.dart';
import 'package:threed_print_cost_calculator/shared/providers/whats_new_provider.dart';

void useAppPageAnnouncementEffect({
  required BuildContext context,
  required WidgetRef ref,
  required AsyncValue<WhatsNewAnnouncement?> announcementAsync,
  required bool isPremium,
}) {
  final whatsNewShown = useRef(false);

  useEffect(() {
    announcementAsync.whenData((announcement) {
      if (announcement == null || whatsNewShown.value) return;

      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted || whatsNewShown.value) return;
        if (!canShowAppPageModalSheet(context)) return;

        whatsNewShown.value = true;
        final dismiss = ref.read(dismissAnnouncementProvider);
        final locale = Localizations.localeOf(context).languageCode;
        showWhatsNewSheet(
          context,
          announcement: announcement,
          onDismiss: dismiss,
          wnId: announcement.id,
          locale: locale,
          isPremium: isPremium,
        );
      });
    });

    return null;
  }, [announcementAsync]);
}
