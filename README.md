# Media Cleaner

Flutter coursework app with a storage overview and a file manager.
Files are mock data. Delete and Offload remove them from memory until the app restarts.

## Normal mode

```sh
flutter run
```

This uses `lib/main.dart`. To run it in Chrome:

```sh
flutter run -d chrome
```

## Emulator mode

Runs the app inside a phone or tablet frame, adapted from lab04.

```sh
flutter run -d chrome -t lib/main_emulator.dart
```

Controls:

- Screen: storage overview or file manager
- Width: 320, 430, or 800 dp
- Orientation: portrait or landscape
- Data: normal, 200-character filename, zero items, or 500 items
- Keyboard overlay, dark mode, and notch/gesture bar
- Reset demo

The keyboard toggle simulates the space taken up by a keyboard.
Rotation and theme changes keep the current preview state.

## Emulator

List the available emulators, launch one, then run the app:

```sh
flutter emulators
flutter emulators --launch <emulator-id>
flutter devices
flutter run -d <device-id>
```

## H2 constraints

Run emulator mode, then choose a case under H2 errors on the file manager:

- Filename width: removes the width limit from a real file tile's name
- Tile height: reduces the real grid cells to 64 dp
- Selection bar: forces the selection summary and buttons onto one row

Turn Show fix off to see the error, then on to restore the layout. These
controls change the actual file-manager screen. You can change size and
orientation while comparing. Off clears the H2 case.

Use debug mode to see the overflow markers.

Screenshots, explanations, and fixes: [constraints.md](docs/week04/constraints.md).

## H1 responsive checks

Results and fixes: [responsive-matrix.md](docs/week04/responsive-matrix.md).
