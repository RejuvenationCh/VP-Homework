export async function readGameGenres(request, env, jsonResponse, rateLimit) {
  if (request.method !== 'GET') {
    return jsonResponse({ error: 'method_not_allowed' }, 405);
  }
  const parameters = new URL(request.url).searchParams;
  const value = parameters.get('app_ids');
  if (
    parameters.getAll('app_ids').length !== 1 ||
    value === null ||
    !/^[1-9][0-9]{0,9}(,[1-9][0-9]{0,9}){0,9}$/.test(value)
  ) {
    return jsonResponse({ error: 'invalid_request' }, 400);
  }
  const appIds = value.split(',').map(Number);
  if (
    new Set(appIds).size !== appIds.length ||
    appIds.some((id) => id > 4294967295)
  ) {
    return jsonResponse({ error: 'invalid_request' }, 400);
  }
  const limited = await rateLimit(request, env);
  if (limited !== null) return limited;

  const games = [];
  for (let offset = 0; offset < appIds.length; offset += 5) {
    const group = appIds.slice(offset, offset + 5);
    const results = await Promise.all(
      group.map(async (appId) => ({
        app_id: appId,
        primary_genre: await readGenre(request.url, appId),
      })),
    );
    games.push(...results);
  }
  return jsonResponse({ games }, 200);
}

async function readGenre(requestUrl, appId) {
  const cacheKey = new Request(
    new URL(`/v1/steam/games/genres/cache/${appId}`, requestUrl),
  );
  let cache;
  try {
    cache = caches.default;
    const cached = await cache.match(cacheKey);
    if (cached !== undefined) {
      const data = await cached.json();
      if (data.primary_genre === null || validGenre(data.primary_genre)) {
        return data.primary_genre;
      }
    }
  } catch (error) {
    // Cache errors should not stop an import.
  }

  const url = new URL('https://store.steampowered.com/api/appdetails');
  url.searchParams.set('appids', String(appId));
  url.searchParams.set('filters', 'genres');
  url.searchParams.set('l', 'english');
  let primaryGenre = null;
  try {
    const response = await fetch(url, {
      headers: { Accept: 'application/json' },
      redirect: 'manual',
      signal: AbortSignal.timeout(8000),
    });
    if (!response.ok) return null;
    const body = await response.json();
    const entry = body[String(appId)];
    if (entry === null || typeof entry !== 'object' || entry.success !== true) {
      return null;
    }
    if (
      entry.data === null || typeof entry.data !== 'object' ||
      Array.isArray(entry.data)
    ) return null;
    const genres = entry.data.genres;
    if (genres !== undefined && !Array.isArray(genres)) return null;
    if (Array.isArray(genres)) {
      for (const genre of genres) {
        if (genre !== null && validGenre(genre.description)) {
          primaryGenre = genre.description.trim();
          break;
        }
      }
    }
  } catch (error) {
    return null;
  }
  if (cache !== undefined) {
    try {
      await cache.put(
        cacheKey,
        new Response(JSON.stringify({ primary_genre: primaryGenre }), {
          headers: {
            'Content-Type': 'application/json; charset=utf-8',
            'Cache-Control': 'public, max-age=86400',
          },
        }),
      );
    } catch (error) {
      // The Store result is still usable without caching.
    }
  }
  return primaryGenre;
}

function validGenre(value) {
  return typeof value === 'string' && value.trim().length > 0 &&
    value.trim().length <= 80;
}
