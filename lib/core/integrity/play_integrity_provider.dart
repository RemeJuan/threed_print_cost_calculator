import 'package:hooks_riverpod/hooks_riverpod.dart';

import 'play_integrity_service.dart';

final playIntegrityServiceProvider = Provider<PlayIntegrityService>((ref) {
  return DefaultPlayIntegrityService();
});
