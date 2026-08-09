# TCG Tournament Tracker — Architettura

Documento di riferimento per l'app di tracking tornei di Yu-Gi-Oh! e Magic: The Gathering.
Da aggiornare a ogni decisione di design.

## 1. Decisioni prese

| Ambito | Scelta | Motivo |
|---|---|---|
| Framework | Flutter (Dart) | Cross-platform, sviluppo da Windows |
| Piattaforma target | **PWA installabile** (Flutter web), usata da iPhone | Evita del tutto Xcode e i 99 USD/anno di Apple |
| Distribuzione | Hosting statico gratuito (Cloudflare Pages / Netlify / Vercel), installazione da Safari via "Aggiungi a Home" | Nessun App Store, nessun account sviluppatore |
| Build iOS nativa | Rimandata, opzionale | Il codice Flutter resta riutilizzabile se in futuro si vorrà pubblicare su App Store |
| DB locale | Drift (SQLite via WASM su web) | Offline-first, query SQL per le analisi |
| Backend | Supabase (Postgres + Auth) | Backup e sync tra dispositivi |
| Auth | Email + password (Supabase Auth) | Sync richiede identità utente |
| State management | Riverpod | Standard de facto, testabile |
| Routing | go_router | Deep link e navigazione dichiarativa |
| Grafici | fl_chart | Grafici winrate e andamento temporale |
| Lingue | Italiano e inglese, `flutter_localizations` + file ARB | Interfaccia bilingue, lingua di sistema come default con override in Impostazioni |
| Modello mazzi | Nome + archetipo (no decklist carte) | Inserimento rapido |
| Modello partite | Match a round, formato svizzero | Granularità match, non singolo game |

### Strategia offline-first

L'app funziona interamente su SQLite locale (su web: sqlite3 WASM con persistenza in
IndexedDB, o OPFS dove disponibile). Nessuna schermata deve rompersi senza rete.

### Rischio persistenza su iOS — importante

Safari su iOS può eliminare i dati dei siti web dopo circa 7 giorni di inattività.
L'installazione sulla schermata Home riduce molto il rischio ma non lo azzera, e iOS
non offre garanzie di persistenza (`navigator.storage.persist()` non è affidabile lì).

Conseguenza pratica: su PWA il backup non è un lusso da rimandare, è parte del prodotto.
Per questo la roadmap anticipa due cose rispetto a un'app nativa:

1. Export e import JSON manuale già in fase F2, come rete di sicurezza immediata.
2. Sync Supabase promossa a fase F5, prima della sezione analisi, così i dati veri
   inseriti durante l'uso quotidiano sono già replicati sul server.

Supabase diventa quindi la copia autorevole dei dati, e SQLite locale la cache veloce
che permette all'app di funzionare offline.

## 2. Modello dati

### games
Giochi supportati: i due di sistema più quelli aggiunti dall'utente da Impostazioni.

| Campo | Tipo | Note |
|---|---|---|
| id | text (PK) | slug `ygo`/`mtg` per i seed, uuid per gli altri |
| name | text | "Yu-Gi-Oh!", "Magic: The Gathering" |
| is_system | bool | arriva col seed, non si elimina |
| is_active | bool | nascosto dai menu, mai cancellato |
| sort_order | int | |

### formats
Formati per gioco. Seed di sistema + formati aggiunti dall'utente da Impostazioni.

| Campo | Tipo | Note |
|---|---|---|
| id | text (PK) | uuid, o slug per i seed |
| game_id | text (FK games) | |
| name | text | "Avanzato", "Edison", "Standard", "Modern", "Pauper", "Legacy" |
| is_system | bool | true per i seed, non cancellabili |
| is_active | bool | permette di nascondere un formato senza perdere lo storico |
| sort_order | int | |

Seed iniziale: YGO → Avanzato, Edison. MTG → Standard, Modern, Pauper, Legacy.

### decks
Libreria mazzi dell'utente. Scoped per gioco + formato.

| Campo | Tipo | Note |
|---|---|---|
| id | text (PK) | uuid |
| game_id | text (FK) | |
| format_id | text (FK) | |
| name | text | nome dato dall'utente, es. "Izzet Prowess v3" |
| archetype | text | archetipo canonico, es. "Izzet Prowess" — usato nelle analisi |
| colors | text nullable | solo MTG, es. "UR" |
| notes | text nullable | |
| photo | blob nullable | foto del mazzo fisico, già ridimensionata |
| photo_mime_type | text nullable | |
| is_active | bool | archivia senza cancellare, lo storico resta valido |
| created_at | datetime | |
| updated_at | datetime | |

Un mazzo non si cancella mai fisicamente se ha tornei o partite collegate: si archivia.

