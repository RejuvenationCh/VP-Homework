var __defProp = Object.defineProperty;
var __name = (target, value) => __defProp(target, "name", { value, configurable: true });

// src/index.js
var steamCommunity = "https://steamcommunity.com";
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
    if (requestUrl.pathname !== "/v1/steam/guides") {
      return jsonResponse({ error: "not_found" }, 404);
    }
    if (request.method === "OPTIONS") {
      return new Response(null, { status: 204, headers: corsHeaders() });
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
function corsHeaders() {
  return {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, OPTIONS",
    "Access-Control-Allow-Headers": "Accept, Content-Type",
    "Access-Control-Expose-Headers": "Retry-After",
    "Access-Control-Max-Age": "600",
    "Cache-Control": "no-store",
    "Content-Type": "application/json; charset=utf-8"
  };
}
__name(corsHeaders, "corsHeaders");
function jsonResponse(body, status, extraHeaders = {}) {
  const headers = new Headers(corsHeaders());
  for (const [name, value] of Object.entries(extraHeaders)) {
    headers.set(name, value);
  }
  return new Response(JSON.stringify(body), { status, headers });
}
__name(jsonResponse, "jsonResponse");

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

// .wrangler/tmp/bundle-fkJPmG/middleware-insertion-facade.js
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

// .wrangler/tmp/bundle-fkJPmG/middleware-loader.entry.ts
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
