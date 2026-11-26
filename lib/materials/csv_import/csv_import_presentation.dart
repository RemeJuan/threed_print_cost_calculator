import 'package:material_ui/material_ui.dart';
import 'package:threed_print_cost_calculator/l10n/app_localizations.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_parser.dart';
import 'package:threed_print_cost_calculator/materials/csv_import/csv_import_service.dart';
import 'package:threed_print_cost_calculator/shared/app_colors.dart';
import 'package:threed_print_cost_calculator/shared/app_ui_tokens.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_buttons.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_expansion_card.dart';
import 'package:threed_print_cost_calculator/shared/widgets/app_surface_card.dart';

class CsvImportReviewView extends StatelessWidget {
  const CsvImportReviewView({
    super.key,
    required this.review,
    required this.l10n,
    required this.confirming,
    required this.onApply,
  });

  final ClassifiedCsvImport review;
  final AppLocalizations l10n;
  final bool confirming;
  final VoidCallback onApply;

  @override
  Widget build(BuildContext context) {
    final updates = _rowsOf(CsvImportRowKind.update);
    final creates = _rowsOf(CsvImportRowKind.create);
    final invalid = _rowsOf(CsvImportRowKind.invalid);
    final validCount = updates.length + creates.length;
    return Column(
      children: [
        AppSurfaceCard(
          margin: const EdgeInsets.all(kAppSpace16),
          padding: const EdgeInsets.all(kAppSpace12),
          child: Text(
            l10n.csvImportReviewSummary(
              creates.length,
              invalid.length,
              review.rows.length,
              updates.length,
            ),
            style: const TextStyle(
              color: TEXT_PRIMARY,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.only(bottom: kAppSpace16),
            children: [
              _buildSection(
                key: const ValueKey<String>('csv_import.needs_fixing.section'),
                title: l10n.csvImportNeedsFixingSection(invalid.length),
                rows: invalid,
                initiallyExpanded: true,
                kind: CsvImportRowKind.invalid,
              ),
              _buildSection(
                key: const ValueKey<String>('csv_import.updating.section'),
                title: l10n.csvImportUpdatingSection(updates.length),
                rows: updates,
                kind: CsvImportRowKind.update,
              ),
              _buildSection(
                key: const ValueKey<String>('csv_import.creating.section'),
                title: l10n.csvImportCreatingSection(creates.length),
                rows: creates,
                kind: CsvImportRowKind.create,
              ),
            ],
          ),
        ),
        if (validCount > 0)
          SafeArea(
            minimum: const EdgeInsets.all(kAppSpace16),
            child: SizedBox(
              width: double.infinity,
              child: AppPrimaryButton(
                key: const ValueKey<String>('csv_import.apply.button'),
                onPressed: confirming ? null : onApply,
                loading: confirming,
                icon: const Icon(Icons.check),
                label: l10n.csvImportApplyButton,
              ),
            ),
          ),
      ],
    );
  }

  List<CsvImportRow> _rowsOf(CsvImportRowKind kind) =>
      review.rows.where((row) => row.kind == kind).toList();

  Widget _buildSection({
    required Key key,
    required String title,
    required List<CsvImportRow> rows,
    required CsvImportRowKind kind,
    bool initiallyExpanded = false,
  }) {
    return AppExpansionCard(
      key: key,
      initiallyExpanded: initiallyExpanded,
      title: Text(title),
      margin: const EdgeInsets.symmetric(
        horizontal: kAppSpace16,
        vertical: kAppSpace4,
      ),
      tilePadding: const EdgeInsets.symmetric(horizontal: kAppSpace16),
      childrenPadding: const EdgeInsets.only(bottom: kAppSpace8),
      children: rows.map((row) => _buildRowCard(row, kind)).toList(),
    );
  }

  Widget _buildRowCard(CsvImportRow row, CsvImportRowKind kind) {
    final invalid = kind == CsvImportRowKind.invalid;
    final status = invalid
        ? l10n.csvImportNeedsFixingStatus
        : kind == CsvImportRowKind.update
        ? l10n.csvImportUpdatingStatus
        : l10n.csvImportCreatingStatus;
    return AppSurfaceCard(
      margin: const EdgeInsets.symmetric(
        horizontal: kAppSpace16,
        vertical: kAppSpace4,
      ),
      padding: const EdgeInsets.all(kAppSpace12),
      backgroundColor: invalid
          ? STATUS_ERROR.withValues(alpha: 0.14)
          : CARD_BACKGROUND,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  row.name.isEmpty ? l10n.csvEmptyNamePlaceholder : row.name,
                  style: const TextStyle(
                    color: TEXT_PRIMARY,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                invalid ? Icons.error_outline : Icons.check_circle_outline,
                color: invalid ? STATUS_ERROR : STATUS_SUCCESS,
              ),
            ],
          ),
          const SizedBox(height: kAppSpace4),
          Text(
            '${l10n.csvImportRowLine(row.lineNumber)} · $status',
            style: const TextStyle(color: TEXT_TERTIARY),
          ),
          if (invalid) ...[
            const SizedBox(height: kAppSpace8),
            Text(
              row.errors.map((error) => _errorMessage(error)).join(', '),
              style: const TextStyle(color: STATUS_ERROR),
            ),
          ],
        ],
      ),
    );
  }

  String _errorMessage(CsvImportError error) {
    switch (error.code) {
      case CsvImportErrorCode.requiredName:
        return l10n.csvNameRequiredError;
      case CsvImportErrorCode.requiredColor:
        return l10n.csvColorRequiredError;
      case CsvImportErrorCode.requiredSpoolWeight:
        return l10n.csvSpoolWeightPositiveError;
      case CsvImportErrorCode.invalidSpoolWeight:
        return l10n.csvInvalidSpoolWeightError;
      case CsvImportErrorCode.invalidRemainingWeight:
        return l10n.csvInvalidRemainingWeightError;
      case CsvImportErrorCode.requiredCost:
        return l10n.csvCostPositiveError;
      case CsvImportErrorCode.invalidCost:
        return l10n.csvInvalidCostError;
      case CsvImportErrorCode.invalidTrackRemaining:
        return l10n.csvInvalidTrackRemainingError;
      case CsvImportErrorCode.invalidArchived:
        return l10n.csvInvalidArchivedError;
      case CsvImportErrorCode.invalidHeader:
        return l10n.csvInvalidHeaderError;
      case CsvImportErrorCode.malformedCsv:
        return l10n.csvMalformedError;
    }
  }
}

