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
