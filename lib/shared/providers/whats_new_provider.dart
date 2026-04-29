import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:threed_print_cost_calculator/shared/models/whats_new_announcement.dart';
import 'package:threed_print_cost_calculator/shared/services/whats_new_service.dart';
import 'package:threed_print_cost_calculator/shared/providers/app_providers.dart';

final whatsNewServiceProvider = Provider<WhatsNewService>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  return WhatsNewService(prefs);
});

final currentAnnouncementProvider = FutureProvider<WhatsNewAnnouncement?>((
  ref,
) async {
  final service = ref.watch(whatsNewServiceProvider);
  final announcement = await service.loadAnnouncement();
  if (announcement == null) return null;

  final shouldShow = await service.shouldShowAnnouncement(announcement);
  return shouldShow ? announcement : null;
});

final dismissAnnouncementProvider = Provider<Future<void> Function()>((ref) {
  final service = ref.watch(whatsNewServiceProvider);
  return () async {
    final announcement = await service.loadAnnouncement();
    if (announcement != null) {
      await service.dismissAnnouncement(announcement);
      ref.invalidate(currentAnnouncementProvider);
    }
  };
});
