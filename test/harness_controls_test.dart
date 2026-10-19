import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:media_cleaner/dev/device_harness.dart';
import 'package:media_cleaner/dev/media_demos/media_cleaner_screen.dart';
import 'package:media_cleaner/features/game_library/models/game.dart';
import 'package:media_cleaner/features/game_library/presentation/game_artwork.dart';
import 'package:media_cleaner/features/game_library/presentation/game_library_screen.dart';

import 'support/harness_controls.dart';

void main() {
  testWidgets('library rows show artwork with loading and missing fallbacks', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: GameLibraryScreen(
          loadGames: () async => const [
            Game(
              id: 'sample-art',
              name: 'Art game',
              primaryGenre: 'Shooter',
              platform: 'PC',
              status: GameStatus.backlog,
              artworkUrl: 'https://art.example/game.jpg',
            ),
            Game(
              id: 'manual-no-art',
              name: 'Manual game',
              primaryGenre: 'Unsorted',
              platform: 'Unspecified',
              status: GameStatus.backlog,
            ),
          ],
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(GameArtwork), findsNWidgets(2));
    expect(find.byIcon(Icons.videogame_asset_outlined), findsNWidgets(2));

    final image = tester.widget<Image>(
      find.descendant(
        of: find.byType(GameArtwork).first,
        matching: find.byType(Image),
      ),
    );
    expect(image.loadingBuilder, isNotNull);
    expect(image.errorBuilder, isNotNull);

    final context = tester.element(find.byType(GameArtwork).first);
    final loadingWidget = image.loadingBuilder!(
      context,
      const SizedBox.shrink(),
      const ImageChunkEvent(cumulativeBytesLoaded: 1, expectedTotalBytes: 2),
    );
    final errorWidget = image.errorBuilder!(
      context,
      StateError('Image failed'),
      StackTrace.current,
    );
    await tester.pumpWidget(MaterialApp(home: loadingWidget));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpWidget(MaterialApp(home: errorWidget));
    expect(find.byIcon(Icons.videogame_asset_outlined), findsOneWidget);
  });

  testWidgets('harness controls change frame, data, theme and screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DeviceHarness());
    await tester.pumpAndSettle();
    expect(find.text('No games yet'), findsOneWidget);
    await tester.tap(find.text('Load sample games'));
    await tester.pumpAndSettle();
    await revealLibraryGame(tester, find.text('PAYDAY 2'));
    expect(find.text('PAYDAY 2'), findsOneWidget);
    expect(
      tester
          .widget<ChoiceChip>(find.widgetWithText(ChoiceChip, 'Library'))
          .selected,
      isTrue,
    );
    await tester.tap(find.text('Storage overview'));
    await tester.pumpAndSettle();
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

  testWidgets('retry demo fails once, recovers, and resets', (tester) async {
    tester.view.physicalSize = const Size(1200, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const DeviceHarness());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Retry demo'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load games'), findsOneWidget);
    expect(find.text('No games yet'), findsNothing);
    expect(find.text('PAYDAY 2'), findsNothing);
    await revealPanel(tester, find.text('Dark mode'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Dark mode'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load games'), findsOneWidget);
    expect(
      Theme.of(tester.element(find.text('Could not load games'))).brightness,
      Brightness.dark,
    );
    await tester.tap(find.text('Retry'));
    await tester.pumpAndSettle();
    await revealLibraryGame(tester, find.text('PAYDAY 2'));
    expect(find.text('PAYDAY 2'), findsOneWidget);
    expect(find.text('Could not load games'), findsNothing);
    await revealPanel(tester, find.text('Reset demo'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Reset demo'));
    await tester.pumpAndSettle();
    expect(find.text('Could not load games'), findsOneWidget);
    await revealPanel(tester, find.text('Library'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Library'));
    await tester.pumpAndSettle();
    expect(find.text('No games yet'), findsOneWidget);
    expect(find.text('PAYDAY 2'), findsNothing);
    expect(find.text('Could not load games'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
