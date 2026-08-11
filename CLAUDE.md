# CLAUDE.md — TCG Tournament Tracker

App per tracciare i tornei di Yu-Gi-Oh! e Magic: The Gathering.
Il documento di design completo è in `docs/architettura.md`: leggilo prima di lavorare
su una feature nuova, e aggiornalo quando una decisione cambia.

## Panoramica progetto

- **Scopo:** registrare tornei, round e partite libere, e analizzare i risultati
  (winrate, matchup matrix, play/draw, andamento nel tempo)
- **Giochi:** Yu-Gi-Oh! (Avanzato, Edison), Magic (Standard, Modern, Pauper, Legacy)
- **Piattaforma:** PWA installabile, costruita con Flutter web, usata principalmente da iPhone
- **Lingue:** italiano e inglese

## Stack

- **Flutter** (Dart), target web
- **Drift** (SQLite via WASM) per il database locale, offline-first
- **Supabase** (Postgres + Auth) per backup e sync tra dispositivi
- **Riverpod** per lo state management
- **go_router** per la navigazione
- **fl_chart** per i grafici
- **flutter_localizations** + **intl** per la localizzazione

## Comandi

Il Flutter SDK è installato in `C:\src\flutter` ed è già nel PATH utente.

```bash
flutter pub get                        # installa le dipendenze
flutter gen-l10n                       # rigenera le traduzioni dai file ARB
dart run build_runner build -d         # genera il codice Drift
flutter run -d chrome                  # avvia in sviluppo
flutter analyze                        # analisi statica
flutter test                           # esegue i test
flutter build web --release            # build di produzione
```

Dopo ogni modifica alle tabelle Drift va rilanciato `build_runner`, altrimenti il codice
generato resta disallineato. Dopo ogni modifica ai file ARB va rilanciato `gen-l10n`.

### Credenziali Supabase

Il sync si attiva solo se la build porta con sé le credenziali:

```bash
flutter build web --release \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJ...
```

Una build senza le due variabili è valida: l'app resta interamente locale e la schermata
Account lo dice. Non aggiungere mai la `service_role` key da nessuna parte, e non
committare le credenziali: passano solo da `--dart-define` o da
`--dart-define-from-file` con un file fuori dal repository. Setup del progetto in
`docs/supabase.md`, SQL in `docs/supabase/schema.sql`.

### Vincoli sulle versioni

- **Riverpod resta alla 2.6.1**, senza code generation. La 3.x dipende da `test`, che a
  sua volta entra in conflitto con l'`analyzer` richiesto da `drift_dev`: le due cose non
  si risolvono insieme. Non aggiornare senza aver verificato che il conflitto sia sparito.
- **`intl` è dichiarato come `any`** perché `flutter_localizations` lo pinna a una
  versione precisa fornita dall'SDK.

### Deploy

Ogni push su `main` fa girare `.github/workflows/deploy.yml`: analyze, test, build e
pubblicazione su GitHub Pages. Il `--base-href` arriva da `github.event.repository.name`,
così rinominare il repository non rompe i percorsi degli asset. Le credenziali Supabase
sono due secret del repository; senza, la build riesce e l'app resta locale.

Il workflow finisce con dei controlli che sembrano paranoia e non lo sono: ognuno copre
un guasto che si manifesta solo sul telefono, ore dopo, senza traccia nel log di build.
Uno di questi ha già colpito davvero — una build incrementale che non ricopiava un file
da `web/`.

### Service worker e offline

`web/service_worker.js` e `web/flutter_bootstrap.js` sono **scritti a mano** e non vanno
rigenerati.

Dalla 3.44 Flutter non spedisce più un service worker che fa cache: quello che genera
si disiscrive e ricarica la pagina. Continua però a registrarlo, e due service worker
sullo stesso scope si sovrascrivono a vicenda — per questo il bootstrap è nostro, chiama
`_flutter.loader.load()` senza `serviceWorkerSettings`, e registra il nostro.

La strategia **non** è un manifest di precache generato alla build: i nomi dei file di
Flutter non hanno hash di contenuto e l'insieme di file di CanvasKit cambia tra una
versione e l'altra, quindi una lista scritta a mano marcirebbe in silenzio. Ogni GET
same-origin riempie la cache mentre viene servita; dopo un caricamento completo online
c'è tutto. Le navigazioni sono network-first, così un deploy nuovo si fa notare.

La cache è intitolata al commit (`__BUILD_ID__`, sostituito dal workflow), quindi un
deploy nuovo entra in una cache nuova e la vecchia viene buttata: senza, si servirebbe
un `main.dart.js` nuovo con gli asset vecchi. **In locale il placeholder resta**, quindi
durante lo sviluppo la cache non si invalida da sola: ricarica forzata.

