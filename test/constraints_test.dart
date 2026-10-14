import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_cleaner/dev/constraint_scenario.dart';
import 'package:media_cleaner/dev/device_harness.dart';
import 'package:media_cleaner/dev/responsive_fixtures.dart';
import 'package:media_cleaner/features/media_cleaner/presentation/media_cleaner_screen.dart';
import 'package:media_cleaner/main.dart';

void main() {
  const capture = bool.fromEnvironment('CAPTURE_CONSTRAINTS');

  for (final example in ConstraintCase.values) {
    for (final fixed in [false, true]) {
      testWidgets('${example.name}: ${fixed ? 'fixed' : 'overflow'}', (
        tester,
      ) async {
        tester.view.physicalSize = const Size(320, 568);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        if (capture) {
          for (final weight in ['Regular', 'Semibold', 'Bold']) {
            await (FontLoader('SourceSans3')..addFont(
                  rootBundle.load(
                    'assets/fonts/source_sans_3/SourceSans3-$weight.otf',
                  ),
                ))
                .load();
          }
          await (FontLoader('MaterialIcons')
                ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf')))
              .load();
        }
        final errors = <String>[];
        final original = FlutterError.onError!;
        FlutterError.onError = (details) {
          errors.add(details.toString());
          original(details);
        };
        await tester.pumpWidget(
          RepaintBoundary(
            key: const Key('capture'),
            child: MyApp(
              home: MediaCleanerScreen(
                items: example == ConstraintCase.longName
                    ? DemoData.longName.items
                    : DemoData.normal.items,
                constraint: example,
                showConstraintError: !fixed,
              ),
            ),
          ),
        );
        await tester.pump();
        final exception = tester.takeException();
        FlutterError.onError = original;
        if (fixed) {
          expect(exception, isNull);
          expect(errors, isEmpty);
        } else {
          expect(exception, isNotNull);
          expect(errors, isNotEmpty);
          expect(
            errors.every((error) => error.contains('A RenderFlex overflowed')),
            isTrue,
          );
          expect(
            errors.first,
            contains(
              example == ConstraintCase.shortTile
                  ? 'on the bottom'
                  : 'on the right',
            ),
          );
        }
        if (capture) {
          final boundary = tester.renderObject<RenderRepaintBoundary>(
            find.byKey(const Key('capture')),
          );
          await tester.runAsync(() async {
            final directory = Directory('docs/week04/screenshots');
            await directory.create(recursive: true);
            final name = '${example.name}-${fixed ? 'fixed' : 'overflow'}';
            final screenshot = await boundary.toImage();
            final bytes = await screenshot.toByteData(
              format: ui.ImageByteFormat.png,
            );
            await File('${directory.path}/$name.png')
                .writeAsBytes(bytes!.buffer.asUint8List());
            screenshot.dispose();
            if (!fixed) {
              await File('${directory.path}/${example.name}-error.txt')
                  .writeAsString(errors.first);
            }
          });
        }
      });
    }
  }

  testWidgets(
    'H2 panel changes the real file manager and preserves selection',
    (tester) async {
      tester.view.physicalSize = const Size(1200, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(const DeviceHarness());
      for (final example in ConstraintCase.values) {
        tester
            .state<ScrollableState>(find.byType(Scrollable).first)
            .position
            .jumpTo(0);
        await tester.pumpAndSettle();
        await revealPanel(tester, find.text(example.label));
        await tester.pumpAndSettle();
        await tester.tap(find.text(example.label));
        await tester.pumpAndSettle();
        final screen = tester.widget<MediaCleanerScreen>(
          find.byType(MediaCleanerScreen),
        );
        expect(screen.constraint, example);
        expect(screen.showConstraintError, isFalse);
        expect(find.text('Media Cleaner'), findsOneWidget);
        expect(tester.takeException(), isNull);
        for (final device in DemoDevice.values) {
          await revealPanel(tester, find.text(device.label));
          await tester.pumpAndSettle();
          await tester.tap(find.text(device.label));
          await tester.pumpAndSettle();
          for (final landscape in [false, true]) {
            await revealPanel(
              tester,
              find.text(landscape ? 'Landscape' : 'Portrait'),
            );
            await tester.pumpAndSettle();
            await tester.tap(find.text(landscape ? 'Landscape' : 'Portrait'));
            await tester.pumpAndSettle();
            final context = tester.element(find.byType(MediaCleanerScreen));
            expect(
              MediaQuery.sizeOf(context),
              landscape ? device.size.flipped : device.size,
            );
            expect(
              tester
                  .widget<MediaCleanerScreen>(find.byType(MediaCleanerScreen))
                  .constraint,
              example,
            );
            if (example == ConstraintCase.actionRow) {
              expect(find.text('Delete'), findsOneWidget);
            }
            expect(tester.takeException(), isNull);
          }
        }
        await revealPanel(tester, find.text('Small phone'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Small phone'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Portrait'));
        await tester.pumpAndSettle();
        await revealPanel(tester, find.text('Show fix'));
        await tester.pumpAndSettle();
        final errors = <String>[];
        final original = FlutterError.onError!;
        FlutterError.onError = (details) => errors.add(details.toString());
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        FlutterError.onError = original;
        expect(errors, isNotEmpty);
        expect(
          errors.every((error) => error.contains('A RenderFlex overflowed')),
          isTrue,
        );
        expect(
          tester
              .widget<MediaCleanerScreen>(find.byType(MediaCleanerScreen))
              .showConstraintError,
          isTrue,
        );
        await tester.tap(find.byType(Switch));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull);
      }
      tester
          .state<ScrollableState>(find.byType(Scrollable).first)
          .position
          .jumpTo(0);
      await tester.pumpAndSettle();
      await tester.tap(find.text('Off'));
      await tester.pumpAndSettle();
      expect(
        tester
            .widget<MediaCleanerScreen>(find.byType(MediaCleanerScreen))
            .constraint,
        isNull,
      );
      expect(find.text('Delete'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );
}

Future<void> revealPanel(WidgetTester tester, Finder control) async {
  final scrollable = find.byType(Scrollable).first;
  tester.state<ScrollableState>(scrollable).position.jumpTo(0);
  await tester.pumpAndSettle();
  await tester.scrollUntilVisible(control, 180, scrollable: scrollable);
}
