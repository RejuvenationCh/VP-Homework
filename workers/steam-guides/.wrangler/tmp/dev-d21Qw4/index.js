var __defProp = Object.defineProperty;
var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

// src/index.js
var steamCommunity = "https://steamcommunity.com";
var steamApi = "https://api.steampowered.com";
var steamProfilePath = "/v1/steam/profile/resolve";
var steamGuidePath = "/v1/steam/guides";
var steamOwnedGamesPath = /^\/v1\/steam\/profiles\/([^/]+)\/games$/;
var steamAchievementsPath = /^\/v1\/steam\/profiles\/([^/]+)\/games\/([^/]+)\/achievements$/;
var steamIdPattern = /^7656119[0-9]{10}$/;
var guideSearchMarker = "Results for";
var guideCardPattern = /<a\b(?=[^>]*class="[^"]*\bworkshopItemCollection\b)(?=[^>]*data-publishedfileid="[0-9]+")[^>]*>([\s\S]*?)<\/a>/g;
var guideTextPattern = /<div class="workshopItem(?:Title|ShortDesc)">([\s\S]*?)<\/div>/g;
var resultSummaryPattern = /Showing\s+([0-9,]+)-([0-9,]+)\s+of\s+([0-9,]+)\s+entries/i;
var namedHtmlEntities = {
  amp: "&",
  apos: "'",
  aacute: "\xE1",
  acirc: "\xE2",
  aelig: "\xE6",
  agrave: "\xE0",
  aring: "\xE5",
  atilde: "\xE3",
  auml: "\xE4",
  ccedil: "\xE7",
  eacute: "\xE9",
  ecirc: "\xEA",
  egrave: "\xE8",
  euml: "\xEB",
  gt: ">",
  iacute: "\xED",
  icirc: "\xEE",
  igrave: "\xEC",
  iuml: "\xEF",
  lt: "<",
  nbsp: " ",
  ntilde: "\xF1",
  oacute: "\xF3",
  ocirc: "\xF4",
  ograve: "\xF2",
  oelig: "\u0153",
  otilde: "\xF5",
  ouml: "\xF6",
  quot: '"',
  uacute: "\xFA",
  ucirc: "\xFB",
  ugrave: "\xF9",
  uml: "\xA8",
  uuml: "\xFC",
  yacute: "\xFD",
  yuml: "\xFF"
};
var src_default = {
  async fetch(request, env) {
    const requestUrl = new URL(request.url);
    const achievementsMatch = requestUrl.pathname.match(steamAchievementsPath);
    const ownedGamesMatch = requestUrl.pathname.match(steamOwnedGamesPath);
    if (request.method === "OPTIONS") {
      let allowedMethods = "GET, OPTIONS";
      if (requestUrl.pathname === steamProfilePath) {
        allowedMethods = "POST, OPTIONS";
      }
      return new Response(null, {
        status: 204,
        headers: corsHeaders(allowedMethods)
      });
    }
    if (requestUrl.pathname === steamProfilePath) {
      return resolveSteamProfile(request, env);
    }
    if (achievementsMatch !== null) {
      return readSteamAchievements(
        request,
        env,
        achievementsMatch[1],
        achievementsMatch[2]
      );
    }
    if (ownedGamesMatch !== null) {
      return readOwnedGames(request, env, ownedGamesMatch[1]);
    }
    if (requestUrl.pathname !== steamGuidePath) {
      return jsonResponse({ error: "not_found" }, 404);
    }
    if (request.method !== "GET") {
      return jsonResponse({ error: "method_not_allowed" }, 405);
    }
    const appId = requestUrl.searchParams.get("app_id");
    const searchText = requestUrl.searchParams.get("search_text");
    if (!isValidRequest(appId, searchText)) {
      return jsonResponse({ error: "invalid_request" }, 400);
    }
    const callerIp = request.headers.get("CF-Connecting-IP");
    const rateLimitKey = callerIp || "unknown";
    let rateLimit;
    try {
      rateLimit = await env.STEAM_GUIDE_RATE_LIMIT.limit({ key: rateLimitKey });
    } catch (error) {
      return jsonResponse({ error: "internal_error" }, 500);
    }
    if (!rateLimit.success) {
      return jsonResponse(
        { error: "rate_limited" },
        429,
        { "Retry-After": "60" }
      );
    }
    const guideUrl = buildGuideUrl(appId, searchText.trim());
    let steamResponse;
    try {
      steamResponse = await fetch(guideUrl, {
        headers: { Accept: "text/html" }
      });
    } catch (error) {
      return jsonResponse({ error: "steam_unavailable" }, 502);
    }
    if (steamResponse.status === 429) {
      return jsonResponse(
        { error: "rate_limited" },
        429,
        { "Retry-After": "60" }
      );
    }
    if (!steamResponse.ok) {
      return jsonResponse({ error: "steam_unavailable" }, 502);
    }
    let page;
    try {
      page = await steamResponse.text();
    } catch (error) {
      return jsonResponse({ error: "steam_unavailable" }, 502);
    }
    if (!page.includes(guideSearchMarker)) {
      return jsonResponse({ error: "steam_unavailable" }, 502);
    }
    const hasMatchingGuide = matchingGuideExists(page, searchText.trim());
    if (hasMatchingGuide === null) {
      return jsonResponse({ error: "steam_unavailable" }, 502);
    }
    if (!hasMatchingGuide) {
      return jsonResponse({ error: "guide_not_found" }, 404);
    }
    return jsonResponse({ found: true, guide_url: guideUrl.toString() }, 200);
  }
};
function isValidRequest(appId, searchText) {
  if (appId === null || !/^[1-9][0-9]{0,9}$/.test(appId)) {
    return false;
  }
  if (searchText === null) {
    return false;
  }
  const trimmed = searchText.trim();
  if (trimmed.length < 1 || trimmed.length > 120) {
    return false;
  }
  if (searchTokens(trimmed).length === 0) {
    return false;
  }
  return true;
}
__name(isValidRequest, "isValidRequest");
function buildGuideUrl(appId, searchText) {
  const url = new URL(`/app/${appId}/guides/`, steamCommunity);
  url.searchParams.set("browsefilter", "trend");
  url.searchParams.set("browsesort", "trend");
  url.searchParams.set("l", "english");
  url.searchParams.set("numperpage", "30");
  url.searchParams.set("searchText", searchText);
  return url;
}
__name(buildGuideUrl, "buildGuideUrl");
function matchingGuideExists(page, searchText) {
  const summary = page.match(resultSummaryPattern);
  const searchTerms = searchTokens(searchText);
  if (summary === null || searchTerms.length === 0) {
    return null;
  }
  const firstResult = Number.parseInt(summary[1].replaceAll(",", ""), 10);
  const lastResult = Number.parseInt(summary[2].replaceAll(",", ""), 10);
  const total = Number.parseInt(summary[3].replaceAll(",", ""), 10);
  const cards = [...page.matchAll(guideCardPattern)].slice(0, 30);
  if (total === 0) {
    if (firstResult === 0 && lastResult === 0 && cards.length === 0) {
      return false;
    }
    return null;
  }
  if (firstResult !== 1 || lastResult < firstResult || lastResult > total) {
    return null;
  }
  const expectedCards = Math.min(30, lastResult - firstResult + 1);
  if (expectedCards < 1 || cards.length !== expectedCards) {
    return null;
  }
  let hasUnreadableCard = false;
  for (const card of cards) {
    const sections = [...card[1].matchAll(guideTextPattern)];
    if (sections.length === 0) {
      hasUnreadableCard = true;
      continue;
    }
    const cardTerms = normalizeSearchTerms(
      sections.map((section) => section[1]).join(" ")
    );
    if (cardTerms === null) {
      hasUnreadableCard = true;
      continue;
    }
    if (searchTerms.every((term) => cardTerms.includes(term))) {
      return true;
    }
  }
  if (hasUnreadableCard) return null;
  return false;
}
__name(matchingGuideExists, "matchingGuideExists");
function normalizeSearchTerms(value) {
  const text = decodeHtmlText(value.replace(/<[^>]*>/g, " "));
  if (text === null) return null;
  return searchTokens(text);
}
__name(normalizeSearchTerms, "normalizeSearchTerms");
function searchTokens(value) {
  const normalized = value.normalize("NFC").toLowerCase();
  const terms = normalized.match(/[\p{L}\p{N}]+/gu);
  if (terms === null) return [];
  return terms;
}
__name(searchTokens, "searchTokens");
function decodeHtmlText(value) {
  let hasUnsupportedEntity = false;
  const decoded = value.replace(
    /&(?:[a-z][a-z0-9]+|#(?:[0-9]+|x[0-9a-f]+));/gi,
    (entity) => {
      const name = entity.toLowerCase();
      if (!name.startsWith("&#")) {
        const entityName = name.slice(1, -1);
        if (Object.prototype.hasOwnProperty.call(namedHtmlEntities, entityName)) {
          return namedHtmlEntities[entityName];
        }
        hasUnsupportedEntity = true;
        return " ";
      }
      const hex = name.startsWith("&#x");
      const digits = name.slice(hex ? 3 : 2, -1);
      const codePoint = Number.parseInt(digits, hex ? 16 : 10);
      if (Number.isInteger(codePoint) && codePoint > 0 && codePoint <= 1114111 && !(codePoint >= 55296 && codePoint <= 57343)) {
        return String.fromCodePoint(codePoint);
      }
      return " ";
    }
  );
  if (hasUnsupportedEntity) return null;
  return decoded;
}
__name(decodeHtmlText, "decodeHtmlText");
function corsHeaders(allowedMethods = "GET, OPTIONS") {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": allowedMethods,
    "Access-Control-Allow-Headers": "Accept, Content-Type",
    "Access-Control-Expose-Headers": "Retry-After",
    "Access-Control-Max-Age": "600",
    "Cache-Control": "no-store",
    "Content-Type": "application/json; charset=utf-8"
  };
}
__name(corsHeaders, "corsHeaders");
function jsonResponse(body, status, extraHeaders = {}, allowedMethods = "GET, OPTIONS") {
  const headers = new Headers(corsHeaders(allowedMethods));
  for (const [name, value] of Object.entries(extraHeaders)) {
    headers.set(name, value);
  }
  return new Response(JSON.stringify(body), { status, headers });
}
__name(jsonResponse, "jsonResponse");
async function resolveSteamProfile(request, env) {
  if (request.method !== "POST") {
    return jsonResponse(
      { error: "method_not_allowed" },
      405,
      {},
      "POST, OPTIONS"
    );
  }
  if (!isJsonRequest(request)) {
    return profileError("invalid_request", 400);
  }
  const rawBody = await readLimitedBody(request, 2048);
  if (rawBody === null) {
    return profileError("invalid_request", 400);
  }
  let requestBody;
  try {
    requestBody = JSON.parse(rawBody);
  } catch (error) {
    return profileError("invalid_request", 400);
  }
  if (requestBody === null || Array.isArray(requestBody) || typeof requestBody !== "object" || Object.keys(requestBody).length !== 1 || typeof requestBody.profile !== "string" || requestBody.profile.length < 1 || requestBody.profile.length > 256) {
    return profileError("invalid_request", 400);
  }
  const identifier = parseSteamProfile(requestBody.profile);
  if (identifier === null) {
    return profileError("invalid_request", 400);
  }
  const rateLimitResponse = await checkSteamRateLimit(
    request,
    env,
    "POST, OPTIONS"
  );
  if (rateLimitResponse !== null) {
    return rateLimitResponse;
  }
  if (identifier.steamId !== null) {
    return profileSuccess(identifier.steamId);
  }
  if (typeof env.STEAM_API_KEY !== "string" || env.STEAM_API_KEY.length === 0) {
    return profileError("steam_api_not_configured", 503);
  }
  const apiUrl = new URL(
    "/ISteamUser/ResolveVanityURL/v1/",
    steamApi
  );
  apiUrl.searchParams.set("key", env.STEAM_API_KEY);
  apiUrl.searchParams.set("vanityurl", identifier.vanityName);
  apiUrl.searchParams.set("url_type", "1");
  let steamResponse;
  try {
    steamResponse = await fetch(apiUrl, {
      headers: { Accept: "application/json" },
      redirect: "manual"
    });
  } catch (error) {
    return profileError("steam_unavailable", 502);
  }
  if (!steamResponse.ok) {
    return profileError("steam_unavailable", 502);
  }
  let payload;
  try {
    payload = await steamResponse.json();
  } catch (error) {
    return profileError("steam_unavailable", 502);
  }
  const result = payload?.response;
  if (result?.success === 42) {
    return profileError("profile_not_found", 404);
  }
  if (result?.success !== 1 || !steamIdPattern.test(result.steamid || "")) {
    return profileError("steam_unavailable", 502);
  }
  return profileSuccess(result.steamid);
}
__name(resolveSteamProfile, "resolveSteamProfile");
function isJsonRequest(request) {
  const contentType = request.headers.get("Content-Type");
  if (contentType === null) return false;
  return /^application\/json(?:\s*;|$)/i.test(contentType);
}
__name(isJsonRequest, "isJsonRequest");
async function readLimitedBody(request, maxBytes) {
  if (request.body === null) return null;
  const reader = request.body.getReader();
  const chunks = [];
  let byteCount = 0;
  try {
    while (true) {
      const result = await reader.read();
      if (result.done) break;
      byteCount += result.value.byteLength;
      if (byteCount > maxBytes) {
        await reader.cancel();
        return null;
      }
      chunks.push(result.value);
    }
  } catch (error) {
    return null;
  }
  const bytes = new Uint8Array(byteCount);
  let offset = 0;
  for (const chunk of chunks) {
    bytes.set(chunk, offset);
    offset += chunk.byteLength;
  }
  try {
    return new TextDecoder("utf-8", { fatal: true }).decode(bytes);
  } catch (error) {
    return null;
  }
}
__name(readLimitedBody, "readLimitedBody");
async function checkSteamRateLimit(request, env, allowedMethods = "GET, OPTIONS") {
  const callerIp = request.headers.get("CF-Connecting-IP");
  try {
    const result = await env.STEAM_GUIDE_RATE_LIMIT.limit({
      key: callerIp || "unknown"
    });
    if (!result.success) {
      return jsonResponse(
        { error: "rate_limited" },
        429,
        { "Retry-After": "60" },
        allowedMethods
      );
    }
    return null;
  } catch (error) {
    return jsonResponse(
      { error: "internal_error" },
      500,
      {},
      allowedMethods
    );
  }
}
__name(checkSteamRateLimit, "checkSteamRateLimit");
async function readOwnedGames(request, env, steamId) {
  if (request.method !== "GET") {
    return jsonResponse({ error: "method_not_allowed" }, 405);
  }
  if (!steamIdPattern.test(steamId)) {
    return jsonResponse({ error: "invalid_request" }, 400);
  }
  const rateLimitResponse = await checkSteamRateLimit(request, env);
  if (rateLimitResponse !== null) return rateLimitResponse;
  if (typeof env.STEAM_API_KEY !== "string" || env.STEAM_API_KEY.trim().length === 0) {
    return jsonResponse({ error: "steam_api_not_configured" }, 503);
  }
  const summaryUrl = new URL("/ISteamUser/GetPlayerSummaries/v2/", steamApi);
  summaryUrl.searchParams.set("key", env.STEAM_API_KEY);
  summaryUrl.searchParams.set("steamids", steamId);
  const summary = await fetchSteamJson(summaryUrl);
  if (summary === null) {
    return jsonResponse({ error: "steam_unavailable" }, 502);
  }
  if (summary.response === null || typeof summary.response !== "object" || !Array.isArray(summary.response.players)) {
    return jsonResponse({ error: "steam_unavailable" }, 502);
  }
  const player = summary.response.players.find((item) => {
    if (item === null || typeof item !== "object") return false;
    return item.steamid === steamId;
  });
  if (player === void 0) {
    return jsonResponse({ error: "profile_not_found" }, 404);
  }
  if (player.communityvisibilitystate === 1 || player.communityvisibilitystate === 2) {
    return ownedGamesResult(steamId, "private", []);
  }
  if (player.communityvisibilitystate !== 3) {
    return ownedGamesResult(steamId, "unavailable", []);
  }
  const gamesUrl = new URL("/IPlayerService/GetOwnedGames/v1/", steamApi);
  gamesUrl.searchParams.set("key", env.STEAM_API_KEY);
  gamesUrl.searchParams.set(
    "input_json",
    JSON.stringify({
      steamid: steamId,
      include_appinfo: true,
      include_played_free_games: true
    })
  );
  const gamesPayload = await fetchSteamJson(gamesUrl);
  if (gamesPayload === null) {
    return jsonResponse({ error: "steam_unavailable" }, 502);
  }
  return ownedGamesResponse(steamId, gamesPayload.response);
}
__name(readOwnedGames, "readOwnedGames");
async function fetchSteamJson(url) {
  let response;
  try {
    response = await fetch(url, {
      headers: { Accept: "application/json" },
      redirect: "manual"
    });
  } catch (error) {
    return null;
  }
  if (!response.ok) return null;
  try {
    return await response.json();
  } catch (error) {
    return null;
  }
}
__name(fetchSteamJson, "fetchSteamJson");
async function readSteamAchievements(request, env, steamId, rawAppId) {
  const appId = Number(rawAppId);
  if (request.method !== "GET" || !steamIdPattern.test(steamId) || !/^[1-9][0-9]{0,9}$/.test(rawAppId) || !Number.isSafeInteger(appId) || appId > 4294967295) {
    const status = request.method === "GET" ? 400 : 405;
    const error = status === 400 ? "invalid_request" : "method_not_allowed";
    return jsonResponse({ error }, status);
  }
  const rateLimitResponse = await checkSteamRateLimit(request, env);
  if (rateLimitResponse !== null) return rateLimitResponse;
  if (typeof env.STEAM_API_KEY !== "string" || env.STEAM_API_KEY.trim().length === 0) {
    return jsonResponse({ error: "steam_api_not_configured" }, 503);
  }
  const schemaUrl = new URL(
    "/ISteamUserStats/GetSchemaForGame/v2/",
    steamApi
  );
  schemaUrl.searchParams.set("key", env.STEAM_API_KEY);
  schemaUrl.searchParams.set("appid", String(appId));
  schemaUrl.searchParams.set("l", "english");
  const schemaPayload = await fetchSteamJson(schemaUrl);
  if (schemaPayload === null) {
    return jsonResponse({ error: "steam_unavailable" }, 502);
  }
  const schema = parseSteamAchievementSchema(schemaPayload);
  if (schema === null) {
    return jsonResponse({ error: "steam_unavailable" }, 502);
  }
  if (schema.length === 0) {
    return steamAchievementsResult(steamId, appId, "no_achievements", []);
  }
  const progressUrl = new URL(
    "/ISteamUserStats/GetPlayerAchievements/v1/",
    steamApi
  );
  progressUrl.searchParams.set("key", env.STEAM_API_KEY);
  progressUrl.searchParams.set("steamid", steamId);
  progressUrl.searchParams.set("appid", String(appId));
  progressUrl.searchParams.set("l", "english");
  const progressPayload = await fetchSteamJson(progressUrl);
  const progress = parseSteamPlayerAchievements(progressPayload);
  if (progress === null) {
    return steamAchievementsResult(
      steamId,
      appId,
      "progress_unavailable",
      mapSteamAchievementProgress(schema, /* @__PURE__ */ new Map())
    );
  }
  return steamAchievementsResult(
    steamId,
    appId,
    "available",
    mapSteamAchievementProgress(schema, progress)
  );
}
__name(readSteamAchievements, "readSteamAchievements");
function parseSteamAchievementSchema(payload) {
  if (payload === null || typeof payload !== "object" || Array.isArray(payload) || payload.game === null || typeof payload.game !== "object" || Array.isArray(payload.game)) {
    return null;
  }
  const gameStats = payload.game.availableGameStats;
  if (gameStats === void 0) return [];
  if (gameStats === null || typeof gameStats !== "object" || Array.isArray(gameStats)) {
    return null;
  }
  const rawAchievements = gameStats.achievements;
  if (rawAchievements === void 0) return [];
  if (!Array.isArray(rawAchievements)) return null;
  const achievements = [];
  const ids = /* @__PURE__ */ new Set();
  for (const item of rawAchievements) {
    if (item === null || typeof item !== "object" || Array.isArray(item)) {
      return null;
    }
    if (typeof item.name !== "string" || item.name.trim().length === 0) {
      return null;
    }
    const achievementId = item.name.trim();
    if (ids.has(achievementId)) return null;
    ids.add(achievementId);
    let displayName = achievementId;
    if (typeof item.displayName === "string" && item.displayName.trim().length > 0) {
      displayName = item.displayName;
    }
    achievements.push({
      achievement_id: achievementId,
      display_name: displayName,
      description: nullableString(item.description),
      hidden: steamFlag(item.hidden),
      icon_url: nullableString(item.icon),
      icon_gray_url: nullableString(item.icongray)
    });
  }
  return achievements;
}
__name(parseSteamAchievementSchema, "parseSteamAchievementSchema");
function nullableString(value) {
  if (typeof value !== "string" || value.trim().length === 0) return null;
  return value;
}
__name(nullableString, "nullableString");
function steamFlag(value) {
  if (value === 0 || value === false) return false;
  if (value === 1 || value === true) return true;
  return null;
}
__name(steamFlag, "steamFlag");
function parseSteamPlayerAchievements(payload) {
  if (payload === null || typeof payload !== "object" || Array.isArray(payload) || payload.playerstats === null || typeof payload.playerstats !== "object" || Array.isArray(payload.playerstats)) {
    return null;
  }
  const playerStats = payload.playerstats;
  if (playerStats.success === false || playerStats.success === 0 || !Array.isArray(playerStats.achievements)) {
    return null;
  }
  const progress = /* @__PURE__ */ new Map();
  const duplicateIds = /* @__PURE__ */ new Set();
  for (const item of playerStats.achievements) {
    if (item === null || typeof item !== "object" || Array.isArray(item) || typeof item.apiname !== "string" || item.apiname.trim().length === 0) {
      continue;
    }
    const achievementId = item.apiname.trim();
    if (progress.has(achievementId)) {
      duplicateIds.add(achievementId);
      continue;
    }
    const unlocked = steamFlag(item.achieved);
    let unlockTime = null;
    if (unlocked === true && Number.isSafeInteger(item.unlocktime) && item.unlocktime >= 0) {
      unlockTime = item.unlocktime;
    }
    progress.set(achievementId, { unlocked, unlockTime });
  }
  for (const achievementId of duplicateIds) {
    progress.set(achievementId, { unlocked: null, unlockTime: null });
  }
  return progress;
}
__name(parseSteamPlayerAchievements, "parseSteamPlayerAchievements");
function mapSteamAchievementProgress(schema, progress) {
  const achievements = [];
  for (const achievement of schema) {
    const playerAchievement = progress.get(achievement.achievement_id);
    let unlocked = null;
    let unlockTime = null;
    if (playerAchievement !== void 0) {
      unlocked = playerAchievement.unlocked;
      unlockTime = playerAchievement.unlockTime;
    }
    achievements.push({
      ...achievement,
      unlocked,
      unlock_time: unlockTime
    });
  }
  return achievements;
}
__name(mapSteamAchievementProgress, "mapSteamAchievementProgress");
function steamAchievementsResult(steamId, appId, status, achievements) {
  return jsonResponse(
    { steam_id: steamId, app_id: appId, status, achievements },
    200
  );
}
__name(steamAchievementsResult, "steamAchievementsResult");
function ownedGamesResponse(steamId, response) {
  if (response === null || typeof response !== "object" || !Number.isSafeInteger(response.game_count) || response.game_count < 0) {
    return ownedGamesResult(steamId, "unavailable", []);
  }
  if (response.game_count === 0) {
    if (response.games !== void 0 && (!Array.isArray(response.games) || response.games.length !== 0)) {
      return ownedGamesResult(steamId, "unavailable", []);
    }
    return ownedGamesResult(steamId, "empty", []);
  }
  if (!Array.isArray(response.games) || response.games.length !== response.game_count) {
    return ownedGamesResult(steamId, "unavailable", []);
  }
  const games = mapOwnedGames(response.games);
  if (games === null) {
    return ownedGamesResult(steamId, "unavailable", []);
  }
  return ownedGamesResult(steamId, "available", games);
}
__name(ownedGamesResponse, "ownedGamesResponse");
function mapOwnedGames(rawGames) {
  const games = [];
  for (const game of rawGames) {
    if (game === null || typeof game !== "object" || !Number.isSafeInteger(game.appid) || game.appid < 1 || game.appid > 4294967295 || typeof game.name !== "string" || game.name.trim().length === 0) {
      return null;
    }
    let playtime = null;
    if (game.playtime_forever !== void 0 && game.playtime_forever !== null) {
      if (!Number.isSafeInteger(game.playtime_forever) || game.playtime_forever < 0) {
        return null;
      }
      playtime = game.playtime_forever;
    }
    games.push({
      app_id: game.appid,
      name: game.name,
      playtime_forever_minutes: playtime
    });
  }
  return games;
}
__name(mapOwnedGames, "mapOwnedGames");
function ownedGamesResult(steamId, status, games) {
  return jsonResponse({ steam_id: steamId, status, games }, 200);
}
__name(ownedGamesResult, "ownedGamesResult");
function parseSteamProfile(profile) {
  if (steamIdPattern.test(profile)) {
    return { steamId: profile, vanityName: null };
  }
  let candidate = profile;
  if (profile.startsWith("https://")) {
    const urlMatch = profile.match(
      /^https:\/\/(?:steamcommunity\.com|www\.steamcommunity\.com)\/(id|profiles)\/([^/?#]+)\/?$/
    );
    if (urlMatch === null) return null;
    candidate = urlMatch[2];
    if (urlMatch[1] === "profiles") {
      if (!steamIdPattern.test(candidate)) return null;
      return { steamId: candidate, vanityName: null };
    }
  }
  if (!/^[A-Za-z0-9_-]{1,64}$/.test(candidate)) return null;
  return { steamId: null, vanityName: candidate };
}
__name(parseSteamProfile, "parseSteamProfile");
function profileSuccess(steamId) {
  return jsonResponse(
    {
      steam_id: steamId,
      profile_url: `${steamCommunity}/profiles/${steamId}/`
    },
    200,
    {},
    "POST, OPTIONS"
  );
}
__name(profileSuccess, "profileSuccess");
function profileError(error, status, headers = {}) {
  return jsonResponse({ error }, status, headers, "POST, OPTIONS");
}
__name(profileError, "profileError");

// ../../../../../../../../../../.npm/_npx/c943b712072b77c4/node_modules/wrangler/templates/middleware/middleware-ensure-req-body-drained.ts
var drainBody = /* @__PURE__ */ __name(async (request, env, _ctx, middlewareCtx) => {
  try {
    return await middlewareCtx.next(request, env);
  } finally {
    try {
      if (request.body !== null && !request.bodyUsed) {
        const reader = request.body.getReader();
        while (!(await reader.read()).done) {
        }
      }
    } catch (e) {
      console.error("Failed to drain the unused request body.", e);
    }
  }
}, "drainBody");
var middleware_ensure_req_body_drained_default = drainBody;

// ../../../../../../../../../../.npm/_npx/c943b712072b77c4/node_modules/wrangler/templates/middleware/middleware-miniflare3-json-error.ts
function reduceError(e) {
  return {
    name: e?.name,
    message: e?.message ?? String(e),
    stack: e?.stack,
    cause: e?.cause === void 0 ? void 0 : reduceError(e.cause)
  };
}
__name(reduceError, "reduceError");
var jsonError = /* @__PURE__ */ __name(async (request, env, _ctx, middlewareCtx) => {
  try {
    return await middlewareCtx.next(request, env);
  } catch (e) {
    const error = reduceError(e);
    const body = JSON.stringify(error);
    const headers = {
      "Content-Type": "application/json",
      "MF-Experimental-Error-Stack": "true"
    };
    const encoded = encodeURIComponent(body);
    if (encoded.length <= 8192) {
      headers["MF-Experimental-Error-Stack-Payload"] = encoded;
    }
    return new Response(body, { status: 500, headers });
  }
}, "jsonError");
var middleware_miniflare3_json_error_default = jsonError;

// .wrangler/tmp/bundle-9iXERg/middleware-insertion-facade.js
var __INTERNAL_WRANGLER_MIDDLEWARE__ = [
  middleware_ensure_req_body_drained_default,
  middleware_miniflare3_json_error_default
];
var middleware_insertion_facade_default = src_default;

// ../../../../../../../../../../.npm/_npx/c943b712072b77c4/node_modules/wrangler/templates/middleware/common.ts
var __facade_middleware__ = [];
function __facade_register__(...args) {
  __facade_middleware__.push(...args.flat());
}
__name(__facade_register__, "__facade_register__");
function __facade_invokeChain__(request, env, ctx, dispatch, middlewareChain) {
  const [head, ...tail] = middlewareChain;
  const middlewareCtx = {
    dispatch,
    next(newRequest, newEnv) {
      return __facade_invokeChain__(newRequest, newEnv, ctx, dispatch, tail);
    }
  };
  return head(request, env, ctx, middlewareCtx);
}
__name(__facade_invokeChain__, "__facade_invokeChain__");
function __facade_invoke__(request, env, ctx, dispatch, finalMiddleware) {
  return __facade_invokeChain__(request, env, ctx, dispatch, [
    ...__facade_middleware__,
    finalMiddleware
  ]);
}
__name(__facade_invoke__, "__facade_invoke__");

// .wrangler/tmp/bundle-9iXERg/middleware-loader.entry.ts
var __Facade_ScheduledController__ = class ___Facade_ScheduledController__ {
  constructor(scheduledTime, cron, noRetry) {
    this.scheduledTime = scheduledTime;
    this.cron = cron;
    this.#noRetry = noRetry;
  }
  scheduledTime;
  cron;
  static {
    __name(this, "__Facade_ScheduledController__");
  }
  #noRetry;
  noRetry() {
    if (!(this instanceof ___Facade_ScheduledController__)) {
      throw new TypeError("Illegal invocation");
    }
    this.#noRetry();
  }
};
function wrapExportedHandler(worker) {
  if (__INTERNAL_WRANGLER_MIDDLEWARE__ === void 0 || __INTERNAL_WRANGLER_MIDDLEWARE__.length === 0) {
    return worker;
  }
  for (const middleware of __INTERNAL_WRANGLER_MIDDLEWARE__) {
    __facade_register__(middleware);
  }
  const fetchDispatcher = /* @__PURE__ */ __name(function(request, env, ctx) {
    if (worker.fetch === void 0) {
      throw new Error("Handler does not export a fetch() function.");
    }
    return worker.fetch(request, env, ctx);
  }, "fetchDispatcher");
  return {
    ...worker,
    fetch(request, env, ctx) {
      const dispatcher = /* @__PURE__ */ __name(function(type, init) {
        if (type === "scheduled" && worker.scheduled !== void 0) {
          const controller = new __Facade_ScheduledController__(
            Date.now(),
            init.cron ?? "",
            () => {
            }
          );
          return worker.scheduled(controller, env, ctx);
        }
      }, "dispatcher");
      return __facade_invoke__(request, env, ctx, dispatcher, fetchDispatcher);
    }
  };
}
__name(wrapExportedHandler, "wrapExportedHandler");
function wrapWorkerEntrypoint(klass) {
  if (__INTERNAL_WRANGLER_MIDDLEWARE__ === void 0 || __INTERNAL_WRANGLER_MIDDLEWARE__.length === 0) {
    return klass;
  }
  for (const middleware of __INTERNAL_WRANGLER_MIDDLEWARE__) {
    __facade_register__(middleware);
  }
  return class extends klass {
    #fetchDispatcher = /* @__PURE__ */ __name((request, env, ctx) => {
      this.env = env;
      this.ctx = ctx;
      if (super.fetch === void 0) {
        throw new Error("Entrypoint class does not define a fetch() function.");
      }
      return super.fetch(request);
    }, "#fetchDispatcher");
    #dispatcher = /* @__PURE__ */ __name((type, init) => {
      if (type === "scheduled" && super.scheduled !== void 0) {
        const controller = new __Facade_ScheduledController__(
          Date.now(),
          init.cron ?? "",
          () => {
          }
        );
        return super.scheduled(controller);
      }
    }, "#dispatcher");
    fetch(request) {
      return __facade_invoke__(
        request,
        this.env,
        this.ctx,
        this.#dispatcher,
        this.#fetchDispatcher
      );
    }
  };
}
__name(wrapWorkerEntrypoint, "wrapWorkerEntrypoint");
var WRAPPED_ENTRY;
if (typeof middleware_insertion_facade_default === "object") {
  WRAPPED_ENTRY = wrapExportedHandler(middleware_insertion_facade_default);
} else if (typeof middleware_insertion_facade_default === "function") {
  WRAPPED_ENTRY = wrapWorkerEntrypoint(middleware_insertion_facade_default);
}
var middleware_loader_entry_default = WRAPPED_ENTRY;
export {
  __INTERNAL_WRANGLER_MIDDLEWARE__,
  middleware_loader_entry_default as default
};
//# sourceMappingURL=index.js.map
