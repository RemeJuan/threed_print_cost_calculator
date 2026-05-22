import 'dart:typed_data';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';

class GCodeImportPreviewDialog extends StatelessWidget {
  const GCodeImportPreviewDialog({
    super.key,
    required this.bytes,
    required this.l10n,
  });

  final Uint8List bytes;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final maxWidth = math.max(0.0, mediaQuery.size.width - (kAppSpace16 * 2));
    final maxHeight = math.max(0.0, mediaQuery.size.height - (kAppSpace16 * 2));

    return Dialog(
      backgroundColor: PREVIEW_BACKDROP,
      insetPadding: const EdgeInsets.all(kAppSpace16),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth, maxHeight: maxHeight),
        child: Stack(
          children: [
            Positioned.fill(
              child: Padding(
                padding: const EdgeInsets.all(kAppSpace16),
                child: Center(
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.none,
                    gaplessPlayback: true,
                    isAntiAlias: false,
                    errorBuilder: (context, error, stackTrace) => Center(
                      child: Text(
                        l10n.importGcodePreviewDecodeFailed,
                        textAlign: TextAlign.center,
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: TEXT_PRIMARY),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                left: false,
                child: IconButton(
                  tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close, color: ICON_PRIMARY),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
