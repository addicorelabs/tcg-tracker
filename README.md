# TCG Tracker

App per tracciare i tornei di Yu-Gi-Oh! e Magic: The Gathering. PWA installabile,
costruita con Flutter web, pensata per essere usata dal telefono a bordo tavolo.

Il documento di design è in [`docs/architettura.md`](docs/architettura.md), le
convenzioni di lavoro in [`CLAUDE.md`](CLAUDE.md).

## Sviluppo

Il Flutter SDK sta in `C:\src\flutter`.

```bash
flutter pub get
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080
flutter analyze
flutter test
```

Con il sync attivo, l'avvio vuole le credenziali Supabase:

```bash
flutter run -d web-server --web-port 8080 \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

Senza, l'app parte lo stesso e resta interamente locale.

## Deploy

Ogni push su `main` fa partire
[il workflow](.github/workflows/deploy.yml): analyze, test, build e
pubblicazione su GitHub Pages. Non c'è niente da lanciare a mano.

Il `--base-href` viene ricavato dal nome del repository, quindi rinominarlo non
rompe il deploy.

### Setup una tantum

1. Crea il repository su GitHub e collegalo:
   ```bash
   git remote add origin https://github.com/<utente>/<repo>.git
   git push -u origin main
   ```
2. **Settings → Pages → Source: GitHub Actions.** Senza questo il workflow
   fallisce all'ultimo passo.
3. **Settings → Secrets and variables → Actions**, due secret:
   - `SUPABASE_URL`
   - `SUPABASE_ANON_KEY`

   La anon key è pubblica per definizione: finisce comunque nel bundle
   scaricato dal browser. Sta nei secret per tenerla fuori dal sorgente, non
   perché nasconderla sia possibile. **La `service_role` key non va messa qui
   né da nessun'altra parte.**

   Senza i due secret la build riesce lo stesso e l'app resta locale.
4. Dopo il primo deploy, sulla dashboard Supabase → **Authentication → URL
   Configuration**, metti l'indirizzo pubblico in *Site URL* e *Redirect URLs*.
   Finché punta a `localhost`, il link di conferma email non funziona dal
   telefono.

### Installazione su iPhone

Safari → apri l'URL → Condividi → **Aggiungi a Home**. Da lì parte a schermo
intero, senza barra del browser, e funziona offline.

## Offline

Il service worker sta in [`web/service_worker.js`](web/service_worker.js) ed è
scritto a mano: da Flutter 3.44 quello generato non fa più cache, si disiscrive
e basta. Anche [`web/flutter_bootstrap.js`](web/flutter_bootstrap.js) è nostro,
per impedire a Flutter di registrare il proprio al posto del nostro.

Il primo caricamento scarica una decina di megabyte (CanvasKit più il codice
compilato). Dopo, tutto arriva dalla cache.
