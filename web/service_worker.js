'use strict';

// Offline support for the PWA.
//
// Written by hand because Flutter no longer ships one: as of 3.44 the
// generated `flutter_service_worker.js` unregisters itself and caches nothing.
// Without this file the app needs the network to start, which for something
// used at a tournament venue — in a basement, on a busy cell — is the same as
// not working.
//
// The strategy is deliberately not a build-time precache manifest. Flutter's
// output file names are stable rather than content-hashed, and CanvasKit pulls
// in a set of files that changes between Flutter versions: a hand-written list
// would go stale silently, which is the one failure mode worse than no cache.
// Instead every same-origin GET fills the cache as it is served, so after one
// complete load online everything the app needs is on the device.

// Replaced with the commit SHA by the deploy workflow. A new deploy therefore
// lands in a different cache, and the old one is dropped on activation, which
// is what stops a half-old half-new mix of `main.dart.js` and its assets.
//
// Local builds keep the literal placeholder, so a rebuild reuses the same
// cache: during development, hard-reload rather than trusting this file.
const CACHE = 'tcg-tracker-__BUILD_ID__';

/// Fetched during install, so a device that goes offline immediately after
/// installing still opens. Everything else arrives through the fetch handler.
const SHELL = [
  './',
  'index.html',
  'flutter_bootstrap.js',
  'flutter.js',
  'main.dart.js',
  'manifest.json',
  // The database. These two are hand-downloaded binaries rather than build
  // output, and without them the app opens to an error instead of a library.
  'sqlite3.wasm',
  'drift_worker.js',
];

self.addEventListener('install', (event) => {
  event.waitUntil(
    (async () => {
      const cache = await caches.open(CACHE);
      // Individually, not `addAll`: that rejects the whole batch if one entry
      // 404s, which would leave the app with no cache at all over a single
      // file that may not even be needed.
      await Promise.all(
        SHELL.map((path) =>
          cache.add(new Request(path, { cache: 'reload' })).catch((error) => {
            console.warn('Could not precache', path, error);
          })
        )
      );
      await self.skipWaiting();
    })()
  );
});

self.addEventListener('activate', (event) => {
  event.waitUntil(
    (async () => {
      const names = await caches.keys();
      await Promise.all(
        names.filter((name) => name !== CACHE).map((name) => caches.delete(name))
      );
      await self.clients.claim();
    })()
  );
});

self.addEventListener('fetch', (event) => {
  const request = event.request;

  // Only same-origin reads. Supabase calls in particular must never be served
  // from a cache: a stale snapshot answered offline would look like the cloud
  // agreeing with a device that is actually behind.
  if (request.method !== 'GET') return;
  if (new URL(request.url).origin !== self.location.origin) return;

  // A navigation is the one request worth spending the network on: it is small,
  // and it is how a new deploy gets noticed. Offline, the cached shell answers.
  if (request.mode === 'navigate') {
    event.respondWith(
      (async () => {
        try {
          const response = await fetch(request);
          await put(request, response.clone());
          return response;
        } catch (error) {
          return (
            (await caches.match(request)) ??
            (await caches.match('index.html')) ??
            Response.error()
          );
        }
      })()
    );
    return;
  }

  event.respondWith(
    (async () => {
      const cached = await caches.match(request);
      if (cached) return cached;

      const response = await fetch(request);
      await put(request, response.clone());
      return response;
    })()
  );
});

/// Stores a response, ignoring the ones that would poison the cache.
///
/// Partial and opaque responses are skipped: a 206 cached whole would be served
/// back as if it were the entire file, and an opaque response cannot be checked
/// for having succeeded at all.
async function put(request, response) {
  if (!response.ok || response.type !== 'basic') return;

  const cache = await caches.open(CACHE);
  await cache.put(request, response);
}
