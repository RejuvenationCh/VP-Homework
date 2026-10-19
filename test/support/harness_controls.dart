import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_cleaner/dev/harness_control_panel.dart';

Finder panelControl(Finder control) =>
    find.descendant(of: find.byType(HarnessControlPanel), matching: control);

Future<void> revealPanel(WidgetTester tester, Finder control) async {
  final target = panelControl(control);
  final scrollable = panelControl(find.byType(Scrollable)).first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(target, 180, scrollable: scrollable);
  await tester.ensureVisible(target);
  await tester.pumpAndSettle();
}

Future<void> tapPanel(WidgetTester tester, Finder control) async {
  await revealPanel(tester, control);
  await tester.tap(panelControl(control));
  await tester.pumpAndSettle();
}

Future<void> revealLibraryGame(WidgetTester tester, Finder game) async {
  final scrollable = find
      .descendant(
        of: find.byType(CustomScrollView),
        matching: find.byType(Scrollable),
      )
      .first;
  await tester.scrollUntilVisible(game, 400, scrollable: scrollable);
}
