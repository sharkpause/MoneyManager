import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:money_manager/app.dart';
import 'package:money_manager/core/formatters/rupiah_formatter.dart';

void main() {
  group('RupiahFormatter', () {
    test('formats zero, positive, and negative whole Rupiah values', () {
      expect(RupiahFormatter.format(0), 'Rp 0');
      expect(RupiahFormatter.format(150000), 'Rp 150.000');
      expect(RupiahFormatter.format(-50000), '-Rp 50.000');
      expect(RupiahFormatter.format(12500000), 'Rp 12.500.000');
    });
  });

  group('MoneyManagerApp adaptive shell', () {
    testWidgets('uses NavigationBar on compact width (< 600px)', (tester) async {
      tester.view.physicalSize = const Size(400, 800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MoneyManagerApp());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationBar), findsOneWidget);
      expect(find.byType(NavigationRail), findsNothing);
      expect(find.text('Rp 0'), findsOneWidget);
    });

    testWidgets('uses NavigationRail on expanded width (>= 600px)', (tester) async {
      tester.view.physicalSize = const Size(900, 700);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(MoneyManagerApp());
      await tester.pumpAndSettle();

      expect(find.byType(NavigationRail), findsOneWidget);
      expect(find.byType(NavigationBar), findsNothing);
      expect(find.text('Rp 0'), findsOneWidget);
    });
  });
}
