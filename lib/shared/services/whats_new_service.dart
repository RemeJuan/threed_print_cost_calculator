import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/shared/models/whats_new_announcement.dart';

class WhatsNewService {
  static const String _dismissedAnnouncementIdKey = 'dismissed_announcement_id';

  final SharedPreferences _prefs;

  WhatsNewService(this._prefs);

  Future<WhatsNewAnnouncement?> loadAnnouncement() async {
    try {
      final jsonString = await rootBundle.loadString('assets/whats_new.json');
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return WhatsNewAnnouncement.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<bool> shouldShowAnnouncement(WhatsNewAnnouncement announcement) async {
    final dismissedAnnouncementId = _prefs.getString(
      _dismissedAnnouncementIdKey,
    );
    return dismissedAnnouncementId != announcement.id;
  }

  Future<void> dismissAnnouncement(WhatsNewAnnouncement announcement) async {
    await _prefs.setString(_dismissedAnnouncementIdKey, announcement.id);
  }
}
