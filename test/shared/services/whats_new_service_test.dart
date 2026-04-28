import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/shared/models/whats_new_announcement.dart';
import 'package:threed_print_cost_calculator/shared/services/whats_new_service.dart';

void main() {
  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPreferences.getInstance();
  });

  group('WhatsNewAnnouncement', () {
    test('parses valid JSON', () {
      final json = {
        'wn_id': 'test_123',
        'en': {
          'title': 'Test Title',
          'body': 'Test Body',
          'cta': 'OK',
          'unlock_pro_cta': 'Unlock Pro',
        },
        'de': {
          'title': 'Test Titel',
          'body': 'Test Inhalt',
          'cta': 'Ja',
          'unlock_pro_cta': 'Pro freischalten',
        },
      };
      final announcement = WhatsNewAnnouncement.fromJson(json);

      expect(announcement, isNotNull);
      expect(announcement?.id, 'test_123');
      expect(announcement?.getLocalizedTitle('en'), 'Test Title');
      expect(announcement?.getLocalizedTitle('de'), 'Test Titel');
      expect(announcement?.getLocalizedBody('en'), 'Test Body');
      expect(announcement?.getLocalizedBody('de'), 'Test Inhalt');
      expect(announcement?.getLocalizedCta('en'), 'OK');
      expect(announcement?.getLocalizedUnlockProCta('de'), 'Pro freischalten');
    });

    test('returns null for missing id', () {
      final json = {
        'title': {'en': 'Test Title'},
        'body': {'en': 'Test Body'},
        'cta': {'en': 'OK'},
      };
      final announcement = WhatsNewAnnouncement.fromJson(json);
      expect(announcement, isNull);
    });

    test('returns null for missing title', () {
      final json = {
        'wn_id': 'test_123',
        'en': {'body': 'Test Body', 'cta': 'OK', 'unlock_pro_cta': 'Unlock Pro'},
      };
      final announcement = WhatsNewAnnouncement.fromJson(json);
      expect(announcement, isNull);
    });

    test('returns null for missing body', () {
      final json = {
        'wn_id': 'test_123',
        'en': {'title': 'Test Title', 'cta': 'OK', 'unlock_pro_cta': 'Unlock Pro'},
      };
      final announcement = WhatsNewAnnouncement.fromJson(json);
      expect(announcement, isNull);
    });

    test('falls back to English for unsupported locale', () {
      final json = {
        'wn_id': 'test_123',
        'en': {
          'title': 'Test Title',
          'body': 'Test Body',
          'cta': 'OK',
          'unlock_pro_cta': 'Unlock Pro',
        },
        'de': {
          'title': 'Test Titel',
          'body': 'Test Inhalt',
          'cta': 'Ja',
          'unlock_pro_cta': 'Pro freischalten',
        },
      };
      final announcement = WhatsNewAnnouncement.fromJson(json)!;

      expect(announcement.getLocalizedTitle('fr'), 'Test Title');
      expect(announcement.getLocalizedBody('es'), 'Test Body');
      expect(announcement.getLocalizedCta('it'), 'OK');
    });

    test('falls back to English for body but returns empty for missing title', () {
      final json = {
        'wn_id': 'test_123',
        'en': {
          'title': 'Test Title',
          'body': 'Test Body',
          'cta': 'OK',
          'unlock_pro_cta': 'Unlock Pro',
        },
        'de': {
          'title': 'Test Titel',
          'body': 'Test Inhalt',
          'cta': 'Ja',
          'unlock_pro_cta': 'Pro freischalten',
        },
      };
      final announcement = WhatsNewAnnouncement.fromJson(json)!;
      expect(announcement.getLocalizedTitle('fr'), 'Test Title');
      expect(announcement.getLocalizedBody('fr'), 'Test Body');
      expect(announcement.getLocalizedTitle('de'), 'Test Titel');
      expect(announcement.getLocalizedUnlockProCta('fr'), 'Unlock Pro');
    });
  });

  group('WhatsNewService', () {
    test('shows announcement when no dismissed id stored', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = WhatsNewService(prefs);

      final announcement = WhatsNewAnnouncement(
        id: 'test_id',
        locales: {
          'en': const WhatsNewAnnouncementLocale(
            title: 'Test',
            body: 'Body',
            cta: 'OK',
            unlockProCta: 'Unlock Pro',
          ),
        },
      );
      final shouldShow = await service.shouldShowAnnouncement(announcement);

      expect(shouldShow, true);
    });

    test('does not show after dismissal', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = WhatsNewService(prefs);

      final announcement = WhatsNewAnnouncement(
        id: 'test_id',
        locales: {
          'en': const WhatsNewAnnouncementLocale(
            title: 'Test',
            body: 'Body',
            cta: 'OK',
            unlockProCta: 'Unlock Pro',
          ),
        },
      );
      await service.dismissAnnouncement(announcement);
      final shouldShow = await service.shouldShowAnnouncement(announcement);

      expect(shouldShow, false);
    });

    test('shows again when JSON id changes', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = WhatsNewService(prefs);

      final oldAnnouncement = WhatsNewAnnouncement(
        id: 'old_id',
        locales: {
          'en': const WhatsNewAnnouncementLocale(
            title: 'Old',
            body: 'Old Body',
            cta: 'OK',
            unlockProCta: 'Unlock Pro',
          ),
        },
      );
      await service.dismissAnnouncement(oldAnnouncement);

      final newAnnouncement = WhatsNewAnnouncement(
        id: 'different_id',
        locales: {
          'en': const WhatsNewAnnouncementLocale(
            title: 'New Feature',
            body: 'Description',
            cta: 'OK',
            unlockProCta: 'Unlock Pro',
          ),
        },
      );
      final shouldShow = await service.shouldShowAnnouncement(newAnnouncement);

      expect(shouldShow, true);
    });

    test('dismiss persists id in SharedPreferences', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = WhatsNewService(prefs);

      final announcement = WhatsNewAnnouncement(
        id: 'test_id',
        locales: {
          'en': const WhatsNewAnnouncementLocale(
            title: 'Test',
            body: 'Body',
            cta: 'OK',
            unlockProCta: 'Unlock Pro',
          ),
        },
      );
      await service.dismissAnnouncement(announcement);

      expect(prefs.getString('dismissed_announcement_id'), 'test_id');
    });

    test('getDismissedAnnouncementId returns stored id', () async {
      SharedPreferences.setMockInitialValues({
        'dismissed_announcement_id': 'test_id',
      });
      final prefs = await SharedPreferences.getInstance();
      final service = WhatsNewService(prefs);

      expect(service.getDismissedAnnouncementId(), 'test_id');
    });

    test('getDismissedAnnouncementId returns null when nothing stored', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = WhatsNewService(prefs);

      expect(service.getDismissedAnnouncementId(), isNull);
    });

    test('loadAnnouncement returns null when JSON file missing', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = WhatsNewService(prefs);

      final announcement = await service.loadAnnouncement();
      expect(announcement, isNull);
    });
  });
}
