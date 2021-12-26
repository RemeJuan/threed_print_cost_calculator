// Copyright (c) 2021, Very Good Ventures
// https://verygood.ventures
//
// Use of this source code is governed by an MIT-style
// license that can be found in the LICENSE file or at
// https://opensource.org/licenses/MIT.
import 'package:sembast/sembast.dart';
import 'package:sembast/sembast_memory.dart';
import 'package:threed_print_cost_calculator/locator.dart' as di;
import 'package:threed_print_cost_calculator/locator.dart';

export 'pump_app.dart';

Future<void> setupTest() async {
  di.initServices();
  di.sl.allowReassignment = true;

  sl.registerSingletonAsync<Database>(
    () async => databaseFactoryMemory.openDatabase('database'),
  );
  await sl.allReady();
}
