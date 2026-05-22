import 'package:flutter/material.dart';

class AppSearchBar extends StatelessWidget {
  const AppSearchBar({
    required this.controller,
    required this.onChanged,
    this.hintText,
    this.labelText,
    this.showClearButton = true,
    this.textFieldKey,
    this.clearButtonKey,
    super.key,
  });

  final TextEditingController controller;
  final String? hintText;
  final String? labelText;
  final bool showClearButton;
  final ValueChanged<String> onChanged;
  final ValueKey<String>? textFieldKey;
  final ValueKey<String>? clearButtonKey;

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<TextEditingValue>(
      valueListenable: controller,
      builder: (_, value, _) {
        return TextField(
          key: textFieldKey,
          controller: controller,
          decoration: InputDecoration(
            isDense: true,
            hintText: hintText,
            labelText: labelText,
            prefixIcon: const Icon(Icons.search),
            suffixIcon: showClearButton && value.text.isNotEmpty
                ? IconButton(
                    key: clearButtonKey,
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                  )
                : null,
          ),
          onChanged: onChanged,
        );
      },
    );
  }
}