Le chiamate a Supabase non passano mai dalla cache — sono cross-origin e il fetch
handler esce subito. Una risposta vecchia servita offline sembrerebbe il cloud che dà
ragione a un dispositivo che invece è indietro.

### Asset web di Drift

`web/sqlite3.wasm` e `web/drift_worker.js` sono file binari scaricati a mano, non
generati dalla build. Senza di loro il database non si apre nel browser.

Le loro versioni devono corrispondere ai pacchetti risolti in `pubspec.lock`, altrimenti
si ottiene un errore solo a runtime. Attualmente: `sqlite3` 3.5.1 e `drift` 2.34.3.
Dopo un aggiornamento di quei pacchetti vanno riscaricati:

```bash
curl -L -o web/drift_worker.js https://github.com/simolus3/drift/releases/download/drift-<versione>/drift_worker.js
curl -L -o web/sqlite3.wasm    https://github.com/simolus3/sqlite3.dart/releases/download/sqlite3-<versione>/sqlite3.wasm
```

## Convenzioni di codice

- **Naming:** `lowerCamelCase` per variabili e funzioni, `UpperCamelCase` per classi e
  enum, `snake_case` per i nomi dei file
- **Formattazione:** `dart format`, riga da 80 colonne
- **Lint:** `flutter_lints`, configurato in `analysis_options.yaml`
- **Immutabilità:** i modelli di dominio sono immutabili, con `copyWith`
- **Null safety:** niente `!` per forzare i nullable, usare pattern matching o early return
- **Stringhe UI:** mai hardcoded, sempre da `AppLocalizations`

## Vincoli architetturali

- La UI non accede mai a Drift o a Supabase direttamente: passa sempre dai repository
  in `lib/data/repositories/`
- Le regole di calcolo delle statistiche vivono solo in `lib/core/stats/` e non vengono
  riscritte nelle singole schermate
- Ogni schermata deve funzionare senza rete
- La barra di navigazione è una pillola che **galleggia sopra** il corpo
  (`extendBody: true`), così l'app si vede tutt'intorno. Ogni schermata che
  scorre deve quindi lasciarle posto da sola: `.clearingFloatingBar` sul padding
  di ciò che scorre, e `LiftedFab` intorno a un FAB. Le misure stanno solo in
  `shared/layout/floating_bar_inset.dart`, costanti e non lette da `MediaQuery`,
  perché lo `Scaffold` azzera il padding inferiore nello slot del FAB — cioè
  proprio dove serve. Dimenticarsene su una schermata rende irraggiungibile
  l'ultima riga della sua lista
- Un mazzo, un formato o un archetipo con dati storici collegati si archivia, non si
  cancella: lo storico dei tornei deve restare leggibile
- Il **contatore punti vita** (`features/life/`) non scrive niente nel database: è uno
  strumento da tavolo, non una registrazione. Le regole che dipendono dal gioco (vita
  iniziale, passi, preset) stanno solo in `core/life/life_rules.dart`

## Regole di dominio

- I **bye** sono esclusi da ogni calcolo di winrate ma restano nel record del torneo,
  mostrato come `5-2 (1 bye)`
- I **punti** di un torneo sono 3 per vittoria, 1 per pareggio, 0 per sconfitta. Un bye
  vale 3 punti come una vittoria: è l'unico posto in cui un bye conta qualcosa, perché
  è così che lo assegna l'organizzatore e il punteggio deve corrispondere alla classifica
  che l'utente ha davanti
- I match di **top cut** contano nelle statistiche come i round svizzeri. Non si chiede
  all'utente se un round è di top cut: si deduce da `hasTopCut` e dal numero di round
  oltre i round svizzeri previsti
- Il **tipo di evento** è obbligatorio alla creazione di un torneo e non ha default: è
  l'unica cosa di un torneo che non si può dedurre da nient'altro
- I **tipi di evento e le dimensioni del top cut dipendono dal gioco** e vivono solo in
  `core/tournaments/event_options.dart`. `EventType` contiene l'unione dei due circuiti
  perché la colonna è una sola; non aggiungere voci direttamente nelle schermate
- Il **mazzo dell'avversario** è obbligatorio in ogni round che non sia un bye, e si
  sceglie da un menu, mai a testo libero: la matchup matrix è leggibile solo se lo stesso
  mazzo si chiama sempre allo stesso modo. Le voci sono l'unione degli archetipi già
  incontrati e degli archetipi dei mazzi dell'utente, più "Altro" per crearne uno nuovo
- Le **partite libere** sono escluse dalle analisi, e non esiste un filtro per includerle:
  nessuna schermata ne registra da quando il contatore punti vita ha sostituito il
  recorder. L'esclusione vive in un punto solo, la query di `AnalyticsRepository`
- Ogni **winrate va sempre mostrato col campione** su cui è calcolato. Sotto le 5 partite
  decise (`Analytics.smallSample`) la cifra si attenua, non si nasconde
