import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/settings/providers/printers_notifier.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';
import 'package:threed_print_cost_calculator/shared/utils/form_validation.dart';
import 'package:threed_print_cost_calculator/shared/utils/numeric_input_formatters.dart';
import 'package:threed_print_cost_calculator/shared/utils/text_input_normalizers.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';

class AddPrinter extends HookConsumerWidget {
  const AddPrinter({this.dbRef, super.key});

  final String? dbRef;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(printersProvider.notifier);
    final l10n = AppLocalizations.of(context)!;
    final formKey = useMemoized(GlobalKey<FormState>.new);
    final hasSubmitted = useState(false);

    final loadFuture = useMemoized(() => notifier.init(dbRef), [dbRef]);
    final loadSnapshot = useFuture(loadFuture);
    final state = ref.watch(printersProvider);

    // Hook-managed controllers and focus nodes to avoid clobbering while typing
    final nameController = useTextEditingController(text: state.name.value);
    final nameFocus = useFocusNode();

    final bedController = useTextEditingController(text: state.bedSize.value);
    final bedFocus = useFocusNode();

    final wattController = useTextEditingController(text: state.wattage.value);
    final wattFocus = useFocusNode();

    final avgWattController = useTextEditingController(
      text: state.averageWattage.value,
    );
    final avgWattFocus = useFocusNode();

    if (loadSnapshot.connectionState != ConnectionState.done) {
      return const Center(child: CircularProgressIndicator());
    }

    String? requiredTextValidator(String? value) {
      return localizedValidationMessage(l10n, notifier.validateName(value));
    }

    String? positiveNumberValidator(String? value) {
      return localizedValidationMessage(l10n, notifier.validateWattage(value));
    }

    String? averageWattageValidator(String? value) {
      return localizedValidationMessage(
        l10n,
        notifier.validateAverageWattage(value),
      );
    }

    String? bedSizeValidator(String? value) {
      return localizedValidationMessage(l10n, notifier.validateBedSize(value));
    }

    final isFormValid = notifier.isValidForSubmit;

    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        physics: const ClampingScrollPhysics(),
        child: Form(
          key: formKey,
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
                  validator: requiredTextValidator,
                  autovalidateMode: hasSubmitted.value
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  decoration: InputDecoration(labelText: l10n.printerNameLabel),
                  onChanged: notifier.updateName,
                ),
                FocusSafeTextField(
                  key: const ValueKey<String>(
                    'settings.printers.bedSize.input',
                  ),
                  controller: bedController,
                  externalText: state.bedSize.value,
                  focusNode: bedFocus,
                  keyboardType: TextInputType.text,
                  validator: bedSizeValidator,
                  autovalidateMode: hasSubmitted.value
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  decoration: InputDecoration(labelText: l10n.bedSizeLabel),
                  onChanged: notifier.updateBedSize,
                ),
                FocusSafeTextField(
                  key: const ValueKey<String>(
                    'settings.printers.wattage.input',
                  ),
                  controller: wattController,
                  externalText: state.wattage.value,
                  focusNode: wattFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: localizedDecimalInputFormatters,
                  inputNormalizer: normalizeLeadingZeroNumericInput,
                  validator: positiveNumberValidator,
                  autovalidateMode: hasSubmitted.value
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  decoration: InputDecoration(labelText: l10n.wattageLabel),
                  onChanged: notifier.updateWattage,
                ),
                FocusSafeTextField(
                  key: const ValueKey<String>(
                    'settings.printers.averageWattage.input',
                  ),
                  controller: avgWattController,
                  externalText: state.averageWattage.value,
                  focusNode: avgWattFocus,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  inputFormatters: localizedDecimalInputFormatters,
                  inputNormalizer: normalizeLeadingZeroNumericInput,
                  validator: averageWattageValidator,
                  autovalidateMode: hasSubmitted.value
                      ? AutovalidateMode.onUserInteraction
                      : AutovalidateMode.disabled,
                  decoration: InputDecoration(
                    labelText: l10n.averageWattageLabel,
                  ),
                  onChanged: notifier.updateAverageWattage,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    l10n.wattageFaqHint,
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(color: TEXT_TERTIARY),
                  ),
                ),
                const SizedBox(height: 16),
                AppPrimaryButton(
                  key: const ValueKey<String>('settings.printers.save.button'),
                  onPressed: !hasSubmitted.value || isFormValid
                      ? () async {
                          hasSubmitted.value = true;
                          if (!(formKey.currentState?.validate() ?? false)) {
                            return;
                          }

                          final didSave = await notifier.submit(dbRef);
                          if (!didSave || !context.mounted) return;
                          Navigator.of(context, rootNavigator: true).pop();
                        }
                      : null,
                  label: l10n.saveButton,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
