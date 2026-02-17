import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/generated/l10n.dart';
import 'package:threed_print_cost_calculator/settings/providers/printers_notifier.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class AddPrinter extends HookConsumerWidget {
  const AddPrinter({this.dbRef, super.key});

  final String? dbRef;

  @override
  Widget build(context, ref) {
    final notifier = ref.read(printersProvider.notifier)..init(dbRef);
    final state = ref.watch(printersProvider);
    final l10n = S.of(context);

    // Hook-managed controllers and focus nodes to avoid clobbering while typing
    final nameController = useTextEditingController(text: state.name.value);
    final nameFocus = useFocusNode();
    useEffect(() {
      if (!nameFocus.hasFocus) nameController.text = state.name.value;
      return null;
    }, [state.name.value]);

    final bedController = useTextEditingController(text: state.bedSize.value);
    final bedFocus = useFocusNode();
    useEffect(() {
      if (!bedFocus.hasFocus) bedController.text = state.bedSize.value;
      return null;
    }, [state.bedSize.value]);

    final wattController = useTextEditingController(text: state.wattage.value);
    final wattFocus = useFocusNode();
    useEffect(() {
      if (!wattFocus.hasFocus) wattController.text = state.wattage.value;
      return null;
    }, [state.wattage.value]);

    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        physics: const ClampingScrollPhysics(),
        child: AutofillGroup(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              FocusSafeTextField(
                controller: nameController,
                externalText: state.name.value,
                focusNode: nameFocus,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: l10n.printerNameLabel),
                onChanged: notifier.updateName,
              ),
              FocusSafeTextField(
                controller: bedController,
                externalText: state.bedSize.value,
                focusNode: bedFocus,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: l10n.bedSizeLabel),
                onChanged: notifier.updateBedSize,
              ),
              FocusSafeTextField(
                controller: wattController,
                externalText: state.wattage.value,
                focusNode: wattFocus,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.wattageLabel),
                onChanged: notifier.updateWattage,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: DEEP_BLUE,
                  textStyle: Theme.of(
                    context,
                  ).textTheme.displayMedium?.copyWith(fontSize: 16),
                ),
                onPressed: () => notifier.submit(dbRef),
                child: Text(l10n.saveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
