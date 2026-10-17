import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> revealPanel(WidgetTester tester, Finder control) async {
  final scrollable = find.byType(Scrollable).first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(control, 180, scrollable: scrollable);
}
