# Steam Worker setup

A standard Steam Web API user key can be registered at https://steamcommunity.com/dev/apikey. Steam requires an account, an associated domain, and agreement to its API terms. This Worker uses the public `api.steampowered.com` host with that user key. The key belongs in the Worker secret named `STEAM_API_KEY`. Keep it out of Flutter, source files, responses, and logs.

For local development, create `workers/steam-guides/.dev.vars` with:

```dotenv
STEAM_API_KEY="your-local-key"
```

The `.dev.vars` file is ignored by Git. Wrangler exposes the value to Worker code as `env.STEAM_API_KEY`.

The Worker is deployed at `https://game-backlog-steam-guides.steam-guides.workers.dev`. Its Steam key is stored as the Cloudflare secret `STEAM_API_KEY`. To rotate it, run `npx wrangler@4 secret put STEAM_API_KEY` from this directory. Do not add the key to Git or Flutter.

The app uses the hosted Worker automatically. Developers can override it at build time with `STEAM_GUIDE_API_BASE_URL`. A phone cannot reach the computer's Worker through `127.0.0.1`. Keep the local command for Chrome development. Worker requests to Steam stop after eight seconds so the app can show an unavailable response instead of waiting indefinitely.

The guide lookup does not call the Steam Web API and needs no key. Vanity profile resolution and owned-game/playtime reads use `STEAM_API_KEY` on the Worker. The game-read route returns only public data. It reports private profiles and incomplete or unavailable Steam responses separately. A complete zero-game response means there are no visible entries, not proof of account ownership.

To rebuild the Android APK with the deployed service as its default:

```bash
flutter build apk --release --dart-define=STEAM_GUIDE_API_BASE_URL=https://game-backlog-steam-guides.steam-guides.workers.dev
```

Run the build command from the repository root. The hosted address is also the source default, so `flutter build apk --release` works without a URL flag.

Genre lookup is `GET /v1/steam/games/genres?app_ids=105600,1293830`. It accepts up to ten distinct app IDs, reads English Steam Store genres from a fixed host, and caches successful metadata for one day. Missing Store data returns null for that entry. The endpoint shares the existing rate limit and needs no Steam key. See `docs/api/steam-game-genres.yaml` from the repository root.