- Le regole delle analisi stanno solo in `core/stats/analytics.dart`, e ogni figura della
  sezione nasce dalla stessa singola query: due numeri sullo schermo non devono mai poter
  venire da insiemi di dati diversi
- Il record di un torneo non è un campo salvato: si calcola sempre dai match

## Sync

- Il sync manda **l'intero database come un documento solo**, che è lo stesso JSON
  dell'export manuale. Non è un merge riga per riga, ed è una scelta, non una
  semplificazione temporanea: vedi la sezione 11 di `docs/architettura.md`
- Un push è accettato dal server **solo se il cloud è ancora alla revisione che il
  dispositivo dichiara**. Quando non lo è, l'app mostra un conflitto e lascia scegliere:
  nessuna delle due copie viene scartata in automatico
- L'unico punto che parla con Supabase è `SupabaseSyncBackend`, dietro l'interfaccia
  `SyncBackend`. Tutto il resto del codice non conosce Supabase, ed è quello che rende
  il sync testabile senza rete
- Le scritture dell'apertura del database (migrazione, `_repairSchema`, seed) e quelle
  di un pull **non contano come modifiche locali**. Se un giorno una di queste due
  esclusioni salta, l'app rispedisce il proprio database a ogni avvio o all'infinito
- Uscire dall'account non cancella mai i dati locali

## Migrazioni del database

Lo schema è alla **versione 4**. Ogni cambio di schema richiede:

1. incrementare `schemaVersion` in `lib/data/db/app_database.dart`
2. aggiungere il passo corrispondente in `onUpgrade`, sempre dentro un `if (from < N)`
3. aggiungere un test in `test/data/migration_test.dart`, che ricostruisce a mano lo
   schema della versione precedente e lascia che l'app lo aggiorni davvero

Il terzo punto non è opzionale: il browser dell'utente contiene già un database della
versione precedente, e l'aggiornamento è l'unica parte del rilascio che non si può
ritentare.

Una colonna nuova arriva col suo default, e quello di `is_system` è `false`. Per questo
la migrazione a 4 chiama `Seed.markSystemGames`, e `_repairSchema` la richiama quando è
appena aggiunto una colonna a `games`: senza, i due giochi di sistema tornerebbero
eliminabili.

All'apertura gira anche `_repairSchema`, che confronta lo schema dichiarato con quello
realmente presente e aggiunge tabelle e colonne mancanti. Non sostituisce le migrazioni:
è la rete di sicurezza per un database il cui `user_version` mente, stato in cui un
browser è già finito davvero e da cui l'app non poteva più uscire. Aggiunge soltanto, non
riscrive né cancella mai niente.

Se il backup cambia forma, va incrementato anche `BackupService.formatVersion`.

## Giochi e formati

Yu-Gi-Oh! e Magic arrivano dal seed e sono `is_system`; giochi e formati dell'utente si
aggiungono da Impostazioni → Gestisci giochi e formati. La regola che tiene insieme
tutto è una sola:

**una voce nascosta sparisce da ogni posto in cui se ne *sceglie* una, e resta ovunque
ci siano già dati che la indicano.**

In pratica, provider distinti e nessuna eccezione sparsa:

- `gamesProvider` / `formatsProvider` — solo attivi. Menu di scelta e chip dei filtri
- `allGamesProvider` / `allFormatsProvider` — nascosti inclusi. Solo per rileggere un
  nome: la riga di un mazzo o di un torneo deve continuare a dire in che gioco e in che
  formato è, anche se quella voce è stata nascosta dopo
- `editableFormatsProvider` — attivi più quello che il record in modifica già indica.
  Senza quest'ultimo pezzo, aprire un mazzo il cui formato è stato nascosto non
  troverebbe la voce corrispondente, ripiegherebbe in silenzio sul primo formato della
  lista, e lo salverebbe in un formato che nessuno ha scelto. Non esiste
  l'equivalente per i giochi, ed è voluto: il gioco di un record è fissato alla
  creazione e i due editor nascondono il selettore quando c'è qualcosa da modificare
- `analyticsGameProvider` / `analyticsFormatProvider` — il gioco e il formato su
  cui le analisi stanno davvero riferendo. La sezione **non** offre "tutti e due
  i giochi" né "tutti i formati": un gioco e un formato sono sempre in
  vigore, anche prima che l'utente scelga e anche se quello scelto è stato
  nascosto dopo. Ripiegano sul primo visibile senza riscrivere la scelta
  salvata, così riattivare la voce riporta la sezione dov'era. I chip devono
  mostrare questi, non `AnalyticsSelection`, altrimenti i numeri risponderebbero
  a una domanda che sullo schermo non è scritta
