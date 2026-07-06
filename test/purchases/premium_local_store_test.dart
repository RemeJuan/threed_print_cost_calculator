import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/purchases/premium_local_store.dart';

void main() {
  late SharedPreferences prefs;
  late SharedPrefsPremiumLocalStore store;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    store = SharedPrefsPremiumLocalStore(prefs);
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
}
