// Ojo de Dios Cloudflare Worker — private API gateway for GitHub Pages + USB key.
// Secrets stay here in Cloudflare, never in GitHub Pages and never on the USB.
// Required secret examples:
//   wrangler secret put USB_ACCESS_TOKEN
//   wrangler secret put TOMTOM_API_KEY

const CORS_HEADERS = {
  'Access-Control-Allow-Origin': '*',
  'Access-Control-Allow-Methods': 'GET, POST, OPTIONS',
  'Access-Control-Allow-Headers': 'Content-Type, Authorization, X-Igor-USB-Key',
  'Access-Control-Max-Age': '86400',
};

function json(data, status = 200, extraHeaders = {}) {
  return new Response(JSON.stringify(data), {
    status,
    headers: {
      ...CORS_HEADERS,
      'Content-Type': 'application/json; charset=utf-8',
      'Cache-Control': 'no-store',
      ...extraHeaders,
    },
  });
}

function withCors(response, extraHeaders = {}) {
  const headers = new Headers(response.headers);
  for (const [key, value] of Object.entries(CORS_HEADERS)) headers.set(key, value);
  for (const [key, value] of Object.entries(extraHeaders)) headers.set(key, value);
  return new Response(response.body, { status: response.status, statusText: response.statusText, headers });
}

function getToken(request) {
  const url = new URL(request.url);
  const headerToken = request.headers.get('X-Igor-USB-Key') || '';
  const bearer = request.headers.get('Authorization') || '';
  const queryToken = url.searchParams.get('igor_key') || '';
  if (headerToken) return headerToken.trim();
  if (bearer.toLowerCase().startsWith('bearer ')) return bearer.slice(7).trim();
  return queryToken.trim();
}

function requireUsbKey(request, env) {
  const expected = String(env.USB_ACCESS_TOKEN || '').trim();
  if (!expected) return null; // deployment not locked yet; useful during first setup
  const supplied = getToken(request);
  if (supplied && supplied === expected) return null;
  return json({ error: 'locked', message: 'IGOR USB KEY REQUIRED' }, 401);
}

function validTilePart(value) {
  return /^\d+$/.test(value) && Number(value) >= 0 && Number(value) <= 9999999;
}

async function handleTomTom(request, env, pathParts) {
  if (pathParts[2] === 'status') {
    return json({
      hasKey: Boolean(env.TOMTOM_API_KEY),
      // Cloudflare KV counter can be added later. Keep shape compatible with local API.
      dailyCount: null,
      budget: Number(env.TOMTOM_DAILY_BUDGET || 40000),
      date: new Date().toISOString().slice(0, 10),
      cloud: true,
    });
  }

  // /api/tomtom/flow/{z}/{x}/{y}.pbf
  if (pathParts[2] === 'flow' && pathParts.length === 6) {
    if (!env.TOMTOM_API_KEY) return json({ error: 'no_key' }, 503);
    const [z, x, yFile] = pathParts.slice(3);
    const y = yFile.replace(/\.pbf$/i, '');
    if (!yFile.endsWith('.pbf') || ![z, x, y].every(validTilePart)) {
      return json({ error: 'bad_tile' }, 400);
    }
    const upstream = `https://api.tomtom.com/traffic/map/4/tile/flow/relative/${z}/${x}/${y}.pbf?key=${encodeURIComponent(env.TOMTOM_API_KEY)}`;
    const res = await fetch(upstream, {
      headers: { 'User-Agent': 'ojo-de-dios-cloud-worker/1.0' },
      cf: { cacheTtl: 20, cacheEverything: true },
    });
    return withCors(res, { 'Content-Type': 'application/x-protobuf', 'Cache-Control': 'public, max-age=20' });
  }

  return json({ error: 'not_found' }, 404);
}

async function handleOverpass(request) {
  if (request.method !== 'POST') return json({ error: 'method_not_allowed' }, 405);
  const body = await request.text();
  if (!body || body.length > 25000) return json({ error: 'bad_query' }, 400);

  const endpoints = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://lz4.overpass-api.de/api/interpreter',
  ];

  let lastText = '';
  for (const endpoint of endpoints) {
    try {
      const res = await fetch(endpoint, {
        method: 'POST',
        headers: { 'Content-Type': 'application/x-www-form-urlencoded; charset=UTF-8' },
        body,
      });
      const text = await res.text();
      lastText = text.slice(0, 500);
      if (res.ok && !/runtime error|Query timed out|Too many requests/i.test(text)) {
        return new Response(text, {
          status: 200,
          headers: { ...CORS_HEADERS, 'Content-Type': 'application/json; charset=utf-8', 'Cache-Control': 'public, max-age=180' },
        });
      }
    } catch (error) {
      lastText = String(error && error.message || error).slice(0, 500);
    }
  }
  return json({ error: 'overpass_failed', detail: lastText }, 502);
}

export default {
  async fetch(request, env) {
    if (request.method === 'OPTIONS') return new Response(null, { status: 204, headers: CORS_HEADERS });

    const lock = requireUsbKey(request, env);
    if (lock) return lock;

    const url = new URL(request.url);
    const pathParts = url.pathname.split('/').filter(Boolean);

    if (url.pathname === '/' || url.pathname === '/api/health') {
      return json({ ok: true, service: 'ojo-de-dios-worker', locked: Boolean(env.USB_ACCESS_TOKEN) });
    }

    if (pathParts[0] !== 'api') return json({ error: 'not_found' }, 404);
    if (pathParts[1] === 'tomtom') return handleTomTom(request, env, pathParts);
    if (pathParts[1] === 'overpass') return handleOverpass(request);

    // v1 cloud gateway: unsupported layers degrade gracefully in the frontend.
    return json({ error: 'unsupported_in_worker_v1', path: url.pathname }, 501);
  },
};
