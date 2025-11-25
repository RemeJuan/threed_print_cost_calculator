import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:threed_print_cost_calculator/calculator/provider/calculator_notifier.dart';
import 'package:threed_print_cost_calculator/calculator/state/calculator_state.dart';
import 'package:riverpod/riverpod.dart';

class MockCalculatorNotifier extends StateNotifier<CalculatorState>
    with Mock
    implements CalculatorProvider {
  MockCalculatorNotifier() : super(CalculatorState());
}

class MockSharedPreferences extends Mock implements SharedPreferences {}
