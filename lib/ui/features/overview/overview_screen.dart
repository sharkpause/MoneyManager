import 'package:flutter/material.dart';

import '../../../core/constants/layout_breakpoints.dart';
import 'overview_compact_view.dart';
import 'overview_expanded_view.dart';
import 'overview_view_model.dart';

/// Adaptive entry point for the Overview feature sharing one [OverviewViewModel].
class OverviewScreen extends StatefulWidget {
  const OverviewScreen({super.key});

  @override
  State<OverviewScreen> createState() => _OverviewScreenState();
}

class _OverviewScreenState extends State<OverviewScreen> {
  final _viewModel = OverviewViewModel();

  @override
  void dispose() {
    _viewModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Money Manager')),
      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth >= LayoutBreakpoints.expandedWidth) {
            return OverviewExpandedView(viewModel: _viewModel);
          }
          return OverviewCompactView(viewModel: _viewModel);
        },
      ),
    );
  }
}
