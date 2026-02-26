import 'dart:io' as io;
import 'dart:convert' as convert;
import 'package:path_provider/path_provider.dart' as path_provider;

import 'platform.dart';
import '../model/persisted_release_data.dart';
import '../../common/util/util.dart';

Platform createPlatform() => IOPlatform();

class IOPlatform implements Platform {
  static final String _localizelyReleaseDataFile =
      'localizely_release_data.json';

  Future<io.File> _getPersistedReleaseDataFile() async {
    var dir = await path_provider.getApplicationSupportDirectory();
    var filePath = '${dir.path}/$_localizelyReleaseDataFile';

    return io.File(filePath);
  }

  @override
  String getLocale() {
    return Util.canonicalizedLocale(io.Platform.localeName);
  }

  @override
  Future<PersistedReleaseData?> getPersistedReleaseData() async {
    var file = await _getPersistedReleaseDataFile();

    if (!file.existsSync()) {
      return null;
    }

    var content = await file.readAsString();
    var json = convert.jsonDecode(content);

    return PersistedReleaseData.fromJson(json);
  }

  @override
  Future<void> savePersistedReleaseData(PersistedReleaseData data) async {
    var file = await _getPersistedReleaseDataFile();

    if (!file.existsSync()) {
      await file.create(recursive: true);
    }

    var content = convert.jsonEncode(data);

    await file.writeAsString(content);
  }

  @override
  Future<void> removePersistedReleaseData() async {
    var file = await _getPersistedReleaseDataFile();

    if (file.existsSync()) {
      await file.delete();
    }
  }
}