La foto sta dentro la riga e non in uno store separato, così viaggia col backup: un
ripristino che perdesse tutte le foto sarebbe un ripristino a metà. Per non gonfiare gli
export, il picker la **ridimensiona a 1280 px sul lato lungo e la ricodifica in JPEG**
prima ancora che arrivi al database.

### deck_cards
Lista carte importata da un file di testo. Cancellata in cascata col mazzo.

| Campo | Tipo | Note |
|---|---|---|
| id | text (PK) | |
| deck_id | text (FK decks, ON DELETE CASCADE) | |
| section | enum | `main`, `side`, `extra`, `commander` |
| name | text | nome carta, salvato esattamente come scritto nel file |
| quantity | int | |
| sort_order | int | posizione nella sezione, preserva l'ordine del file |

L'app **non valida i nomi delle carte**: non ha un database carte, e una lista che
fallisce l'import per un errore di battitura sarebbe peggio di una che importa
esattamente ciò che il file diceva.

### opponent_archetypes
Archetipi avversari conosciuti, per gioco + formato. Fondamentale: senza una lista
controllata la matchup matrix si frammenta in decine di varianti scritte a mano.

| Campo | Tipo | Note |
|---|---|---|
| id | text (PK) | |
| game_id | text (FK) | |
| format_id | text (FK) | |
| name | text | es. "Snake-Eye", "Boros Energy" |
| times_faced | int | contatore denormalizzato, ordina i suggerimenti per frequenza |

L'inserimento di un match permette di scegliere da questa lista o creare una nuova voce
al volo, che viene salvata qui.

L'app parte con una lista già pronta per ogni formato (`ArchetypeSeed`), scritta a mano
sui metagame realmente giocati. È l'unico seed che viene applicato **una volta sola** —
alla creazione del database e nella migrazione a schema 3 — invece che a ogni apertura:
un metagame ruota, e un default che ricompare dopo essere stato cancellato sarebbe
peggio del non averlo.

L'applicazione della lista sostituisce quello che trova, tranne gli archetipi a cui punta
un match: quelli restano, perché quel round è stato giocato davvero contro quel mazzo. I
default nascono con `times_faced` a zero, così non scavalcano nei suggerimenti i mazzi
davvero incontrati.

Conseguenza sulla UI: con sessanta voci per formato, l'opzione "crea un archetipo nuovo"
non può essere l'ultima riga del menu — sarebbe lontana da scorrere e, peggio, il filtro
la nasconderebbe proprio quando serve, cioè quando si sta scrivendo un nome che nella
lista non c'è. È quindi un pulsante accanto al menu.

### tournaments

| Campo | Tipo | Note |
|---|---|---|
| id | text (PK) | |
| game_id | text (FK) | |
| format_id | text (FK) | |
| deck_id | text (FK decks) | mazzo giocato |
| name | text | nome evento |
| date | date | |
| event_type | enum | `locale`, `regionale`, `nazionale`, `online` |
| participant_count | int nullable | |
| rounds_planned | int | numero round svizzeri previsti |
| has_top_cut | bool | |
| top_cut_size | int nullable | 8, 4, 2 |
| final_standing | int nullable | piazzamento finale |
| status | enum | `pianificato`, `in_corso`, `concluso` |
| notes | text nullable | |

Record finale (V-S-P) non è un campo: si calcola dai match. Evita disallineamenti.

### matches
Un record per match. Copre sia i round di torneo sia le partite libere.

| Campo | Tipo | Note |
|---|---|---|
| id | text (PK) | |
| tournament_id | text nullable (FK) | null = partita libera |
| game_id | text (FK) | |
| format_id | text (FK) | |
| deck_id | text (FK) | mio mazzo |
| round_number | int nullable | null per partite libere |
| is_top_cut | bool | |
| opponent_name | text nullable | facoltativo |
| opponent_archetype_id | text nullable (FK) | |
| on_the_play | bool nullable | ho iniziato io il primo game |
| games_won | int | |
| games_lost | int | |
| games_drawn | int | |
| result | enum | `vittoria`, `sconfitta`, `pareggio`, `bye` — derivato ma salvato per query rapide |
| played_at | datetime | |
| notes | text nullable | |

`game_id`, `format_id` e `deck_id` sono ridondanti rispetto al torneo, ma servono a
interrogare uniformemente match di torneo e partite libere senza join condizionali.

## 3. Sezioni dell'app

Navigazione principale: bottom navigation a 5 voci. Le due azioni di creazione stanno
su un FAB contestuale, non nella barra.

### Home / Dashboard
Punto d'ingresso. Torneo in corso se esiste (con pulsante "registra round"), ultimi
risultati, winrate del mazzo più giocato negli ultimi 30 giorni, accesso rapido a
"Nuovo torneo" e "Nuova partita".

