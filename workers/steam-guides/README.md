# Steam Worker setup

A standard Steam Web API user key can be registered at https://steamcommunity.com/dev/apikey. Steam requires an account, an associated domain, and agreement to its API terms. This Worker uses the public `api.steampowered.com` host with that user key. The key belongs in the Worker secret named `STEAM_API_KEY`. Keep it out of Flutter, source files, responses, and logs.

For local development, create `workers/steam-guides/.dev.vars` with:

```dotenv
STEAM_API_KEY="your-local-key"
```

The `.dev.vars` file is ignored by Git. Wrangler exposes the value to Worker code as `env.STEAM_API_KEY`.

To add the secret to a Cloudflare Worker later, run `npx wrangler@4 secret put STEAM_API_KEY` from this directory. This repository has not set a Cloudflare secret or deployed the Worker.

The guide lookup does not call the Steam Web API and needs no key. Vanity profile resolution and owned-game/playtime reads use `STEAM_API_KEY` on the Worker. The game-read route returns only public data. It reports private profiles and incomplete or unavailable Steam responses separately. A complete zero-game response means there are no visible entries, not proof of account ownership.
