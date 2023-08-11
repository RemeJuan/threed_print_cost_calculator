import 'package:flutter/material.dart';
import 'package:flutter_form_bloc/flutter_form_bloc.dart';
import 'package:threed_print_cost_calculator/calculator/bloc/calculator_bloc.dart';
import 'package:threed_print_cost_calculator/calculator/helpers/calculator_helpers.dart';
import 'package:threed_print_cost_calculator/l10n/l10n.dart';

class PremiumWidgets extends StatelessWidget {
  const PremiumWidgets({required this.premium, super.key});

  final bool premium;

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<CalculatorBloc>();
    final l10n = context.l10n;

    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TextFieldBlocBuilder(
                textFieldBloc: bloc.labourRate,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.labourRateLabel,
                ),
                onChanged: (value) async {
                  bloc.submit();
                  await CalculatorHelpers.addOrUpdateRecord(
                    'labourRate',
                    value,
                  );
                },
                isEnabled: premium,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFieldBlocBuilder(
                textFieldBloc: bloc.labourTime,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.labourTimeLabel,
                ),
                onChanged: (_) => bloc.submit(),
                isEnabled: premium,
              ),
            ),
          ],
        ),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Expanded(
              child: TextFieldBlocBuilder(
                textFieldBloc: bloc.wearAndTear,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.wearAndTearLabel,
                ),
                onChanged: (value) async {
                  bloc.submit();
                  await CalculatorHelpers.addOrUpdateRecord(
                    'wearAndTear',
                    value,
                  );
                },
                isEnabled: premium,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFieldBlocBuilder(
                textFieldBloc: bloc.failureRisk,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: l10n.failureRiskLabel,
                ),
                onChanged: (value) async {
                  bloc.submit();
                  await CalculatorHelpers.addOrUpdateRecord(
                    'failureRisk',
                    value,
                  );
                },
                isEnabled: premium,
              ),
            ),
          ],
        ),
        const MaterialButton(
          onPressed: null,
          child: Text('Save Print'),
        ),
      ],
    );
  }
}