class CsvImportResultView extends StatelessWidget {
  const CsvImportResultView({
    super.key,
    required this.result,
    required this.l10n,
    required this.onReturn,
  });

  final CsvImportResult result;
  final AppLocalizations l10n;
  final VoidCallback onReturn;

  @override
  Widget build(BuildContext context) {
    final skipped =
        result.preValidatedFailures +
        result.skippedRows.length +
        result.saveFailures.length;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(kAppSpace16),
      child: AppSurfaceCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.csvImportResultTitle,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: TEXT_PRIMARY),
            ),
            const SizedBox(height: kAppSpace16),
            Text(
              l10n.csvImportResultUpdated(result.updated),
              style: const TextStyle(color: TEXT_SECONDARY),
            ),
            const SizedBox(height: kAppSpace8),
            Text(
              l10n.csvImportResultCreated(result.created),
              style: const TextStyle(color: TEXT_SECONDARY),
            ),
            const SizedBox(height: kAppSpace8),
            Text(
              l10n.csvImportResultSkipped(skipped),
              style: const TextStyle(color: TEXT_SECONDARY),
            ),
            const SizedBox(height: kAppSpace16),
            SizedBox(
              width: double.infinity,
              child: AppPrimaryButton(
                key: const ValueKey<String>('csv_import.return.button'),
                onPressed: onReturn,
                label: l10n.csvImportReturnButton,
                icon: const Icon(Icons.arrow_back),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
