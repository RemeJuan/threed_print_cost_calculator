import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('syncs external text when not focused', (tester) async {
    final controller = TextEditingController();
    final hostKey = GlobalKey<_HostState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _Host(
            key: hostKey,
            controller: controller,
            externalText: 'initial',
          ),
        ),
      ),
    );

    await tester.pump();

    expect(controller.text, 'initial');

    hostKey.currentState!.setExternalText('updated');
    await tester.pump();

    expect(controller.text, 'updated');
    controller.dispose();
  });

  testWidgets('preserves edits while focused', (tester) async {
    final controller = TextEditingController();
    final focusNode = FocusNode();
    final hostKey = GlobalKey<_HostState>();

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: _Host(
            key: hostKey,
            controller: controller,
            externalText: 'initial',
            focusNode: focusNode,
          ),
        ),
      ),
    );

    await tester.pump();
    await tester.tap(find.byType(TextFormField));
    await tester.pump();

    await tester.enterText(find.byType(TextFormField), 'user input');
    await tester.pump();

    hostKey.currentState!.setExternalText('external change');
    await tester.pump();

    expect(controller.text, 'user input');

    focusNode.dispose();
    controller.dispose();
  });
}

class _Host extends StatefulWidget {
  const _Host({
    super.key,
    required this.controller,
    required this.externalText,
    this.focusNode,
  });

  final TextEditingController controller;
  final String externalText;
  final FocusNode? focusNode;

  @override
  State<_Host> createState() => _HostState();
}

class _HostState extends State<_Host> {
  late String _externalText;

  @override
  void initState() {
    super.initState();
    _externalText = widget.externalText;
  }

  void setExternalText(String value) {
    setState(() {
      _externalText = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return FocusSafeTextField(
      controller: widget.controller,
      externalText: _externalText,
      focusNode: widget.focusNode,
    );
  }
}
