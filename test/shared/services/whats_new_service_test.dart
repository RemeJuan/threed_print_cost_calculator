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
        'en': {
          'body': 'Test Body',
          'cta': 'OK',
          'unlock_pro_cta': 'Unlock Pro',
        },
      };
      final announcement = WhatsNewAnnouncement.fromJson(json);
      expect(announcement, isNull);
    });

    test('returns null for missing body', () {
      final json = {
        'wn_id': 'test_123',
        'en': {
          'title': 'Test Title',
          'cta': 'OK',
          'unlock_pro_cta': 'Unlock Pro',
        },
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

    test(
      'falls back to English for body but returns empty for missing title',
      () {
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
      },
    );
  });

  group('WhatsNewService', () {
    const currentAnnouncement = WhatsNewAnnouncement(
      id: 'gcode_import_2026_04',
      locales: {
        'en': WhatsNewAnnouncementLocale(
          title: 'Title',
          body: 'Body',
          cta: 'Got it',
          unlockProCta: 'Start free trial',
        ),
      },
    );

    test('shows when announcement id is not dismissed', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = WhatsNewService(prefs);

      final shouldShow = await service.shouldShowAnnouncement(
        currentAnnouncement,
      );

      expect(shouldShow, true);
    });

    test('does not show for same announcement id after dismiss', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = WhatsNewService(prefs);

      await service.dismissAnnouncement(currentAnnouncement);
      final shouldShow = await service.shouldShowAnnouncement(
        currentAnnouncement,
      );

      expect(shouldShow, false);
    });

    test('shows again when announcement id changes', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = WhatsNewService(prefs);

      await service.dismissAnnouncement(
        const WhatsNewAnnouncement(
          id: 'old_id',
          locales: {
            'en': WhatsNewAnnouncementLocale(
              title: 'Old',
              body: 'Old Body',
              cta: 'Got it',
              unlockProCta: 'Start free trial',
            ),
          },
        ),
      );
      final shouldShow = await service.shouldShowAnnouncement(
        currentAnnouncement,
      );

      expect(shouldShow, true);
    });

    test('dismiss persists dismissed_announcement_id', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = WhatsNewService(prefs);

      await service.dismissAnnouncement(currentAnnouncement);

      expect(prefs.getString('dismissed_announcement_id'), currentAnnouncement.id);
    });

    test('legacy launch markers do not suppress a new announcement', () async {
      SharedPreferences.setMockInitialValues({
        'has_launched_before': true,
        'last_seen_version': '1.2.3',
      });
      final prefs = await SharedPreferences.getInstance();
      final service = WhatsNewService(prefs);

      final shouldShow = await service.shouldShowAnnouncement(
        currentAnnouncement,
      );

      expect(shouldShow, true);
      expect(prefs.getString('dismissed_announcement_id'), isNull);
    });

    test('loadAnnouncement returns null when JSON file missing', () async {
      final prefs = await SharedPreferences.getInstance();
      final service = WhatsNewService(prefs);

      final announcement = await service.loadAnnouncement();
      expect(announcement, isNull);
    });
  });
}