### Nuovo torneo
Form unico a sezioni nell'ordine: gioco → formato → mazzo (dalla libreria filtrata per
gioco e formato) → dati evento (nome, data, tipo, round previsti, top cut, partecipanti).

Era previsto un wizard a step: è diventato un form unico perché i campi sono otto e
poterli vedere e correggere tutti prima di salvare vale più di quattro schermate da
sfogliare.

Alla conferma il torneo nasce **in corso** e si apre direttamente sul dettaglio, che è
dove serve stare: la cosa successiva che si fa è registrare il round 1. Senza almeno un
mazzo in libreria il salvataggio è disabilitato, con la spiegazione del perché.

### Gestione tornei
Lista tornei con filtri per gioco, formato, mazzo, periodo, tipo evento. Dettaglio
torneo: intestazione con record calcolato e piazzamento, elenco round con risultato,
aggiunta o modifica round, chiusura torneo con piazzamento finale.

### Nuova partita
**Non** è una registrazione: è lo strumento da tavolo che si tiene aperto mentre si
gioca. Conta i life points di Yu-Gi-Oh! e i punti vita di Magic, e porta con sé le
piccole cose che servono a una partita.

È l'unica schermata dell'app che **non scrive nulla nel database**: esiste per i venti
minuti che dura la partita, non per il record che lascia. Lo stato vive in un provider
Riverpod, così passare dalla lista tornei e tornare non azzera i totali, ma non è
persistito: ritrovare i totali di ieri sarebbe peggio che non trovarne nessuno.

Solo 1v1: due posti, quello dell'avversario ruotato di 180° perché il telefono sta in
mezzo al tavolo e chi legge è dall'altra parte.

- **Vita iniziale** — 8000 per Yu-Gi-Oh!, 20 per Magic, modificabile prima di iniziare.
  Preset rapidi: 8000/4000/2000 e 20/40/30.
- **Passo** — quanto vale un tocco: 50/100/500/1000 per Yu-Gi-Oh!, 1/2/5/10 per Magic.
  Un solo set di pulsanti per entrambi renderebbe uno dei due inutilizzabile.
- **Contatori** — veleno, energia, esperienza, segnalini. Compaiono solo se messi in
  gioco e non scendono mai sotto zero.
- **Dado** — d4, d6, d8, d10, d12, d20. **Moneta** — testa o croce.
- **Timer del round** — 30/40/50/55/60 minuti, nella barra in alto perché va guardato senza
  aprire niente. Il ticker esiste solo mentre il timer corre.
- **Cronologia** — ogni variazione, tiro e lancio, con il totale risultante. L'annulla
  toglie l'ultima modifica a un totale ma **non** tocca dadi e monete: quelli sono il
  verbale di cosa è successo al tavolo, non un errore da correggere.

La vita può andare sotto zero e l'app non dichiara conclusa la partita: chi è a 0 può
ancora guadagnarne prima che qualcuno conceda.

Le regole che dipendono dal gioco vivono solo in `core/life/life_rules.dart`.

> Nota: la colonna `matches.tournament_id` resta nullable e il repository sa ancora
> leggere le partite fuori torneo, ma **nessuna schermata le registra**. Il filtro
> "competitivo / libero" previsto per la sezione analisi non ha quindi niente da
> filtrare finché non esisterà un modo per inserirle.

### Analisi
Filtri globali persistenti: gioco, formato, mazzo, periodo (30 giorni / 90 / 1 anno /
sempre). Sono ricordati tra una sessione e l'altra perché sono una domanda, non uno stato
di vista: chi segue Edison guarda Edison ogni volta.

Tutti i filtri sono facoltativi e il gioco parte da **entrambi**, a differenza di ogni
altra schermata: la prima domanda a cui questa sezione risponde è "come sto andando", e
restringere è la seconda.

1. **Riepilogo** — winrate match e winrate game, con il campione sempre accanto, e il
   record come barra vittorie/pareggi/sconfitte. Una barra proporzionale e non un
   riempimento singolo: un 50% fatto di pareggi e uno fatto di vittorie e sconfitte sono
   due stagioni diverse.
2. **Per mazzo** — compare solo con più di un mazzo giocato, ordinato per quanto è stato
   usato.
3. **Matchup matrix** — griglia mio archetipo × archetipo avversario, colorata per
   winrate, con il numero di match nella cella. La prima colonna resta ferma e il resto
   scorre di lato: su un telefono la griglia è sempre più larga dello schermo, e una riga
   di cui non si vede il mazzo non si legge.
4. **Play/Draw** — winrate iniziando e rispondendo, con la differenza in punti. Le
   partite in cui non è stato annotato chi ha iniziato restano contate a parte, mai
   spostate in uno dei due gruppi.
