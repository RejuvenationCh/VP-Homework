# Project structure

The project keeps the runnable app small and groups game-library code by feature. The original Media Cleaner demos remain available for the H2 coursework examples.

| Path | Purpose |
| --- | --- |
| `lib/main.dart` | Normal app entry point, theme selection, and shared game storage. |
| `lib/app_theme.dart` | Shared Material theme, colors, and typography. |
| `lib/game_status_theme.dart` | Central light and dark status palette, supplied through the app theme. |
| `lib/features/game_library/models/` | Game, Steam profile, and achievement data types. |
| `lib/features/game_library/data/` | SQLite/Drift database, migration from preferences, serialization, sample data, and Steam Worker client. |
| `lib/features/game_library/presentation/` | Overview, Library, Settings, details, forms, notes, and achievement screens/widgets. |
| `lib/dev/` | Emulator controls, H2 fixtures, and development-only screens. |
| `lib/dev/media_demos/` | Retained Media Cleaner overview and file-manager examples used by H2. |
| `workers/steam-guides/` | Cloudflare Worker routes for profile resolution, games, achievements, and guide lookup. The Steam API key stays in Worker configuration. |
| `web/drift_worker.js`, `web/sqlite3.wasm` | Drift's SQLite runtime for Flutter web. Browser data is stored per origin. |
| `docs/api/` | Contracts for the Worker endpoints. |
| `docs/week02/` to `docs/week05/` | Coursework design, constraints, architecture, and reflection records. |

The normal app passes one shared `GameLibraryStorage` into the screens that read or update data. That storage owns the Drift database and migrates existing preference-backed games and achievement notes in one transaction without deleting the source values. Library edits merge changed fields with the latest saved games. Conflicting edits are rejected, and achievement notes and tracking are saved separately from refreshed Steam progress. Emulator fixtures can omit persistent storage, which keeps development scenarios separate from the normal user's library.

The Worker is a separate service. Flutter sends the selected public profile to the configured Worker, and the Worker calls Steam with its server-side API key. No app account or cloud sync is included. Settings saves an HTTPS service URL in SQLite; this takes priority over `STEAM_GUIDE_API_BASE_URL`. Debug builds can use loopback by default. Release builds require a configured HTTPS service. Cached achievements carry a warning when refresh fails. Steam artwork URLs are resolved from the game app ID, with custom artwork taking priority.
