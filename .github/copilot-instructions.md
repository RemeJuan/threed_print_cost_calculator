# GitHub Copilot Instructions - 3D Print Cost Calculator

## Project Overview
This is a Flutter mobile application (iOS, Android, Web, and Desktop) that helps users calculate the cost of 3D printing projects. The app considers multiple factors including material cost, electricity consumption based on printer wattage, wear and tear, failure risk, and labor rates.

## Technology Stack
- **Framework**: Flutter 3.x with Dart SDK >=3.10.0
- **State Management**: Riverpod 3.x (StateNotifierProvider, Provider)
- **Database**: Sembast (NoSQL local database)
- **Backend Services**: Firebase (Analytics, Crashlytics, App Check)
- **Testing**: flutter_test, bloc_test, mocktail
- **UI Components**: Material Design with Google Fonts

## Code Style and Standards

### Linting
- Follow `package:flutter_lints/flutter.yaml` rules
- **Disabled rules**:
  - `public_member_api_docs`: Documentation comments are optional
  - `constant_identifier_names`: Allows flexible naming for constants
- Exclude generated files: `**/*.g.dart`, `**/*.freezed.dart`

### Dart Conventions
- Use descriptive variable names without Hungarian notation
- Prefer `final` over `var` when values won't change
- Use trailing commas for better formatting
- Avoid unnecessary null checks with null-safety
- Use `late` keyword judiciously and only when necessary

### File Organization
```
lib/
├── app/              # Main app configuration, theme, routing
├── calculator/       # Core calculator feature
│   ├── helpers/      # Business logic and utilities
│   ├── provider/     # Riverpod state management
│   ├── state/        # State models
│   └── view/         # UI widgets
├── database/         # Database helpers and models
├── history/          # Calculation history feature
├── settings/         # User settings and preferences
└── l10n/             # Internationalization
```

## State Management with Riverpod

### Provider Patterns
- Use `StateNotifierProvider` for mutable state that needs lifecycle management
- Use `Provider` for immutable/computed values
- Use `FutureProvider` for async data loading
- Always pass `Ref` to providers for dependency injection

### Example Provider Structure
```dart
final myProvider = StateNotifierProvider<MyNotifier, MyState>(
  (ref) {
    final dependency = ref.read(dependencyProvider);
    return MyNotifier(ref, dependency);
  },
);

class MyNotifier extends StateNotifier<MyState> {
  final Ref ref;
  
  MyNotifier(this.ref) : super(MyState());
  
  void updateValue(String value) {
    state = state.copyWith(value: value);
  }
}
```

## Database Operations

### Sembast Usage
- Use `StoreRef` for type-safe database operations
- Database names are defined in `DBName` enum
- Use `DatabaseHelpers` for common CRUD operations
- Always handle async operations properly

### Database Structure
- `settings`: User preferences and app settings
- `printers`: Saved printer configurations
- `history`: Past calculation records

## Testing Guidelines

### Test Organization
- Mirror the `lib/` structure in `test/` directory
- Place shared test utilities in `test/helpers/`
- Use `mocktail` for mocking dependencies
- Use `bloc_test` for testing state notifiers

### Test Conventions
```dart
void main() {
  group('MyFeature', () {
    late MyNotifier notifier;
    
    setUp(() {
      notifier = MyNotifier();
    });
    
    test('should update state correctly', () {
      // Arrange
      const testValue = 'test';
      
      // Act
      notifier.updateValue(testValue);
      
      // Assert
      expect(notifier.state.value, equals(testValue));
    });
  });
}
```

### Running Tests
```bash
# Run all tests
fvm flutter test test --no-pub --test-randomize-ordering-seed random

# Run specific test file
fvm flutter test test/path/to/test_file.dart
```

## Feature Development

### Calculator Logic
- All calculation helpers are in `lib/calculator/helpers/calculator_helpers.dart`
- Use precise decimal arithmetic for cost calculations
- Consider all factors: material, electricity, wear & tear, failure risk, labor
- Validate all numeric inputs using `Formz` validators in `NumberInput`

### UI Development
- Use Material Design 3 components
- Implement responsive layouts that work across mobile, tablet, and desktop
- Use `flutter_hooks` for stateful widget logic when appropriate
- Leverage `flutter_slidable` for swipe actions in lists
- Apply consistent spacing and padding using Material Design guidelines

### Internationalization
- Use Flutter's `intl` package for localization
- Localization files are in `lib/l10n/`
- Use `Localizely SDK` for OTA translation updates
- Always wrap user-facing strings with localization

## Common Patterns

### Number Input Validation
```dart
import 'package:threed_print_cost_calculator/app/components/num_input.dart';

// In state class
final NumberInput myValue;

// In notifier
void updateMyValue(String value) {
  final parsed = num.tryParse(value.replaceAll(',', '.'));
  state = state.copyWith(
    myValue: NumberInput.dirty(value: parsed),
  );
}
```

### Accessing Database
```dart
final dbHelpers = ref.read(dbHelpersProvider(DBName.settings));
final settings = await dbHelpers.getSettings();
```

### Navigation
- Use Flutter's navigation 2.0 pattern
- Keep navigation logic in the app layer

## Firebase Integration
- Firebase is initialized in `main.dart` via `bootstrap.dart`
- Use Firebase Analytics for tracking user events
- Firebase Crashlytics captures production errors
- App Check provides security for Firebase services

## Premium Features
- Implements RevenueCat for in-app purchases
- Premium features are gated behind subscription checks
- Handle premium state gracefully with fallbacks

## Performance Considerations
- Minimize rebuilds by using Riverpod selectors
- Avoid heavy computations in build methods
- Use `const` constructors where possible
- Optimize images and assets

## Version Management
- Use semantic versioning in `pubspec.yaml`
- Update version via Makefile commands:
  - `make bump_fix` - patch version
  - `make bump_feat` - minor version
  - `make bump_build` - build number

## Important Notes
- Always use `fvm flutter` commands (Flutter Version Management)
- Respect existing architecture patterns
- Keep widgets small and focused
- Write self-documenting code with clear variable names
- Consider offline-first functionality (local database primary)

## Code Generation
When suggesting code:
1. Follow the established patterns in existing files
2. Use Riverpod for state management (not Provider or BLoC directly)
3. Implement proper error handling
4. Consider edge cases (empty strings, null values, etc.)
5. Use Flutter best practices for widget composition
6. Ensure type safety throughout
7. Add tests for new functionality