5. **Andamento** — winrate match mese per mese. I mesi non giocati non compaiono: un mese
   senza partite non è un mese di sconfitte.
6. **Meta locale** — quali archetipi si sono davvero visti dall'altra parte del tavolo,
   con quante volte e come è andata.

Ogni figura nasce da **una sola query**: i numeri sullo schermo non possono venire da
insiemi di dati diversi. Le regole di calcolo stanno solo in `core/stats/analytics.dart`.

**Il campione non è mai opzionale.** Un winrate senza il numero di partite dietro è il
modo più rapido per farsi un'idea sbagliata da tre game. Sotto le 5 partite decise il
numero viene mostrato ma visibilmente attenuato: non è una soglia per nascondere niente,
due partite restano due partite, ma un 100% su due non deve leggersi come un 100% su
quaranta.

**Competitivo / libero: filtro non presente.** Contano solo i round di torneo. Da quando
il contatore punti vita ha sostituito la registrazione delle partite libere, nessuna
schermata ne crea una, quindi il filtro sarebbe un comando senza niente dietro. La
colonna `matches.tournament_id` resta nullable e la query esclude esplicitamente le righe
con torneo nullo, quindi il giorno in cui le partite libere torneranno basta aggiungere
il filtro.

Le partite senza archetipo avversario — possibili solo da un backup ripristinato, visto
che il round editor lo pretende — contano nel winrate ma non nella matrice né nel meta:
una partita giocata è una partita giocata, ma non si può attribuire a un matchup.

### Editor mazzi
La libreria è **a due livelli**. Il primo elenca gli **archetipi**, uno per riga, con
quanti mazzi contengono e in quali formati; toccandone uno si apre l'elenco dei mazzi di
quell'archetipo. Trenta mazzi letti come trenta righe sono un muro, letti come otto
archetipi sono uno scaffale.

Il primo livello elenca **tutti** gli archetipi del formato, non solo quelli in cui c'è
un mazzo: è il catalogo di ciò che si gioca, e un archetipo ancora vuoto è esattamente il
posto in cui va archiviato il primo mazzo che ci si costruisce. Le righe vuote sono
disegnate più in sordina, e aprendole il pulsante "nuovo mazzo" arriva con l'archetipo
già compilato.

Il raggruppamento ignora maiuscole e spazi. **Prima gli archetipi con dei mazzi**,
nell'ordine della lista — quello aggiornato più di recente in cima — e poi tutto il resto
in ordine alfabetico, che è l'unico ordine utile per un catalogo di duecento voci che
nessuno ha ancora toccato.

L'archetipo di un mazzo si sceglie **dallo stesso menu degli avversari**, non si scrive:
è quello il campo su cui le analisi raggruppano, e "Snake-Eye" scritto qui con
"Snake-Eye Fire King" scritto di là diventano due righe di una matchup matrix che
avrebbe dovuto averne una. Cambiando gioco o formato la scelta si azzera, perché le liste
sono per formato.

Filtri gioco e formato agiscono sul primo livello e restano in vigore dentro
l'archetipo, che quindi mostra esattamente i mazzi che la sua riga contava. Il pulsante
"nuovo mazzo" dentro un archetipo apre l'editor con l'archetipo già compilato. Creazione, modifica, archiviazione,
duplicazione di un mazzo. Da qui si gestisce anche la lista degli archetipi avversari
per formato.

### Impostazioni
Lingua, tema, account e sync, backup su file, e il catalogo dei formati. I formati
restano visibili qui invece di vivere solo un tocco più in là: quali formati esistono
è la cosa che si va a controllare nove volte su dieci, e la riga che apre l'editor sta
in fondo per la decima.

La riga dell'account porta con sé lo stato del sync — accedi, modifiche in attesa,
tutto salvato, conflitto — invece di nasconderlo un tocco più in là: su una PWA la
copia nel cloud è l'unica che il browser non può buttare via, quindi sapere se è
aggiornata non deve richiedere di andarla a cercare.

### Gestione giochi e formati
Una scheda per gioco con i suoi formati dentro, ed è l'unico posto dell'app in cui
compaiono anche le voci nascoste — perché è l'unico da cui si possono far tornare. Ogni
riga porta rinomina, nascondi/mostra ed elimina, e sotto il nome quanti mazzi e quanti
tornei la indicano: è quel numero a decidere se l'eliminazione può riuscire.

Un gioco nuovo nasce **senza formati**: l'app non sa niente di quel gioco, quindi non
ne inventa. I formati si aggiungono dalla riga sotto, nella stessa scheda.

