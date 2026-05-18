import 'package:flutter/material.dart';

class GCodeImportHeader extends StatelessWidget {
  const GCodeImportHeader({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(text, style: Theme.of(context).textTheme.bodyMedium);
  }
}
