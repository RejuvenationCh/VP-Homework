import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_cleaner/main.dart';
import 'package:media_cleaner/dev/responsive_fixtures.dart';
import 'package:media_cleaner/dev/media_demos/storage_overview_screen.dart';
import 'package:media_cleaner/features/media_cleaner/presentation/widgets/media_tile.dart';
import 'package:media_cleaner/dev/media_demos/media_cleaner_screen.dart';

import 'package:media_cleaner/dev/demo_device.dart';

void main() {
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
}
