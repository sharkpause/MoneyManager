import 'package:flutter/material.dart';

import '../../../core/formatters/rupiah_formatter.dart';
import 'overview_view_model.dart';

/// Compact (< 600px) layout for the Overview screen.
class OverviewCompactView extends StatelessWidget {
  const OverviewCompactView({
    super.key,
    required this.viewModel,
  });

  final OverviewViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Net Worth',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      RupiahFormatter.format(viewModel.netWorthRp),
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
