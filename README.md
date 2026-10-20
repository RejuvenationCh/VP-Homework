# Game Backlog

Game Backlog is a Flutter coursework app for organizing a personal game library and working toward Steam achievements. Local game details, ratings, favorites, achievement tracking, and notes are stored with SQLite through Drift. A public Steam profile can be selected in Settings to import visible games and read achievement progress on demand.

## Features

- Overview with genre bubbles and library counts
- Library search, filters, sorting, favorites, and game details
- Automatic Steam covers, with an optional cover URL for manual games
- Personal status, rating, play-next, and notes for each game
- Steam profile import and playtime through the local Worker
- On-demand achievement definitions and unlock state, with tracking, notes, filters, and guide links
- Dark, light, and system appearance
- Development emulator and retained H2 media demonstrations

## Requirements

- Flutter SDK with Dart 3.13.3 or a compatible newer version
- Chrome for the web version, or an Android device/emulator for Android
- For Steam profile import: Node.js/npm, a Steam Web API key, and the local Cloudflare Worker

## Run the app

```sh
flutter pub get
flutter run
```

For Chrome:

```sh
flutter run -d chrome
```

## Enable Steam import

Steam import needs the local Cloudflare Worker and a Steam Web API key. Keep the key in `workers/steam-guides/.dev.vars`; do not put it in Flutter code or the browser.

```sh
cd workers/steam-guides
npx wrangler@4 dev --ip 127.0.0.1 --port 8787
```

In a second terminal, run Flutter with the local Worker URL:

```sh
flutter run -d chrome --dart-define=STEAM_GUIDE_API_BASE_URL=http://127.0.0.1:8787
```

Open Settings, enter a public Steam profile URL, vanity name, or SteamID64, and select **Import / refresh games**. Imported games appear in Library. Open a game and choose **View achievements**. The app reads Steam when asked; changes are not live-pushed. The Worker has not been deployed. Public profile data does not verify account ownership.

Settings also has a **Steam service** URL. Save your hosted HTTPS Worker address there to use Steam on an Android device. Debug builds use the local Worker when no URL is saved. Release builds require a saved URL or the build setting above. Keep the API key on the Worker. A saved URL takes priority over the build setting; **Reset URL** restores the build default.

If Steam cannot refresh achievements, the app labels saved results and offers Retry. Game covers load automatically for existing Steam imports. Add or edit a manual game to enter its HTTPS cover image URL.

## Android release

```sh
flutter build apk --release
```

The APK is written to `build/app/outputs/flutter-apk/app-release.apk`. Configure a hosted Steam service in Settings after installing, or pass its HTTPS URL with `--dart-define=STEAM_GUIDE_API_BASE_URL=...` while building. The Worker still needs to be deployed separately.

On macOS, if `flutter test` crashes in `parseOtoolArchitectureSections`, use a checkout path without parentheses. Flutter's native-assets parser rejects paths such as `Data C (General)`.

## Screens

### Overview

![Overview screen](docs/screenshots/overview.png)

### Library

![Library screen](docs/screenshots/library.png)

### Game details

![Game details screen](docs/screenshots/details.png)

### Add or edit a game

![Add and edit game form](docs/screenshots/add-edit-game.png)

### Achievements

![Achievements screen](docs/screenshots/achievements.png)

### Achievement notes

![Achievement notes screen](docs/screenshots/notes.png)

### Settings

![Settings screen](docs/screenshots/settings.png)

## Coursework documents

- [Architecture](docs/structure.md)
- [Week 5 reflection](docs/week05/reflection.md)

Release APK: [download](releases/app-release.apk). This local build still needs a clean-device installation check. No GitHub release has been published.