Nascondere è l'operazione normale, eliminare è l'eccezione. Una voce di sistema non si
elimina mai, e una voce che contiene mazzi o tornei nemmeno: quella partita è stata
giocata davvero lì, e un match in un formato che il database non conosce più è un match
che non si può più leggere. In più, l'ultimo gioco visibile non si può né nascondere né
eliminare: senza giochi nessun editor avrebbe niente da offrire, e la schermata che
potrebbe rimediare passa dagli stessi menu. L'elimina resta comunque nel menu di ogni
riga: un menu le cui voci vanno e vengono non insegna niente, un rifiuto che dice il
motivo sì.

Una voce nascosta sparisce da ogni posto in cui se ne sceglie una — menu degli editor,
chip dei filtri — e resta ovunque ci siano già dati che la indicano. Gli editor fanno
un'eccezione sola, e obbligata: il formato che il record in modifica già indica resta
selezionabile anche se nascosto, altrimenti aprire quel mazzo lo salverebbe in silenzio
nel primo formato della lista.

Un gioco creato dall'utente non ha regole scritte per lui: prende i valori Magic per il
contatore punti vita, la lista neutra di tipi evento, e un colore da una piccola
tavolozza scelto in modo stabile dal suo id.

### Account e sync
Registrazione ed accesso con email e password, stato della sincronizzazione, sync
manuale, interruttore del sync automatico, e i due pulsanti che risolvono un conflitto.
Il dettaglio del modello sta nella sezione 11; la procedura per collegare un progetto
Supabase sta in [`supabase.md`](supabase.md).

## 4. Struttura del progetto

```
tcg-tracker/
  lib/
    main.dart
    app/              router, tema, bootstrap
    l10n/             file ARB italiano e inglese
    core/
      stats/          regole di calcolo winrate, record, matchup (vedi sezione 7)
      utils/          estensioni, formattazione date e numeri
    data/
      db/             Drift: tabelle, DAO, migrazioni, seed
      models/         modelli di dominio
      repositories/   accesso dati, unica porta verso la UI
      sync/           backend Supabase, stato e controller del sync
    features/
      dashboard/
      tournaments/
      matches/
      decks/
      analytics/
      settings/
    shared/           widget riutilizzabili, form, filtri
  test/
  docs/
```

Ogni feature contiene `presentation/` (schermate e widget) e `providers/` (Riverpod).
La UI non tocca mai Drift direttamente: passa sempre dai repository.

## 5. Prerequisiti di sviluppo

1. **Flutter SDK** — https://docs.flutter.dev/get-started/install/windows
2. **Chrome** — ambiente di test principale: `flutter run -d chrome`
3. **Account hosting gratuito** — Cloudflare Pages, Netlify o Vercel. Serve dalla fase F8.

Nessun Mac, nessun Xcode, nessun account sviluppatore Apple, nessun costo.
Verifica dopo l'installazione: `flutter doctor` (gli avvisi su Android e Visual Studio
si possono ignorare, il target è il web).

Android Studio non è necessario. Va installato solo se in futuro si vorrà una build
Android nativa.

## 6. Roadmap

| Fase | Contenuto | Stato |
|---|---|---|
| F0 | Setup progetto Flutter web, dipendenze, tema, routing, localizzazione it/en, manifest PWA | **fatto** |
| F1 | Modello dati Drift su web, migrazioni, seed giochi e formati | **fatto** |
| F2 | Editor mazzi + archetipi avversari + export/import JSON | **fatto** |
| F3 | Nuovo torneo + gestione tornei + registrazione round | **fatto** |
| F4 | Contatore punti vita + dado, moneta, timer, cronologia | **fatto** |
| F5 | Supabase: auth, sync, backup (anticipata per il rischio di eviction su iOS) | **fatto** |
| F6 | Sezione analisi | **fatto** |
| F7 | Impostazioni + formati personalizzati | **fatto** |
| F8 | Deploy su hosting, icone, service worker, installazione su iPhone | da fare |

Fase opzionale futura: build iOS nativa, se un giorno si vorrà l'App Store. Richiede
un Mac o un servizio CI macOS più l'Apple Developer Program.

## 7. Regole di calcolo

Regole decise, da rispettare ovunque nel codice. Vivono in un unico punto
(`core/stats/`), non riscritte schermata per schermata.

### Bye

Un bye ha `result = 'bye'` e nessun archetipo avversario.

- **Escluso** da tutti i calcoli di winrate, match e game.
- **Escluso** dalla matchup matrix e dalle statistiche play/draw.
- **Incluso** nel record del torneo, mostrato in modo esplicito: `5-2 (1 bye)`.
- **Incluso** nel conteggio dei round giocati.
- **Incluso** nei punti del torneo, dove vale 3 punti come una vittoria.

