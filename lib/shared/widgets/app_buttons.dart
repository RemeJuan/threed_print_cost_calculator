import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';

const double _kButtonHeight = 48;
const double _kButtonRadius = 8;
const double _kIconGap = 8;

class AppPrimaryButton extends StatelessWidget {
  const AppPrimaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return ElevatedButton(
      onPressed: enabled ? onPressed : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: LIGHT_BLUE,
        foregroundColor: TEXT_INVERSE,
        disabledBackgroundColor: LIGHT_BLUE.withValues(alpha: 0.4),
        disabledForegroundColor: TEXT_INVERSE.withValues(alpha: 0.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kButtonRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        minimumSize: const Size(0, _kButtonHeight),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      child: _ButtonContent(
        icon: icon,
        label: label,
        loading: loading,
        activeColor: TEXT_INVERSE,
      ),
    );
  }
}

class AppSecondaryButton extends StatelessWidget {
  const AppSecondaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        foregroundColor: LIGHT_BLUE,
        disabledForegroundColor: LIGHT_BLUE.withValues(alpha: 0.4),
        side: BorderSide(
          color: enabled ? LIGHT_BLUE : LIGHT_BLUE.withValues(alpha: 0.4),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kButtonRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24),
        minimumSize: const Size(0, _kButtonHeight),
        textStyle: const TextStyle(fontWeight: FontWeight.w600),
      ),
      child: _ButtonContent(
        icon: icon,
        label: label,
        loading: loading,
        activeColor: LIGHT_BLUE,
      ),
    );
  }
}

class AppTertiaryButton extends StatelessWidget {
  const AppTertiaryButton({
    super.key,
    required this.onPressed,
    required this.label,
    this.icon,
    this.loading = false,
  });

  final VoidCallback? onPressed;
  final String label;
  final Widget? icon;
  final bool loading;

  @override
  Widget build(BuildContext context) {
    final enabled = onPressed != null && !loading;
    return TextButton(
      onPressed: enabled ? onPressed : null,
      style: TextButton.styleFrom(
        foregroundColor: LIGHT_BLUE,
        disabledForegroundColor: LIGHT_BLUE.withValues(alpha: 0.4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_kButtonRadius),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        minimumSize: const Size(0, _kButtonHeight),
        textStyle: const TextStyle(fontWeight: FontWeight.w500),
      ),
      child: _ButtonContent(
        icon: icon,
        label: label,
        loading: loading,
        activeColor: LIGHT_BLUE,
      ),
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({
    required this.label,
    required this.activeColor,
    this.icon,
    this.loading = false,
  });

  final String label;
  final Widget? icon;
  final bool loading;
  final Color activeColor;

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return SizedBox(
        height: 24,
        child: Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(activeColor),
            ),
          ),
        ),
      );
    }
    if (icon != null) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          icon!,
          const SizedBox(width: _kIconGap),
          Text(label),
        ],
      );
    }
    return Text(label);
  }
}
