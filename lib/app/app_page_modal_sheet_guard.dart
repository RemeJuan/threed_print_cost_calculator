import 'package:material_ui/material_ui.dart';

bool canShowAppPageModalSheet(BuildContext context) {
  final route = ModalRoute.of(context);
  final isRouteCurrent = route?.isCurrent ?? true;
  final lifecycleState = WidgetsBinding.instance.lifecycleState;
  final isAppResumed =
      lifecycleState == null || lifecycleState == AppLifecycleState.resumed;

  return isRouteCurrent && isAppResumed;
}
