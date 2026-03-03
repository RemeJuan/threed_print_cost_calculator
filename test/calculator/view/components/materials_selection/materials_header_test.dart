import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/calculator/view/components/materials_selection/materials_header.dart';

import '../../../../helpers/helpers.dart';

void main() {
  setUpAll(() async {
    await setupTest();
  });

  group('MaterialsHeader', () {
    testWidgets('displays header text', (tester) async {
      await tester.pumpApp(
        MaterialsHeader(
          count: 1,
          totalWeight: 100,
          expanded: false,
          onAdd: () {},
          onToggle: () {},
        ),
      );

      expect(find.textContaining('Materials'), findsOneWidget);
    });

    testWidgets('displays material count and weight', (tester) async {
      await tester.pumpApp(
        MaterialsHeader(
          count: 2,
          totalWeight: 150,
          expanded: false,
          onAdd: () {},
          onToggle: () {},
        ),
      );

      expect(find.textContaining('150g'), findsOneWidget);
    });

    testWidgets('displays correct count for single material', (tester) async {
      await tester.pumpApp(
        MaterialsHeader(
          count: 1,
          totalWeight: 100,
          expanded: false,
          onAdd: () {},
          onToggle: () {},
        ),
      );

      expect(find.textContaining('1'), findsWidgets);
    });

    testWidgets('displays correct count for multiple materials', (tester) async {
      await tester.pumpApp(
        MaterialsHeader(
          count: 5,
          totalWeight: 500,
          expanded: false,
          onAdd: () {},
          onToggle: () {},
        ),
      );

      expect(find.textContaining('5'), findsWidgets);
    });

    testWidgets('shows add button', (tester) async {
      await tester.pumpApp(
        MaterialsHeader(
          count: 1,
          totalWeight: 100,
          expanded: false,
          onAdd: () {},
          onToggle: () {},
        ),
      );

      expect(find.byIcon(Icons.add), findsOneWidget);
    });

    testWidgets('calls onAdd when add button is tapped', (tester) async {
      bool addCalled = false;

      await tester.pumpApp(
        MaterialsHeader(
          count: 1,
          totalWeight: 100,
          expanded: false,
          onAdd: () => addCalled = true,
          onToggle: () {},
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(addCalled, isTrue);
    });

    testWidgets('shows expand_more icon', (tester) async {
      await tester.pumpApp(
        MaterialsHeader(
          count: 1,
          totalWeight: 100,
          expanded: false,
          onAdd: () {},
          onToggle: () {},
        ),
      );

      expect(find.byIcon(Icons.expand_more), findsOneWidget);
    });

    testWidgets('calls onToggle when header is tapped', (tester) async {
      bool toggleCalled = false;

      await tester.pumpApp(
        MaterialsHeader(
          count: 1,
          totalWeight: 100,
          expanded: false,
          onAdd: () {},
          onToggle: () => toggleCalled = true,
        ),
      );

      await tester.tap(find.textContaining('Materials'));
      await tester.pumpAndSettle();

      expect(toggleCalled, isTrue);
    });

    testWidgets('rotates expand icon when expanded', (tester) async {
      await tester.pumpApp(
        MaterialsHeader(
          count: 1,
          totalWeight: 100,
          expanded: true,
          onAdd: () {},
          onToggle: () {},
        ),
      );

      final rotation = tester.widget<AnimatedRotation>(
        find.byType(AnimatedRotation),
      );

      expect(rotation.turns, equals(0.5));
    });

    testWidgets('does not rotate expand icon when collapsed', (tester) async {
      await tester.pumpApp(
        MaterialsHeader(
          count: 1,
          totalWeight: 100,
          expanded: false,
          onAdd: () {},
          onToggle: () {},
        ),
      );

      final rotation = tester.widget<AnimatedRotation>(
        find.byType(AnimatedRotation),
      );

      expect(rotation.turns, equals(0.0));
    });

    testWidgets('displays zero weight correctly', (tester) async {
      await tester.pumpApp(
        MaterialsHeader(
          count: 1,
          totalWeight: 0,
          expanded: false,
          onAdd: () {},
          onToggle: () {},
        ),
      );

      expect(find.textContaining('0g'), findsOneWidget);
    });

    testWidgets('displays large weight correctly', (tester) async {
      await tester.pumpApp(
        MaterialsHeader(
          count: 10,
          totalWeight: 9999,
          expanded: false,
          onAdd: () {},
          onToggle: () {},
        ),
      );

      expect(find.textContaining('9999g'), findsOneWidget);
    });

    testWidgets('header has InkWell for tap feedback', (tester) async {
      await tester.pumpApp(
        MaterialsHeader(
          count: 1,
          totalWeight: 100,
          expanded: false,
          onAdd: () {},
          onToggle: () {},
        ),
      );

      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('header has correct padding', (tester) async {
      await tester.pumpApp(
        MaterialsHeader(
          count: 1,
          totalWeight: 100,
          expanded: false,
          onAdd: () {},
          onToggle: () {},
        ),
      );

      final padding = tester.widget<Padding>(
        find.descendant(
          of: find.byType(InkWell),
          matching: find.byType(Padding),
        ).first,
      );

      expect(padding.padding, equals(const EdgeInsets.symmetric(horizontal: 16, vertical: 12)));
    });

    testWidgets('displays zero count', (tester) async {
      await tester.pumpApp(
        MaterialsHeader(
          count: 0,
          totalWeight: 0,
          expanded: false,
          onAdd: () {},
          onToggle: () {},
        ),
      );

      expect(find.textContaining('0'), findsWidgets);
    });

    testWidgets('add button is tappable independently', (tester) async {
      bool addCalled = false;
      bool toggleCalled = false;

      await tester.pumpApp(
        MaterialsHeader(
          count: 1,
          totalWeight: 100,
          expanded: false,
          onAdd: () => addCalled = true,
          onToggle: () => toggleCalled = true,
        ),
      );

      await tester.tap(find.byIcon(Icons.add));
      await tester.pumpAndSettle();

      expect(addCalled, isTrue);
      expect(toggleCalled, isFalse);
    });

    testWidgets('toggle does not trigger add', (tester) async {
      bool addCalled = false;
      bool toggleCalled = false;

      await tester.pumpApp(
        MaterialsHeader(
          count: 1,
          totalWeight: 100,
          expanded: false,
          onAdd: () => addCalled = true,
          onToggle: () => toggleCalled = true,
        ),
      );

      await tester.tap(find.textContaining('Materials'));
      await tester.pumpAndSettle();

      expect(addCalled, isFalse);
      expect(toggleCalled, isTrue);
    });

    testWidgets('animation duration is 200ms', (tester) async {
      await tester.pumpApp(
        MaterialsHeader(
          count: 1,
          totalWeight: 100,
          expanded: false,
          onAdd: () {},
          onToggle: () {},
        ),
      );

      final rotation = tester.widget<AnimatedRotation>(
        find.byType(AnimatedRotation),
      );

      expect(rotation.duration, equals(const Duration(milliseconds: 200)));
    });

    testWidgets('animation uses easeInOut curve', (tester) async {
      await tester.pumpApp(
        MaterialsHeader(
          count: 1,
          totalWeight: 100,
          expanded: false,
          onAdd: () {},
          onToggle: () {},
        ),
      );

      final rotation = tester.widget<AnimatedRotation>(
        find.byType(AnimatedRotation),
      );

      expect(rotation.curve, equals(Curves.easeInOut));
    });
  });
}