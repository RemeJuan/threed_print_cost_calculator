import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/providers/printers_notifier.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';
import 'package:threed_print_cost_calculator/shared/theme.dart';

class AddPrinter extends HookConsumerWidget {
  const AddPrinter({this.dbRef, super.key});

  final String? dbRef;

  @override
  Widget build(context, ref) {
    final notifier = ref.read(printersProvider.notifier);
    final state = ref.watch(printersProvider);
    final l10n = AppLocalizations.of(context)!;

    useEffect(() {
      notifier.init(dbRef);
      return null;
    }, [dbRef]);

    // Hook-managed controllers and focus nodes to avoid clobbering while typing
    final nameController = useTextEditingController(text: state.name.value);
    final nameFocus = useFocusNode();

    final bedController = useTextEditingController(text: state.bedSize.value);
    final bedFocus = useFocusNode();

    final wattController = useTextEditingController(text: state.wattage.value);
    final wattFocus = useFocusNode();

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
                key: const ValueKey<String>('settings.printers.name.input'),
                controller: nameController,
                externalText: state.name.value,
                focusNode: nameFocus,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: l10n.printerNameLabel),
                onChanged: notifier.updateName,
              ),
              FocusSafeTextField(
                key: const ValueKey<String>('settings.printers.bedSize.input'),
                controller: bedController,
                externalText: state.bedSize.value,
                focusNode: bedFocus,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(labelText: l10n.bedSizeLabel),
                onChanged: notifier.updateBedSize,
              ),
              FocusSafeTextField(
                key: const ValueKey<String>('settings.printers.wattage.input'),
                controller: wattController,
                externalText: state.wattage.value,
                focusNode: wattFocus,
                keyboardType: TextInputType.number,
                inputNormalizer: normalizeLeadingZeroNumericInput,
                decoration: InputDecoration(labelText: l10n.wattageLabel),
                onChanged: notifier.updateWattage,
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                key: const ValueKey<String>('settings.printers.save.button'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: DEEP_BLUE,
                  textStyle: Theme.of(
                    context,
                  ).textTheme.displayMedium?.copyWith(fontSize: 16),
                ),
                onPressed: () async {
                  await notifier.submit(dbRef);
                  if (!context.mounted) return;
                  Navigator.of(context, rootNavigator: true).pop();
                },
                child: Text(l10n.saveButton),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
