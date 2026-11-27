import 'package:flutter/material.dart';

import '../../../core/formatters/rupiah_formatter.dart';
import 'overview_view_model.dart';

/// Expanded (>= 600px) multi-pane layout for the Overview screen.
class OverviewExpandedView extends StatelessWidget {
  const OverviewExpandedView({
    super.key,
    required this.viewModel,
  });

  final OverviewViewModel viewModel;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: viewModel,
      builder: (context, _) {
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
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
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Card(
                  child: Padding(
                    padding: EdgeInsets.all(20),
                    child: Text('Recent activity & obligations will appear here.'),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
