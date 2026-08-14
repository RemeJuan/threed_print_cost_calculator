import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_cached.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store_shared_prefs.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SharedPreferences prefs;
  late SharedPrefsPremiumLocalStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    store = SharedPrefsPremiumLocalStore(prefs);
  });

  test('read methods normalize legacy int values', () async {
    SharedPreferences.setMockInitialValues({'run_count': 0});
    prefs = await SharedPreferences.getInstance();
    store = SharedPrefsPremiumLocalStore(prefs);

    expect(store.readSync('run_count'), '0');
    expect(await store.read('run_count'), '0');
    expect(await store.readAll(), {'run_count': '0'});
  });

  test('write stores value in shared prefs', () async {
    await store.write('count', '1');

    expect(prefs.getString('count'), '1');
  });

  test('readAll returns known shared pref keys only', () async {
    await prefs.setString('calculation_count', '1');
    await prefs.setString('other', 'x');

    final values = await store.readAll();

    expect(values['calculation_count'], '1');
    expect(values.containsKey('other'), isFalse);
  });

  test(
    'cached write tolerates duplicate keychain item and serves cache',
    () async {
      final calls = <MethodCall>[];
      var writeAttempts = 0;
      final channel = MethodChannel(
        'plugins.it_nomads.com/flutter_secure_storage',
      );
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            calls.add(call);
            if (call.method == 'readAll') return <String, String>{};
            if (call.method == 'write') {
              writeAttempts++;
              throw PlatformException(code: '-25299');
            }
            if (call.method == 'delete') return null;
            return null;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      final storage = const FlutterSecureStorage();
      final cache = CachedPremiumLocalStore(storage);
      await cache.preload();

      await cache.write('count', '9');

      expect(cache.readSync('count'), '9');
      expect(await cache.read('count'), '9');
      expect(await cache.readAll(), {'count': '9'});
      expect(writeAttempts, 2);
      expect(calls.where((call) => call.method == 'delete'), hasLength(1));
    },
  );

  test(
    'cached write retries after delete on duplicate keychain item',
    () async {
      final channel = MethodChannel(
        'plugins.it_nomads.com/flutter_secure_storage',
      );
      var writeAttempts = 0;
      var deleteAttempts = 0;
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(channel, (call) async {
            if (call.method == 'readAll') return <String, String>{};
            if (call.method == 'write') {
              writeAttempts++;
              if (writeAttempts == 1) {
                throw PlatformException(code: '-25299');
              }
              return null;
            }
            if (call.method == 'delete') {
              deleteAttempts++;
              return null;
            }
            return null;
          });
      addTearDown(() {
        TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
            .setMockMethodCallHandler(channel, null);
      });

      final cache = CachedPremiumLocalStore(const FlutterSecureStorage());
      await cache.preload();

      await cache.write('count', '10');

      expect(writeAttempts, 2);
      expect(deleteAttempts, 1);
      expect(cache.readSync('count'), '10');
    },
  );
}
