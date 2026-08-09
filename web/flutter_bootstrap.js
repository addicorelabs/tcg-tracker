// Custom bootstrap, replacing the one Flutter generates, for one reason: to
// stop it registering `flutter_service_worker.js`.
//
// As of Flutter 3.44 that file no longer caches anything — it unregisters
// itself and reloads the page. Registering it alongside ours would put two
// service workers on the same scope, and the last one registered wins, so the
// app would end up with either no offline support or a reload loop.
//
// The tokens below are filled in by `flutter build web`.
{{flutter_js}}
{{flutter_build_config}}

_flutter.loader.load();

// Registered after the app is on its way rather than before: the first paint
// should never wait on the cache being warmed.
if ('serviceWorker' in navigator) {
  window.addEventListener('load', function () {
    navigator.serviceWorker.register('service_worker.js').catch(function (error) {
      // Not fatal, and deliberately not shown to the user: without a service
      // worker the app still works, it just needs the network to start.
      console.warn('Offline support unavailable:', error);
    });
  });
}
