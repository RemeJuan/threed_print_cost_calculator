import 'package:material_ui/material_ui.dart';

Widget homeButton(BuildContext context) {
  return IconButton(
    icon: const Icon(Icons.home_outlined),
    tooltip: 'Home',
    onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
  );
}
