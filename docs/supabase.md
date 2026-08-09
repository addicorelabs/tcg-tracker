# Supabase — setup del sync (F5)

Guida per collegare l'app a un progetto Supabase. Va fatta una volta sola.
Finché non è fatta l'app funziona normalmente, solo in locale, e la schermata
Account lo dice esplicitamente invece di offrire un login che non potrebbe mai
funzionare.

## 1. Creare il progetto

1. Registrarsi su https://supabase.com (il piano gratuito basta ampiamente:
   500 MB di database contro un backup che sta in pochi MB).
2. **New project**. Scegliere una region europea, per esempio `eu-central-1`.
3. Annotare la password del database quando viene chiesta. Non serve all'app,
   serve a te se un giorno vorrai collegarti direttamente al Postgres.

## 2. Creare la tabella

Aprire **SQL Editor**, incollare tutto il contenuto di
[`docs/supabase/schema.sql`](supabase/schema.sql) ed eseguirlo.

Crea tre cose:

- la tabella `snapshots`, una riga per utente;
- la row level security, che è l'unica cosa che impedisce a un account di
  leggere i dati di un altro;
- la funzione `push_snapshot`, che rifiuta una scrittura basata su una
  revisione ormai vecchia.

Rieseguirlo non fa danni.

## 3. Impostare l'autenticazione

In **Authentication → Providers** lasciare attivo **Email**.

- Se **Confirm email** è attivo (default), dopo la registrazione arriva una
  mail con un link, e finché non lo si apre l'accesso non è completo. L'app lo
  dice invece di restare in attesa.
- Per una prova rapida si può disattivare la conferma. Per l'uso vero conviene
  lasciarla attiva.

In **Authentication → URL Configuration** mettere come *Site URL* l'indirizzo
a cui la PWA sarà pubblicata (fase F8), così il link di reset password torna
sull'app e non su `localhost`.

## 4. Prendere le due chiavi

In **Project Settings → API**:

- **Project URL** — qualcosa come `https://abcdefgh.supabase.co`
- **anon / publishable key** — la chiave pubblica, quella lunga

La chiave anon **è pensata per stare dentro il client**: non è un segreto, ed è
la row level security del punto 2 a proteggere i dati. La `service_role` key,
invece, non va messa mai da nessuna parte in questo progetto.

## 5. Compilare l'app con le credenziali

Le credenziali entrano al momento della build, non da un file nel repository:

```bash
flutter run -d web-server --web-hostname 0.0.0.0 --web-port 8080 \
  --dart-define=SUPABASE_URL=https://abcdefgh.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...

flutter build web --release \
  --dart-define=SUPABASE_URL=https://abcdefgh.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGciOi...
```

Per non riscriverle ogni volta si può usare un file di configurazione:

```bash
flutter build web --release --dart-define-from-file=supabase.json
```

con `supabase.json` fuori dal repository (o in `.gitignore`):

```json
{
  "SUPABASE_URL": "https://abcdefgh.supabase.co",
  "SUPABASE_ANON_KEY": "eyJhbGciOi..."
}
```

Una build senza queste due variabili è una build valida: l'app parte, funziona
tutta, e la sezione Account spiega che il sync non c'è.

## 6. Verificare

1. Aprire **Impostazioni → Account e sync**, creare un account, accedere.
2. Creare un mazzo. Entro pochi secondi la riga in Impostazioni deve passare a
   "Tutto salvato nel cloud".
3. Su Supabase, **Table Editor → snapshots**: deve esserci una riga con
   `revision` a 1 o più e il `payload` pieno.

## Come funziona il sync

Quello che viaggia è **l'intero database come un unico documento**, non le
singole modifiche. È lo stesso JSON dell'export manuale.

La scelta è deliberata: questa app contiene lo storico tornei di una persona,
qualche centinaio di righe, e un merge riga per riga richiederebbe tombstone,
cursori e una migrazione di tutte e sette le tabelle per risolvere un problema
che l'utente non ha. Il prezzo è uno solo, ed è dichiarato nella schermata
Account: se si modifica su due dispositivi senza sincronizzare in mezzo, una
delle due copie viene scartata — scegliendo, mai in silenzio.

A rendere la cosa sicura è un contatore. Ogni push accettato incrementa
`revision`, e il dispositivo ricorda da quale revisione vengono i suoi dati. Un
push è accettato solo se il cloud è ancora a quella revisione, quindi un
dispositivo che non ha visto le modifiche di un altro **non può** sovrascriverle.
Quando succede, l'app mostra le due versioni e i due pulsanti, e non ne
preseleziona nessuno: entrambi buttano via dei dati.

Il sync automatico manda le modifiche 5 secondi dopo che sono state fatte, così
compilare un round è un caricamento solo e non sei. Si può spegnere.

### Cosa non fa

- Non è realtime: non c'è nessuna sottoscrizione, si sincronizza all'accesso, a
  ogni modifica e quando lo si chiede.
- Non fonde due versioni divergenti.
- Non cancella niente in locale quando si esce dall'account.

## Costi

Il piano gratuito basta. L'unico numero che vale la pena tenere d'occhio sono
le **foto dei mazzi**: viaggiano dentro il JSON in base64, quindi una foto da
300 KB diventa circa 400 KB nel documento, e il documento intero viene
ricaricato a ogni push. Con qualche decina di mazzi fotografati conviene tenere
il sync automatico acceso ma sapere che ogni modifica costa quel caricamento.

Un progetto Supabase gratuito viene messo in pausa dopo una settimana senza
richieste. L'app continua a funzionare offline, ma il sync torna solo dopo aver
riattivato il progetto dalla dashboard.
