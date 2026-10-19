const steamCommunity = 'https://steamcommunity.com';
const guideSearchMarker = 'Results for';
const guideCardPattern =
  /<a\b(?=[^>]*class="[^"]*\bworkshopItemCollection\b)(?=[^>]*data-publishedfileid="[0-9]+")[^>]*>([\s\S]*?)<\/a>/g;
const guideTextPattern =
  /<div class="workshopItem(?:Title|ShortDesc)">([\s\S]*?)<\/div>/g;
const resultSummaryPattern =
  /Showing\s+([0-9,]+)-([0-9,]+)\s+of\s+([0-9,]+)\s+entries/i;
const namedHtmlEntities = {
  amp: '&',
  apos: "'",
  aacute: 'á',
  acirc: 'â',
  aelig: 'æ',
  agrave: 'à',
  aring: 'å',
  atilde: 'ã',
  auml: 'ä',
  ccedil: 'ç',
  eacute: 'é',
  ecirc: 'ê',
  egrave: 'è',
  euml: 'ë',
  gt: '>',
  iacute: 'í',
  icirc: 'î',
  igrave: 'ì',
  iuml: 'ï',
  lt: '<',
  nbsp: ' ',
  ntilde: 'ñ',
  oacute: 'ó',
  ocirc: 'ô',
  ograve: 'ò',
  oelig: 'œ',
  otilde: 'õ',
  ouml: 'ö',
  quot: '"',
  uacute: 'ú',
  ucirc: 'û',
  ugrave: 'ù',
  uml: '¨',
  uuml: 'ü',
  yacute: 'ý',
  yuml: 'ÿ',
};

export default {
  async fetch(request, env) {
    const requestUrl = new URL(request.url);
    if (requestUrl.pathname !== '/v1/steam/guides') {
      return jsonResponse({ error: 'not_found' }, 404);
    }
    if (request.method === 'OPTIONS') {
      return new Response(null, { status: 204, headers: corsHeaders() });
    }
    if (request.method !== 'GET') {
      return jsonResponse({ error: 'method_not_allowed' }, 405);
    }

    const appId = requestUrl.searchParams.get('app_id');
    const searchText = requestUrl.searchParams.get('search_text');
    if (!isValidRequest(appId, searchText)) {
      return jsonResponse({ error: 'invalid_request' }, 400);
    }

    const callerIp = request.headers.get('CF-Connecting-IP');
    const rateLimitKey = callerIp || 'unknown';
    let rateLimit;
    try {
      rateLimit = await env.STEAM_GUIDE_RATE_LIMIT.limit({ key: rateLimitKey });
    } catch (error) {
      return jsonResponse({ error: 'internal_error' }, 500);
    }
    if (!rateLimit.success) {
      return jsonResponse(
        { error: 'rate_limited' },
        429,
        { 'Retry-After': '60' },
      );
    }

    const guideUrl = buildGuideUrl(appId, searchText.trim());
    let steamResponse;
    try {
      steamResponse = await fetch(guideUrl, {
        headers: { Accept: 'text/html' },
      });
    } catch (error) {
      return jsonResponse({ error: 'steam_unavailable' }, 502);
    }

    if (steamResponse.status === 429) {
      return jsonResponse(
        { error: 'rate_limited' },
        429,
        { 'Retry-After': '60' },
      );
    }
    if (!steamResponse.ok) {
      return jsonResponse({ error: 'steam_unavailable' }, 502);
    }

    let page;
    try {
      page = await steamResponse.text();
    } catch (error) {
      return jsonResponse({ error: 'steam_unavailable' }, 502);
    }
    if (!page.includes(guideSearchMarker)) {
      return jsonResponse({ error: 'steam_unavailable' }, 502);
    }
    const hasMatchingGuide = matchingGuideExists(page, searchText.trim());
    if (hasMatchingGuide === null) {
      return jsonResponse({ error: 'steam_unavailable' }, 502);
    }
    if (!hasMatchingGuide) {
      return jsonResponse({ error: 'guide_not_found' }, 404);
    }

    return jsonResponse({ found: true, guide_url: guideUrl.toString() }, 200);
  },
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

function buildGuideUrl(appId, searchText) {
  const url = new URL(`/app/${appId}/guides/`, steamCommunity);
  url.searchParams.set('browsefilter', 'trend');
  url.searchParams.set('browsesort', 'trend');
  url.searchParams.set('l', 'english');
  url.searchParams.set('numperpage', '30');
  url.searchParams.set('searchText', searchText);
  return url;
}

function matchingGuideExists(page, searchText) {
  // Steam shows popular guides when the search has no match.
  const summary = page.match(resultSummaryPattern);
  const searchTerms = searchTokens(searchText);
  if (summary === null || searchTerms.length === 0) {
    return null;
  }

  const firstResult = Number.parseInt(summary[1].replaceAll(',', ''), 10);
  const lastResult = Number.parseInt(summary[2].replaceAll(',', ''), 10);
  const total = Number.parseInt(summary[3].replaceAll(',', ''), 10);
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
      sections.map((section) => section[1]).join(' '),
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

function normalizeSearchTerms(value) {
  const text = decodeHtmlText(value.replace(/<[^>]*>/g, ' '));
  if (text === null) return null;
  return searchTokens(text);
}

function searchTokens(value) {
  const normalized = value.normalize('NFC').toLowerCase();
  const terms = normalized.match(/[\p{L}\p{N}]+/gu);
  if (terms === null) return [];
  return terms;
}

function decodeHtmlText(value) {
  let hasUnsupportedEntity = false;
  const decoded = value.replace(
    /&(?:[a-z][a-z0-9]+|#(?:[0-9]+|x[0-9a-f]+));/gi,
    (entity) => {
      const name = entity.toLowerCase();
      if (!name.startsWith('&#')) {
        const entityName = name.slice(1, -1);
        if (Object.prototype.hasOwnProperty.call(namedHtmlEntities, entityName)) {
          return namedHtmlEntities[entityName];
        }
        hasUnsupportedEntity = true;
        return ' ';
      }

      const hex = name.startsWith('&#x');
      const digits = name.slice(hex ? 3 : 2, -1);
      const codePoint = Number.parseInt(digits, hex ? 16 : 10);
      if (
        Number.isInteger(codePoint) &&
        codePoint > 0 &&
        codePoint <= 0x10ffff &&
        !(codePoint >= 0xd800 && codePoint <= 0xdfff)
      ) {
        return String.fromCodePoint(codePoint);
      }
      return ' ';
    },
  );
  if (hasUnsupportedEntity) return null;
  return decoded;
}

function corsHeaders() {
  return {
    'Access-Control-Allow-Origin': '*',
    'Access-Control-Allow-Methods': 'GET, OPTIONS',
    'Access-Control-Allow-Headers': 'Accept, Content-Type',
    'Access-Control-Expose-Headers': 'Retry-After',
    'Access-Control-Max-Age': '600',
    'Cache-Control': 'no-store',
    'Content-Type': 'application/json; charset=utf-8',
  };
}

function jsonResponse(body, status, extraHeaders = {}) {
  const headers = new Headers(corsHeaders());
  for (const [name, value] of Object.entries(extraHeaders)) {
    headers.set(name, value);
  }
  return new Response(JSON.stringify(body), { status, headers });
}