Il denominatore del winrate è quindi il numero di match con esito reale, non il numero
di round. Ogni schermata che mostra un winrate deve poter mostrare anche il campione su
cui è calcolato, per rendere evidente la differenza.

### Punti del torneo

3 punti una vittoria, 1 il pareggio, 0 la sconfitta. Vivono in `MatchRecord.points` e
sono mostrati accanto al record, sia nel dettaglio del torneo sia nella lista.

I punti sono l'**unica** eccezione alla regola del bye: lì un bye vale come una vittoria,
perché è così che lo assegna l'organizzatore e il punteggio mostrato dall'app deve
corrispondere alla classifica che l'utente ha davanti. Le analytics restano intoccate:
winrate, matchup matrix e play/draw continuano a ignorare i bye del tutto.

### Top cut

I match di top cut entrano nelle statistiche esattamente come i round svizzeri. Nessun
filtro dedicato nell'interfaccia.

Il campo `is_top_cut` resta salvato sul match, ma **non viene chiesto all'utente**: si
deduce dal torneo, cioè un round oltre i round svizzeri previsti in un torneo che ha un
top cut. Serve a ricostruire il tabellone nel dettaglio del torneo, e lascia aperta la
possibilità di aggiungere un filtro in futuro senza migrare i dati.

### Mazzo dell'avversario

Obbligatorio in ogni round tranne il bye, che è l'unico round senza avversario.

Si sceglie da un menu a tendina filtrabile, **mai** a testo libero: un campo libero
garantisce che lo stesso mazzo venga scritto in tre modi diversi, e la matchup matrix
diventa illeggibile. Le voci offerte sono l'unione, senza duplicati e ignorando
maiuscole, di:

- gli archetipi già incontrati in quel gioco e formato, ordinati per quante volte sono
  stati incontrati, perché il meta locale si ripete;
- gli archetipi dei mazzi dell'utente, che è dove quei nomi vengono curati.

Accanto al menu c'è un **pulsante +** che apre un dialogo per un archetipo non ancora in
lista. Il nuovo archetipo viene salvato subito in `opponent_archetypes`, non solo insieme
al round, così è disponibile ovunque e compare nella sezione archetipi.

Era l'ultima voce del menu, ed è diventato un pulsante quando la lista di default ha
portato le voci a decine per formato: in fondo a sessanta righe era lontanissima, e il
filtro del menu la faceva sparire appena si scriveva un nome che nella lista non c'era —
cioè esattamente nel momento in cui serviva.

### Tipo di evento

Obbligatorio alla creazione di un torneo, senza valore di default. È l'unico dato di un
torneo che non si può dedurre da nient'altro, e un default silenzioso archivierebbe ogni
evento come "locale" senza che l'utente se ne accorga.

I due giochi condividono la colonna `event_type` ma non il circuito, quindi le voci
offerte dipendono dal gioco e vivono in `core/tournaments/event_options.dart`:

| | Tipi | Top cut |
|---|---|---|
| **Yu-Gi-Oh!** | Locale, Online, OTS, Regionale, Nazionale, Continentale, Mondiale | 4, 8, 16, 32, 64 |
| **Magic** | Locale, Store Championship, Showdown, Regionale, PTQ, Mondiale, Online | 4, 8, 16 |

L'enum `EventType` contiene l'unione di entrambi, perché una sola colonna li salva
entrambi. Cambiando gioco nell'editor, un tipo o una dimensione di top cut che il nuovo
gioco non prevede viene azzerato invece di restare selezionato di nascosto.

In modifica, un torneo il cui tipo non è più tra quelli offerti continua a mostrare il
proprio: cambiarlo di nascosto al salvataggio sarebbe peggio che mostrare una voce fuori
lista.

### Il risultato non si digita

L'esito di una partita è **derivato dai game**: più game vinti che persi è una vittoria,
meno è una sconfitta, pari è un pareggio, e un bye resta un bye qualunque cosa dicano i
game. Non esiste un campo "risultato" da compilare, quindi non è possibile registrare una
vittoria con più game persi che vinti.

La regola vive in `MatchStats.resultOf`, e il valore calcolato viene comunque salvato in
colonna: serve alle query di statistica, che così non devono ricalcolarlo riga per riga.

### Il contatore degli archetipi avversari

`opponent_archetypes.times_faced` viene aggiornato dal `MatchRepository` dentro la stessa
transazione della partita: +1 quando si registra un match, spostato da uno all'altro
quando si corregge l'avversario, −1 quando si cancella un round o un intero torneo, e mai
sotto zero.

È un dato denormalizzato, quindi l'unico modo di tenerlo onesto è che nessuno lo scriva
al di fuori di quel repository.

### Competitivo e libero

