import 'package:flutter/material.dart';

import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_screen_header.dart';
import 'package:threed_print_cost_calculator/shared/widgets/home_button.dart';

PreferredSizeWidget buildAssignmentPageAppBar(
  BuildContext context,
  String title,
) {
  return AppScreenHeader(
    title: title,
    leading: BackButton(onPressed: () => Navigator.of(context).pop()),
    actions: [homeButton(context)],
  );
}

Widget buildAssignmentLoadingState(String title) {
  return Scaffold(
    appBar: AppScreenHeader(title: title),
    body: const Center(child: CircularProgressIndicator()),
  );
}

Widget buildAssignmentErrorState(
  String title,
  String errorText,
  String retryLabel,
  VoidCallback onRetry,
) {
  return Scaffold(
    appBar: AppScreenHeader(title: title),
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(kAppSpace16),
            child: Text(errorText, textAlign: TextAlign.center),
          ),
          const SizedBox(height: kAppSpace16),
          AppPrimaryButton(onPressed: onRetry, label: retryLabel),
        ],
      ),
    ),
  );
}

class AssignmentModeHeader<T extends Enum> extends StatelessWidget {
  const AssignmentModeHeader({
    super.key,
    required this.subtitle,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
  });

  final String subtitle;
  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
        const SizedBox(height: kAppSpace16),
        SegmentedButton<T>(
          segments: segments,
          selected: selected,
          onSelectionChanged: onSelectionChanged,
        ),
      ],
    );
  }
}

class AssignmentNavRow extends StatelessWidget {
  const AssignmentNavRow({
    super.key,
    required this.previousLabel,
    required this.nextLabel,
    this.nextEnabled = false,
    required this.onPrevious,
    required this.onNext,
  });

  final String previousLabel;
  final String nextLabel;
  final bool nextEnabled;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Row(
        children: [
          AppTertiaryButton(onPressed: onPrevious, label: previousLabel),
          const Spacer(),
          AppPrimaryButton(
            onPressed: nextEnabled ? onNext : null,
            label: nextLabel,
          ),
        ],
      ),
    );
  }
}
