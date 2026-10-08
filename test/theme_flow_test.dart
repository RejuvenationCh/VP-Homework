import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_cleaner/main.dart';

void main() {
  testWidgets('folder navigation keeps cleanup totals and the shared theme', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.theme!.colorScheme.primary, const Color(0xFF3555B8));
    expect(app.theme!.textTheme.bodyMedium!.fontFamily, 'SourceSans3');
    expect(find.text('16.0 GB free'), findsOneWidget);

    final folder = find.widgetWithText(ListTile, 'DCIM');
    await tester.ensureVisible(folder);
    await tester.tap(folder);
    await tester.pumpAndSettle();
    expect(find.text('C0012.MP4'), findsOneWidget);
    expect(find.text('Rec_0921.mp4'), findsNothing);

    await tester.tap(find.text('C0012.MP4'));
    await tester.pump();
    expect(tester.widget<Checkbox>(find.byType(Checkbox).first).value, isTrue);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    expect(find.text('Delete'), findsNothing);
    await tester.tap(find.byType(Checkbox).first);
    await tester.pump();
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(find.text('C0012.MP4'), findsNothing);
    expect(find.text('108.2 GB of 128.0 GB used'), findsOneWidget);

    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('19.8 GB free'), -250);
    expect(find.text('19.8 GB free'), findsOneWidget);
    await tester.ensureVisible(folder);
    await tester.tap(folder);
    await tester.pumpAndSettle();
    expect(find.text('C0012.MP4'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
