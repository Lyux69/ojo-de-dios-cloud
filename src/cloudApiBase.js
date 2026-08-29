/**
 * Cloud API base for the USB/GitHub Pages version.
 *
 * Local dev keeps using same-origin /api handled by vite.config.js.
 * Cloud/GitHub Pages can set VITE_API_BASE_URL to a Cloudflare Worker URL.
 * Then every browser fetch('/api/...') is automatically rewritten to:
 *   https://worker.example.workers.dev/api/...
 *
 * This keeps secrets (TomTom, future API keys) off the USB and out of GitHub Pages.
 */

const rawApiBase = String(import.meta.env.VITE_API_BASE_URL || '').trim().replace(/\/+$/, '');

function readUsbToken() {
  const params = new URLSearchParams(window.location.search || '');
  const token = params.get('igor_key') || params.get('usb_key') || '';
  if (token) {
    window.localStorage.setItem('IGOR_USB_KEY', token);
    // Hide the token from the visible address bar after first load.
    params.delete('igor_key');
    params.delete('usb_key');
    const clean = `${window.location.pathname}${params.toString() ? `?${params}` : ''}${window.location.hash || ''}`;
    window.history.replaceState(null, '', clean);
    return token;
  }
  return window.localStorage.getItem('IGOR_USB_KEY') || '';
}

function addUsbToken(url, token) {
  if (!token) return url;
  const parsed = new URL(url, window.location.origin);
  parsed.searchParams.set('igor_key', token);
  return parsed.toString();
}

if (rawApiBase && typeof window !== 'undefined' && typeof window.fetch === 'function') {
  const nativeFetch = window.fetch.bind(window);
  const usbToken = readUsbToken();

  window.__GEV_API_BASE_URL__ = rawApiBase;

  window.fetch = (input, init) => {
    if (typeof input === 'string' && input.startsWith('/api/')) {
      return nativeFetch(addUsbToken(`${rawApiBase}${input}`, usbToken), init);
    }

    if (input instanceof Request) {
      const url = new URL(input.url);
      if (url.origin === window.location.origin && url.pathname.startsWith('/api/')) {
        const rewritten = new Request(addUsbToken(`${rawApiBase}${url.pathname}${url.search}`, usbToken), input);
        return nativeFetch(rewritten, init);
      }
    }

    return nativeFetch(input, init);
  };

  console.info('[USB Cloud] API base activo:', rawApiBase, usbToken ? '(llave USB cargada)' : '(sin llave USB)');
}
