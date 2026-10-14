import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_cleaner/main.dart';
import 'package:media_cleaner/dev/device_harness.dart';
import 'package:media_cleaner/dev/responsive_fixtures.dart';
import 'package:media_cleaner/features/media_cleaner/presentation/storage_overview_screen.dart';
import 'package:media_cleaner/features/media_cleaner/presentation/widgets/media_tile.dart';
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

  for (final files in [false, true]) {
    for (final device in DemoDevice.values) {
      for (final landscape in [false, true]) {
        for (final data in DemoData.values) {
          for (final dark in [false, true]) {
            for (final keyboard in [false, true]) {
              final size = landscape ? device.size.flipped : device.size;
              testWidgets('${files ? 'files' : 'overview'} ${device.name} '
                  '${landscape ? 'landscape' : 'portrait'} ${data.name} '
                  '${dark ? 'dark' : 'light'} keyboard=$keyboard', (
                tester,
              ) async {
                tester.view.physicalSize = size;
                tester.view.devicePixelRatio = 1;
                addTearDown(tester.view.resetPhysicalSize);
                addTearDown(tester.view.resetDevicePixelRatio);
                final inset = keyboard ? (landscape ? 180.0 : 260.0) : 0.0;
                final padding = landscape
                    ? const EdgeInsets.only(left: 32, bottom: 20)
                    : const EdgeInsets.only(top: 32, bottom: 20);
                await tester.pumpWidget(
                  MyApp(
                    themeMode: dark ? ThemeMode.dark : ThemeMode.light,
                    builder: (context, child) => MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        size: size,
                        padding: keyboard
                            ? padding.copyWith(bottom: 0)
                            : padding,
                        viewPadding: padding,
                        viewInsets: EdgeInsets.only(bottom: inset),
                      ),
                      child: child!,
                    ),
                    home: files
                        ? MediaCleanerScreen(items: data.items)
                        : StorageOverviewScreen(items: data.items),
                  ),
                );
                await tester.pumpAndSettle();
                expect(tester.takeException(), isNull);
                final screenContext = tester.element(
                  find.byType(
                    files ? MediaCleanerScreen : StorageOverviewScreen,
                  ),
                );
                expect(
                  Theme.of(screenContext).brightness,
                  dark ? Brightness.dark : Brightness.light,
                );
                final wideKey = files
                    ? 'files-wide-layout'
                    : 'overview-wide-layout';
                expect(
                  find.byKey(Key(wideKey)),
                  size.width - padding.left >= 700
                      ? findsOneWidget
                      : findsNothing,
                );

                if (data == DemoData.empty) {
                  final action = find.text('Restore demo files');
                  await tester.scrollUntilVisible(
                    action,
                    180,
                    scrollable: files
                        ? find
                              .descendant(
                                of: find.byKey(const Key('files-scroll')),
                                matching: find.byType(Scrollable),
                              )
                              .first
                        : find.byType(Scrollable).first,
                  );
                  await tester.ensureVisible(action);
                  await tester.pumpAndSettle();
                  await tester.tap(action);
                  await tester.pumpAndSettle();
                  expect(find.text('Restore demo files'), findsNothing);
                } else if (files) {
                  final tile = find.byWidgetPredicate(
                    (widget) =>
                        widget is MediaTile &&
                        widget.item.id == data.items.first.id,
                  );
                  await tester.scrollUntilVisible(
                    tile,
                    200,
                    scrollable: find
                        .descendant(
                          of: find.byKey(const Key('files-scroll')),
                          matching: find.byType(Scrollable),
                        )
                        .first,
                  );
                  await tester.ensureVisible(tile);
                  await tester.pumpAndSettle();
                  await tester.tap(tile);
                  await tester.pumpAndSettle();
                  expect(find.text('Delete'), findsOneWidget);
                  expect(tester.takeException(), isNull);
                  await tester.tap(find.text('Clear'));
                  await tester.pumpAndSettle();
                  if (data == DemoData.big) {
                    // Only viewport tiles are built, even with 500 items.
                    expect(
                      find.byType(MediaTile).evaluate().length,
                      lessThan(100),
                    );
                    final scroll = tester.state<ScrollableState>(
                      find
                          .descendant(
                            of: find.byKey(const Key('files-scroll')),
                            matching: find.byType(Scrollable),
                          )
                          .first,
                    );
                    scroll.position.jumpTo(scroll.position.maxScrollExtent);
                    await tester.pumpAndSettle();
                    expect(find.text('Media_499.jpg'), findsOneWidget);
                  }
                } else {
                  final action = find.text('Review large files');
                  await tester.scrollUntilVisible(
                    action,
                    180,
                    scrollable: find.byType(Scrollable).last,
                  );
                  await tester.ensureVisible(action);
                  await tester.pumpAndSettle();
                  expect(
                    tester.getRect(action).bottom,
                    lessThanOrEqualTo(size.height - inset),
                  );
                }
                expect(tester.takeException(), isNull);
              });
            }
          }
        }
      }
    }
  }

  testWidgets('harness controls change frame, data, theme and screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DeviceHarness());
    await tester.tap(find.text('Tablet'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('overview-wide-layout')), findsOneWidget);
    await tester.tap(find.text('File manager'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('files-wide-layout')), findsOneWidget);
    await revealPanel(tester, find.text('Zero items'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Zero items'));
    await tester.pumpAndSettle();
    expect(find.text('Restore demo files'), findsOneWidget);
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
    final bubbles = find.byWidgetPredicate(
      (widget) =>
          widget is Tooltip && (widget.message?.contains(' · ') ?? false),
    );
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

Future<void> revealPanel(WidgetTester tester, Finder control) async {
  final scrollable = find.byType(Scrollable).first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(control, 180, scrollable: scrollable);
}
