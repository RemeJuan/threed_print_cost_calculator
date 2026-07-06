import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_migration.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const channel = MethodChannel('plugins.it_nomads.com/flutter_secure_storage');

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'readAll') {
            return <String, String>{'calculation_count': '7', 'orphan': 'x'};
          }
          if (call.method == 'deleteAll') {
            return null;
          }
          return null;
        });
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('migrateFromSecureToSharedPrefs copies keychain values', () async {
    final prefs = await SharedPreferences.getInstance();

    await migrateFromSecureToSharedPrefs(sharedPreferences: prefs);

    expect(prefs.getString('calculation_count'), '7');
    expect(prefs.getString('orphan'), 'x');
  });

  test('cleanupSecureStorage ignores deleteAll errors', () async {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          if (call.method == 'deleteAll') {
            throw PlatformException(code: 'boom');
          }
          return <String, String>{};
        });

    await cleanupSecureStorage();
  });
}
