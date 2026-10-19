# Steam Worker setup

The Steam API key belongs in the Worker secret named `STEAM_API_KEY`. Keep it out of Flutter, source files, responses, and logs.

For local development, create `workers/steam-guides/.dev.vars` with:

```dotenv
STEAM_API_KEY="your-local-key"
```

The `.dev.vars` file is ignored by Git. Wrangler exposes the value to Worker code as `env.STEAM_API_KEY`.

To add the secret to a Cloudflare Worker later, run `npx wrangler@4 secret put STEAM_API_KEY` from this directory. This repository has not set a Cloudflare secret or deployed the Worker.

The current guide lookup does not call the Steam Web API. It does not need this key to run locally.
