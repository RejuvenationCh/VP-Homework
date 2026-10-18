import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_cleaner/dev/constraint_scenario.dart';
import 'package:media_cleaner/dev/responsive_fixtures.dart';
import 'package:media_cleaner/dev/media_demos/media_cleaner_screen.dart';
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
}