Le partite libere (`tournament_id` null) sono escluse da tutte le analisi, senza filtro
per includerle: nessuna schermata ne registra da quando il contatore punti vita ha preso
il posto del recorder. La colonna resta nullable e la query esclude il torneo nullo in un
punto solo, quindi riaprire la strada costa una riga.

### Il campione di una statistica

Ogni winrate mostrato è accompagnato dal numero di partite decise su cui è calcolato,
ovunque, senza eccezioni. Sotto le **5** partite (`Analytics.smallSample`) la cifra viene
attenuata invece che nascosta.

Attenuata e non rimossa perché il dato esiste ed è quello: quello che cambia è quanto
peso merita. La soglia vive in un unico posto e nessuna schermata la riscrive.

## 8. Localizzazione

Interfaccia in italiano e inglese, tramite `flutter_localizations` e file ARB
(`lib/l10n/app_it.arb`, `lib/l10n/app_en.arb`).

- Lingua iniziale: quella di sistema, con fallback all'inglese.
- Override manuale in Impostazioni, salvato nelle preferenze.
- Nessuna stringa hardcoded nei widget: tutto passa da `AppLocalizations`.
- Date, numeri e percentuali formattati con `intl`, secondo il locale attivo.

I nomi dei formati di sistema (Standard, Modern, Pauper, Legacy, Edison) non si
traducono. Fa eccezione il formato Avanzato di Yu-Gi-Oh!, che in inglese si chiama
Advanced: viene tradotto tramite una chiave dedicata, mentre i formati creati
dall'utente restano sempre come li ha scritti.

## 9. Formato di backup

L'export produce un unico documento JSON con dentro tutte e sei le tabelle.

```json
{
  "app": "tcg-tracker",
  "formatVersion": 1,
  "schemaVersion": 1,
  "exportedAt": "2026-08-08T17:10:00.000",
  "tables": { "games": [], "formats": [], "decks": [], "opponent_archetypes": [], "tournaments": [], "matches": [] }
}
```

- `app` e `formatVersion` sono un controllo di sanità: un file di un'altra app, o
  scritto da una versione più recente, viene rifiutato invece che importato a metà.
  Versione corrente: **2** (foto e liste dei mazzi). I file scritti dalla versione 1 si
  ripristinano ancora, semplicemente non contengono né foto né liste.
- Le date sono **testo ISO-8601**, non timestamp in millisecondi. La serializzazione di
  default di Drift arrotonderebbe i microsecondi a ogni passaggio.
- Le foto dei mazzi sono **base64**: un array di byte non ha rappresentazione JSON.
- **Il ripristino sostituisce, non fonde.** Tutto avviene in una sola transazione: le
  tabelle si svuotano dai figli verso i padri e si riempiono nell'ordine inverso, così le
  foreign key reggono a ogni passo e un file corrotto lascia i dati esistenti intatti.
- Il seed di giochi e formati fa parte del backup, quindi un ripristino non lo perde.

Lo scambio di file col disco vive dietro un import condizionale
(`data/backup/backup_file.dart`): l'implementazione browser è quella reale, lo stub
serve solo a far compilare il codice sotto la Dart VM, dove girano i test.

## 10. Identità visiva

Direzione scelta: **dark gaming**. Tema scuro come default (non "segui il sistema"),
superfici profonde, accento violetto, numeri grandi come elemento dominante.

### Colori

Il `ColorScheme` è generato dal seed `#8B6BFF`, con le superfici scure sovrascritte a
mano per ottenere una scala più profonda di quella prodotta da Material.

I colori che portano significato non stanno nel `ColorScheme` ma in una
`ThemeExtension` chiamata `AppColors`, raggiungibile con `Theme.of(context).appColors`:

| Token | Scuro | Significato |
|---|---|---|
| `yugioh` | `#E8A33D` | identità Yu-Gi-Oh!, ambra come il bordo delle carte |
| `magic` | `#5B9CFF` | identità Magic |
| `win` | `#3DD68C` | match vinto |
| `loss` | `#F2555A` | match perso |
| `draw` | `#9A9AA8` | pareggio |
| `heroGradient` | viola scuro | sfondo dell'intestazione della dashboard |

Ogni token ha anche la variante chiara, con contrasto rialzato per il tema light.

### Tipografia

Nessun webfont: la PWA deve funzionare offline, quindi si usa lo stack di sistema con
fallback (`Inter`, `Segoe UI`, `Roboto`, ...). Il carattere dell'app arriva dai pesi e
dalla spaziatura, non da un font scaricato:

- **Numeri e titoli:** peso 800, spaziatura negativa. Una percentuale di winrate deve
  leggersi come un titolo.
- **Etichette:** maiuscoletto spaziato (`labelSmall` e `labelMedium`), usato per aprire
  ogni blocco tramite il widget `SectionLabel`.
