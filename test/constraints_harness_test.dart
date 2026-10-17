import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_cleaner/dev/constraint_scenario.dart';
import 'package:media_cleaner/dev/demo_device.dart';
import 'package:media_cleaner/dev/device_harness.dart';
import 'package:media_cleaner/features/media_cleaner/presentation/media_cleaner_screen.dart';

import 'support/harness_controls.dart';

void main() {
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
        expect(find.text('Media files (previous)'), findsOneWidget);
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
