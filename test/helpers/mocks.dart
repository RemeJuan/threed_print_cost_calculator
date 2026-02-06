import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';

class MockCalculatorNotifier extends CalculatorProvider with Mock {
  MockCalculatorNotifier() : super();

  @override
  CalculatorState build() => CalculatorState();
}

class MockSharedPreferences extends Mock implements SharedPreferences {}
