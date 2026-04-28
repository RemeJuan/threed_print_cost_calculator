class WhatsNewAnnouncementLocale {
  final String title;
  final String body;
  final String cta;
  final String unlockProCta;

  const WhatsNewAnnouncementLocale({
    required this.title,
    required this.body,
    required this.cta,
    required this.unlockProCta,
  });

  static WhatsNewAnnouncementLocale? fromJson(Object? json) {
    final map = json as Map<String, dynamic>?;
    if (map == null) return null;

    final title = map['title'] as String?;
    final body = map['body'] as String?;
    final cta = map['cta'] as String?;
    final unlockProCta = map['unlock_pro_cta'] as String?;

    if (title == null || title.isEmpty) return null;
    if (body == null || body.isEmpty) return null;
    if (cta == null || cta.isEmpty) return null;
    if (unlockProCta == null || unlockProCta.isEmpty) return null;

    return WhatsNewAnnouncementLocale(
      title: title,
      body: body,
      cta: cta,
      unlockProCta: unlockProCta,
    );
  }
}

class WhatsNewAnnouncement {
  final String id;
  final Map<String, WhatsNewAnnouncementLocale> locales;

  const WhatsNewAnnouncement({
    required this.id,
    required this.locales,
  });

  static WhatsNewAnnouncement? fromJson(Map<String, dynamic> json) {
    final id = json['wn_id'] as String?;
    if (id == null || id.isEmpty) return null;

    final locales = <String, WhatsNewAnnouncementLocale>{};
    for (final entry in json.entries) {
      if (entry.key == 'wn_id') continue;
      final locale = WhatsNewAnnouncementLocale.fromJson(entry.value);
      if (locale != null) {
        locales[entry.key] = locale;
      }
    }

    final english = locales['en'];
    if (english == null) return null;

    return WhatsNewAnnouncement(id: id, locales: locales);
  }

  String getLocalizedTitle(String languageCode) {
    return _locale(languageCode)?.title ?? '';
  }

  String getLocalizedBody(String languageCode) {
    return _locale(languageCode)?.body ?? '';
  }

  String getLocalizedCta(String languageCode) {
    return _locale(languageCode)?.cta ?? '';
  }

  String getLocalizedUnlockProCta(String languageCode) {
    return _locale(languageCode)?.unlockProCta ?? '';
  }

  WhatsNewAnnouncementLocale? _locale(String languageCode) {
    return locales[languageCode] ?? locales['en'];
  }
}
