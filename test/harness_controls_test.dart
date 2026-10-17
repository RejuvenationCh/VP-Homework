import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_cleaner/dev/device_harness.dart';
import 'package:media_cleaner/features/media_cleaner/presentation/media_cleaner_screen.dart';

import 'support/harness_controls.dart';

void main() {
  testWidgets('harness controls change frame, data, theme and screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DeviceHarness());
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Small phone'))
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Tablet'))
          .selected,
      isFalse,
    );
    await tester.tap(find.text('Tablet'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Tablet'))
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Small phone'))
          .selected,
      isFalse,
    );
    expect(find.byKey(const Key('overview-wide-layout')), findsOneWidget);
    await tester.tap(find.text('File manager'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('files-wide-layout')), findsOneWidget);
    await revealPanel(tester, find.text('Zero items'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zero items'));
    await tester.pumpAndSettle();
    expect(find.text('Restore demo files'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Zero items'))
          .selected,
      isTrue,
    );
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Normal'))
          .selected,
      isFalse,
    );
    await revealPanel(tester, find.text('Dark mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark mode'));
    await tester.pumpAndSettle();
    final inner = tester.element(find.byType(MediaCleanerScreen));
    expect(Theme.of(inner).brightness, Brightness.dark);
    expect(MediaQuery.sizeOf(inner), const Size(800, 1280));
    await revealPanel(tester, find.text('Keyboard open'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Keyboard open'));
    await tester.pumpAndSettle();
    expect(MediaQuery.viewInsetsOf(inner).bottom, 260);
    await revealPanel(tester, find.text('Landscape'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Landscape'));
    await tester.pumpAndSettle();
    expect(MediaQuery.sizeOf(inner), const Size(1280, 800));
    expect(MediaQuery.viewInsetsOf(inner).bottom, 180);
    expect(tester.takeException(), isNull);
  });
}