- **Testo corrente:** peso normale, nessuna spaziatura particolare.

### Regole di composizione

- Le sezioni si aprono sempre con un `SectionLabel`, mai con un titolo grande.
- I dati mancanti si mostrano come `—`, mai come `0`: nessun dato e uno zero reale
  significano cose diverse. È la ragione per cui `StatTile.value` è nullable.
- Le schermate vengono progettate a partire dal loro stato vuoto, perché è l'aspetto
  che l'app avrà il giorno in cui viene installata.

## 11. Sync e account

Backend: **Supabase** (Postgres + Auth). Credenziali iniettate alla build con
`--dart-define=SUPABASE_URL` e `--dart-define=SUPABASE_ANON_KEY`; una build senza
credenziali è una build valida e l'app resta interamente locale. Procedura di
collegamento in [`supabase.md`](supabase.md), SQL in [`supabase/schema.sql`](supabase/schema.sql).

### Cosa viaggia: il database intero, come un documento solo

Non riga per riga. Il documento è **lo stesso JSON dell'export manuale**, quindi
formato di backup e formato di sync sono la stessa cosa e hanno la stessa versione.

La scelta è deliberata. Un merge per riga richiederebbe `updated_at` e tombstone su
tutte e sette le tabelle, un cursore di pull e una migrazione di schema, per risolvere
un problema che questo utente non ha: un archivio personale di qualche centinaio di
righe, modificato da un dispositivo alla volta. Il prezzo è uno solo ed è dichiarato
nella schermata Account: modificare su due dispositivi senza sincronizzare in mezzo
significa scartare una delle due copie — scegliendo, mai in silenzio.

### La regola che rende il tutto sicuro

Una sola tabella remota, `snapshots`, una riga per utente, protetta da row level
security. Ogni push accettato incrementa `revision`.

Il dispositivo ricorda `baseRevision`, cioè da quale revisione del cloud vengono i suoi
dati. La funzione `push_snapshot` accetta la scrittura **solo se il cloud è ancora a
quella revisione**, altrimenti solleva un errore `40001` che il client legge come
conflitto. Un dispositivo che non ha visto le modifiche di un altro non può quindi
sovrascriverle, nemmeno provandoci.

Casi, tutti in `SyncController`:

| Cloud | Dispositivo | Esito |
|---|---|---|
| vuoto | qualsiasi cosa | push |
| stessa revisione | niente da mandare | nulla da fare |
| stessa revisione | modifiche locali | push |
| revisione avanti | niente da mandare | pull |
| revisione avanti | modifiche locali | **conflitto**, deciso dall'utente |

`baseRevision` è salvato insieme all'id dell'account: accedere con un secondo account
sullo stesso dispositivo riparte da zero, perché il numero del primo lì non significa
più niente.

Al primo accesso, dati locali mai spediti contano come lavoro non sincronizzato anche
se in quella sessione non è stato toccato niente. Senza questa regola un dispositivo
con una stagione di tornei si scaricherebbe sopra la copia del cloud senza chiedere.

### Cosa conta come modifica locale

Il controller ascolta `tableUpdates()` di Drift, non i singoli repository: una feature
aggiunta domani viene sincronizzata senza che nessuno debba ricordarsi di dirlo.

Due scritture non contano:

- quelle dell'**apertura del database** (migrazione, `_repairSchema`, seed). Sono
  l'app che si installa, non lavoro dell'utente: l'ascolto parte solo dopo che il
  database è aperto. Per la stessa ragione `Seed.apply` legge prima di scrivere e non
  scrive niente quando non c'è niente da aggiungere — un batch tutto ignorato segnala
  comunque a Drift che le tabelle sono cambiate.
- quelle di un **pull**, che altrimenti verrebbero rispedite in su appena scaricate,
  all'infinito. Le notifiche di Drift arrivano un giro dopo la scrittura, quindi la
  finestra in cui vengono ignorate dura un giro in più delle scritture stesse.

Il push automatico è ritardato di 5 secondi: compilare un round diventa un caricamento
solo invece di sei. Si può spegnere dalla schermata Account.

### Cosa non fa

- Non è realtime: si sincronizza all'accesso, dopo una modifica, e su richiesta.
- Non fonde due versioni divergenti.
- **Uscire dall'account non cancella niente in locale.** È l'unica cosa irreversibile
  che quella schermata potrebbe fare, e "esci" non vuol mai dire "cancella i mazzi".

### Costo delle foto

Le foto dei mazzi viaggiano in base64 dentro il documento, e il documento intero viene
ricaricato a ogni push. Con molte foto il sync automatico resta utilizzabile, ma ogni
modifica costa il caricamento di tutto l'archivio: è il conto da tenere presente se un
giorno la libreria diventasse grande.
