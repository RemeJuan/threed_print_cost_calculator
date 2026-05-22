import 'package:flutter/material.dart';

Widget homeButton(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.home_outlined),
    tooltip: 'Home',
    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
  );
}
