import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_cleaner/main.dart';
import 'package:media_cleaner/dev/responsive_fixtures.dart';
import 'package:media_cleaner/features/media_cleaner/presentation/storage_overview_screen.dart';
import 'package:media_cleaner/features/media_cleaner/presentation/media_cleaner_screen.dart';

void main() {
  testWidgets('small phone can select a file without overflowing', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
    await tester.scrollUntilVisible(find.text('Review large files'), 250);
    await tester.ensureVisible(find.text('Review large files'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Review large files'));
    await tester.pumpAndSettle();
    expect(find.byType(MediaCleanerScreen), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.tap(find.text('C0012.MP4'));
    await tester.pumpAndSettle();
    expect(find.text('Delete'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('equal-sized folder bubbles stay inside the map', (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      MyApp(home: StorageOverviewScreen(items: DemoData.big.items)),
    );
    await tester.pumpAndSettle();
    final map = find.byWidgetPredicate(
      (widget) =>
          widget is SizedBox && widget.width == 288 && widget.height == 288,
    );
    final bounds = tester.getRect(map);
    final bubbles = find.byWidgetPredicate((widget) {
      if (widget is! Tooltip) return false;
      final message = widget.message;
      if (message == null) return false;
      return message.contains(' · ');
    });
    expect(bubbles, findsNWidgets(5));
    for (final bubble in bubbles.evaluate()) {
      final rect = tester.getRect(find.byWidget(bubble.widget));
      expect(bounds.contains(rect.topLeft), isTrue);
      expect(bounds.contains(rect.bottomRight), isTrue);
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('restoring files updates the overview after going back', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(430, 932);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const MyApp(home: StorageOverviewScreen(items: [])),
    );
    await tester.tap(find.text('Review large files'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Restore demo files'));
    await tester.pumpAndSettle();
    expect(find.text('C0012.MP4'), findsOneWidget);
    await tester.tap(find.byTooltip('Back'));
    await tester.pumpAndSettle();
    expect(find.text('16.0 GB free'), findsOneWidget);
    expect(find.widgetWithText(ListTile, 'DCIM'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
