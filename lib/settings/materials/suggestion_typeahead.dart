import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:threed_print_cost_calculator/app/components/focus_safe_text_field.dart';

class SuggestionTypeahead extends HookWidget {
  final List<String> suggestions;
  final String labelText;
  final String initialValue;
  final ValueChanged<String> onChanged;
  final ValueKey<String>? fieldKey;

  const SuggestionTypeahead({
    super.key,
    required this.suggestions,
    required this.labelText,
    required this.initialValue,
    required this.onChanged,
    this.fieldKey,
  });

  @override
  Widget build(context) {
    final controller = useTextEditingController(text: initialValue);
    final focusNode = useFocusNode();
    final layerLink = useMemoized(() => LayerLink());
    final showSuggestions = useState(false);

    useEffect(() {
      Timer? blurTimer;

      void onBlur() {
        if (focusNode.hasFocus) return;
        blurTimer?.cancel();
        blurTimer = Timer(const Duration(milliseconds: 200), () {
          showSuggestions.value = false;
        });
      }

      focusNode.addListener(onBlur);
      return () {
        blurTimer?.cancel();
        focusNode.removeListener(onBlur);
      };
    }, [focusNode]);

    void select(String value) {
      controller.text = value;
      controller.selection = TextSelection.fromPosition(
        TextPosition(offset: value.length),
      );
      onChanged(value);
      showSuggestions.value = false;
    }

    return CompositedTransformTarget(
      link: layerLink,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          FocusSafeTextField(
            key: fieldKey,
            controller: controller,
            externalText: initialValue,
            focusNode: focusNode,
            keyboardType: TextInputType.text,
            decoration: InputDecoration(labelText: labelText),
            onChanged: (v) {
              onChanged(v);
              if (v.isNotEmpty &&
                  suggestions.any(
                    (s) => s.toLowerCase().contains(v.toLowerCase()),
                  )) {
                showSuggestions.value = true;
              } else {
                showSuggestions.value = false;
              }
            },
          ),
          if (showSuggestions.value)
            CompositedTransformFollower(
              link: layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 0),
              child: Material(
                elevation: 4,
                color: const Color.fromRGBO(26, 28, 43, 1),
                borderRadius: BorderRadius.circular(8),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxHeight: 200),
                  child: ListView.builder(
                    padding: EdgeInsets.zero,
                    shrinkWrap: true,
                    itemCount: suggestions.length,
                    itemBuilder: (_, i) {
                      final item = suggestions.elementAt(i);
                      final query = controller.text.toLowerCase();
                      if (query.isNotEmpty &&
                          !item.toLowerCase().contains(query)) {
                        return const SizedBox.shrink();
                      }
                      return InkWell(
                        onTap: () => select(item),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          child: Text(
                            item,
                            style: const TextStyle(color: Colors.white70),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