- `deckGameProvider` — il gioco che la libreria mostra davvero. Il filtro ricorda un id
  e quel gioco può venire nascosto dopo: leggere il filtro direttamente lascerebbe la
  libreria su un gioco senza chip da cui spostarsi. Ripiega sul primo gioco visibile e
  non tocca il filtro, così riattivare il gioco lo ripristina

Nascondere è l'operazione normale, eliminare è l'eccezione. `deleteGame` e
`deleteFormat` rifiutano quando la voce è di sistema o contiene mazzi/tornei, e
`deleteGame`/`setGameActive` rifiutano anche di lasciare zero giochi visibili — senza
giochi nessun editor avrebbe niente da offrire e la schermata che potrebbe rimediare
passa dagli stessi menu. Il rifiuto torna come `CatalogDeletionResult`, non come
eccezione, perché è uno stato che la schermata mostra. Eliminare un formato porta via i
suoi archetipi; eliminare un gioco porta via formati e archetipi: sono liste di nomi,
non partite giocate.

### Cosa dipende dall'id del gioco

Un gioco creato dall'utente non ha regole scritte per lui. I tre punti che le
contengono hanno tutti un fallback esplicito, mai un `else` accidentale:

- `core/life/life_rules.dart` — vita iniziale, passi, preset. Fallback: le regole Magic
- `core/tournaments/event_options.dart` — tipi di evento e top cut. Fallback: la lista
  neutra `_fallback` e i top cut corti
- `theme.dart` → `gameAccent(gameId)` — colore identitario. I due giochi di sistema
  hanno il loro, gli altri pescano da `AppColors.extraAccents` con un indice ricavato
  dai code unit dell'id (che è un uuid): stabile tra un avvio e l'altro, cosa che
  `hashCode` non garantisce

## Archetipi di default

`ArchetypeSeed` contiene la lista di archetipi avversari con cui l'app parte, una per
formato, scritta dall'utente e **da lasciare com'è scritta**: quei nomi finiscono nella
matchup matrix, e una "correzione" silenziosa diventa un mazzo che l'utente non riconosce.

- Vengono applicati **una volta sola**, alla creazione del database e nella migrazione a
  schema 3. Non fanno parte di `Seed.apply`, che gira a ogni apertura: un default che
  torna dopo essere stato cancellato sarebbe peggio di nessun default
- L'applicazione **sostituisce** la lista esistente, con una sola eccezione non
  negoziabile: un archetipo a cui punta un match non viene mai cancellato. Quel round è
  stato giocato davvero contro quel mazzo
- Nascono con `times_faced` a zero, quindi non scavalcano nei suggerimenti gli archetipi
  davvero incontrati
- Gli id sono slug (`mtg-legacy/oops-all-spells`), quindi riapplicare la lista non può
  duplicarla. I test verificano che dentro un formato non ci siano né nomi né slug ripetuti
- Il conteggio "questo dispositivo ha dati suoi" del sync **non** guarda gli archetipi,
  altrimenti ogni installazione nuova sembrerebbe piena e ogni primo accesso finirebbe in
  conflitto invece che in uno scaricamento
- La lista compare in due posti oltre al round editor: il primo livello della libreria
  mazzi elenca **tutti** gli archetipi del formato, anche quelli senza mazzi, e il campo
  archetipo dell'editor mazzi è lo stesso menu, non più testo libero

## Trappole note nei test

- **Non aspettare mai uno stream Drift dentro un `testWidgets`.** Drift tiene in vita le
  sue stream query con un timer, e l'orologio finto del widget test non lo fa mai
  scattare: `await repository.watchX().first` resta appeso per sempre. Per leggere dal
  database dentro un widget test si usa una query one-shot (`select(...).get()`).
- Ogni schermata che mostra dati va **sempre svuotata a fine test** (`unmount`), sennò
  il timer di Drift viene segnalato come pendente.

## Struttura directory

```
lib/
  app/            router, tema, bootstrap
  l10n/           file ARB italiano e inglese
  core/
    stats/        regole di calcolo di winrate, record, matchup
    utils/        estensioni e formattazione
  data/
    db/           tabelle Drift, DAO, migrazioni, seed
    models/       modelli di dominio
    repositories/ unica porta di accesso ai dati per la UI
    sync/         livello Supabase
  features/       dashboard, tournaments, matches, decks, analytics, settings
  shared/         widget riutilizzabili, form, filtri
docs/             documentazione di progetto
test/
```

Ogni feature contiene `presentation/` per le schermate e i widget, e `providers/` per
lo stato Riverpod.

## Note

- Non serve alcun Mac, Xcode o account sviluppatore Apple: il target è la PWA
- Su iOS il browser può eliminare i dati locali dopo periodi di inattività, quindi il
  backup verso Supabase e l'export JSON sono funzionalità critiche, non accessorie
