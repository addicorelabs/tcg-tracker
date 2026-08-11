// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Italian (`it`).
class AppLocalizationsIt extends AppLocalizations {
  AppLocalizationsIt([String locale = 'it']) : super(locale);

  @override
  String get appTitle => 'TCG Tracker';

  @override
  String get navHome => 'Home';

  @override
  String get navTournaments => 'Tornei';

  @override
  String get navAnalytics => 'Analisi';

  @override
  String get navDecks => 'Mazzi';

  @override
  String get navSettings => 'Impostazioni';

  @override
  String get actionNewTournament => 'Nuovo torneo';

  @override
  String get actionNewMatch => 'Nuova partita';

  @override
  String get gameYugioh => 'Yu-Gi-Oh!';

  @override
  String get gameMagic => 'Magic: The Gathering';

  @override
  String get formatAdvanced => 'Avanzato';

  @override
  String get comingSoon => 'In arrivo';

  @override
  String get comingSoonHint => 'Questa sezione arriva in una fase successiva.';

  @override
  String get ongoingTournament => 'Torneo in corso';

  @override
  String get noOngoingTournament => 'Nessun torneo in corso';

  @override
  String get noOngoingTournamentHint =>
      'Creane uno e i suoi round compariranno qui.';

  @override
  String get statsLast30Days => 'Ultimi 30 giorni';

  @override
  String get statWinrate => 'Winrate';

  @override
  String get statTournaments => 'Tornei';

  @override
  String get statMatches => 'Partite';

  @override
  String get quickActions => 'Azioni rapide';

  @override
  String get settingsLanguage => 'Lingua';

  @override
  String get settingsLanguageSystem => 'Lingua di sistema';

  @override
  String get settingsFormats => 'Giochi e formati';

  @override
  String get settingsFormatsHint =>
      'Aggiungi i giochi e i formati che giochi, e nascondi quelli che non giochi più.';

  @override
  String get settingsFormatsManage => 'Gestisci giochi e formati';

  @override
  String get catalogTitle => 'Giochi e formati';

  @override
  String get catalogHint =>
      'Nascondere un gioco o un formato lo toglie dai menu. Niente di già registrato al suo interno va perso.';

  @override
  String get catalogSystem => 'Di sistema';

  @override
  String get catalogHidden => 'Nascosto';

  @override
  String get catalogHide => 'Nascondi';

  @override
  String get catalogShow => 'Mostra';

  @override
  String get catalogUnused => 'Non ancora usato';

  @override
  String catalogUsage(int decks, int tournaments) {
    String _temp0 = intl.Intl.pluralLogic(
      decks,
      locale: localeName,
      other: '$decks mazzi',
      one: '1 mazzo',
    );
    String _temp1 = intl.Intl.pluralLogic(
      tournaments,
      locale: localeName,
      other: '$tournaments tornei',
      one: '1 torneo',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get catalogNoFormats => 'Nessun formato. Aggiungi il primo qui sotto.';

  @override
  String get catalogDeleteSystem =>
      'Le voci di sistema non si eliminano. Puoi solo nasconderle.';

  @override
  String get catalogDeleteInUse =>
      'Contiene mazzi o tornei. Puoi solo nasconderlo.';

  @override
  String get gameNew => 'Nuovo gioco';

  @override
  String get gameNameLabel => 'Nome del gioco';

  @override
  String get gameNameTaken => 'Esiste già un gioco con questo nome.';

  @override
  String get gameLastOne => 'Almeno un gioco deve restare visibile.';

  @override
  String gameDeleteConfirm(String name) {
    return 'Eliminare $name? I suoi formati e i relativi archetipi avversari vengono eliminati con lui.';
  }

  @override
  String get formatNew => 'Nuovo formato';

  @override
  String get formatNameLabel => 'Nome del formato';

  @override
  String get formatNameTaken =>
      'Questo gioco ha già un formato con questo nome.';

  @override
  String formatDeleteConfirm(String name) {
    return 'Eliminare $name? I suoi archetipi avversari vengono eliminati con lui.';
  }

  @override
  String get errorGeneric => 'Qualcosa è andato storto.';

  @override
  String get formIncomplete => 'Compila i campi evidenziati prima di salvare.';

  @override
  String saveFailed(String error) {
    return 'Salvataggio non riuscito: $error';
  }

  @override
  String get settingsTheme => 'Tema';

  @override
  String get settingsThemeSystem => 'Sistema';

  @override
  String get settingsThemeLight => 'Chiaro';

  @override
  String get settingsThemeDark => 'Scuro';

  @override
  String get actionSave => 'Salva';

  @override
  String get actionCancel => 'Annulla';

  @override
  String get actionClose => 'Chiudi';

  @override
  String get actionAdd => 'Aggiungi';

  @override
  String get actionRename => 'Rinomina';

  @override
  String get actionDelete => 'Elimina';

  @override
  String get fieldRequired => 'Obbligatorio';

  @override
  String get deckNew => 'Nuovo mazzo';

  @override
  String get deckEdit => 'Modifica mazzo';

  @override
  String get deckGame => 'Gioco';

  @override
  String get deckFormat => 'Formato';

  @override
  String get deckName => 'Nome del mazzo';

  @override
  String get deckArchetype => 'Archetipo';

  @override
  String get deckArchetypeHint =>
      'Stessa lista degli avversari: è così che le analisi raggruppano i risultati.';

  @override
  String get deckColors => 'Colori';

  @override
  String get deckNotes => 'Note';

  @override
  String get deckArchive => 'Archivia';

  @override
  String get deckRestore => 'Ripristina';

  @override
  String get deckArchived => 'Archiviato';

  @override
  String get deckDuplicate => 'Duplica';

  @override
  String get deckCopySuffix => 'copia';

  @override
  String get deckDeleteInUse =>
      'Questo mazzo compare in tornei salvati, quindi può solo essere archiviato.';

  @override
  String get deckShowArchived => 'Mostra archiviati';

  @override
  String deckCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count mazzi',
      one: '1 mazzo',
    );
    return '$_temp0';
  }

  @override
  String get deckNone => 'Nessun mazzo ancora';

  @override
  String get decksEmpty => 'Nessun mazzo';

  @override
  String get decksEmptyHint => 'Aggiungi i mazzi che giochi, uno per formato.';

  @override
  String get filterAll => 'Tutti';

  @override
  String get deckPhoto => 'Foto';

  @override
  String get deckPhotoAdd => 'Aggiungi foto';

  @override
  String get deckPhotoReplace => 'Sostituisci';

  @override
  String get deckPhotoRemove => 'Rimuovi';

  @override
  String get deckPhotoHint =>
      'Ridotta a 1280 px prima del salvataggio, così i backup restano leggeri.';

  @override
  String get deckList => 'Lista del mazzo';

  @override
  String get deckListImport => 'Importa .txt';

  @override
  String get deckListClear => 'Svuota lista';

  @override
  String get deckListEmpty => 'Nessuna lista importata';

  @override
  String get deckListHint =>
      'Legge le liste in testo semplice esportate dai siti di deckbuilding. I nomi delle carte vengono salvati esattamente come sono scritti.';

  @override
  String get deckListImportFailed => 'Nessuna carta trovata nel file.';

  @override
  String deckListCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count carte',
      one: '1 carta',
    );
    return '$_temp0';
  }

  @override
  String get sectionMain => 'Main deck';

  @override
  String get sectionSide => 'Side deck';

  @override
  String get sectionExtra => 'Extra deck';

  @override
  String get sectionCommander => 'Comandante';

  @override
  String get archetypesTitle => 'Archetipi avversari';

  @override
  String get archetypesHint =>
      'Una lista condivisa per formato evita che la matchup matrix spezzi lo stesso mazzo in più grafie.';

  @override
  String get archetypeNew => 'Nuovo archetipo';

  @override
  String get archetypeSearch => 'Cerca un archetipo';

  @override
  String get archetypeName => 'Nome';

  @override
  String get archetypesEmpty => 'Nessun archetipo per questo formato';

  @override
  String get archetypeDeleteInUse =>
      'Ci sono partite registrate contro questo archetipo, quindi non può essere eliminato.';

  @override
  String archetypeTimesFaced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Incontrato $count volte',
      one: 'Incontrato una volta',
      zero: 'Mai incontrato',
    );
    return '$_temp0';
  }

  @override
  String get fieldNotes => 'Note';

  @override
  String get fieldOptional => 'Facoltativo';

  @override
  String get tournamentName => 'Nome evento';

  @override
  String get tournamentDate => 'Data';

  @override
  String get tournamentDeck => 'Mazzo giocato';

  @override
  String get tournamentEventType => 'Tipo';

  @override
  String get tournamentParticipants => 'Partecipanti';

  @override
  String get tournamentRounds => 'Round svizzeri';

  @override
  String get tournamentTopCut => 'Top cut';

  @override
  String get tournamentTopCutSize => 'Dimensione top cut';

  @override
  String get tournamentStanding => 'Piazzamento finale';

  @override
  String tournamentStandingValue(int position) {
    return '$position°';
  }

  @override
  String get eventTypeLocal => 'Locale';

  @override
  String get eventTypeRegional => 'Regionale';

  @override
  String get eventTypeNational => 'Nazionale';

  @override
  String get eventTypeOnline => 'Online';

  @override
  String get eventTypeOts => 'OTS';

  @override
  String get eventTypeStoreChampionship => 'Store Championship';

  @override
  String get eventTypeShowdown => 'Showdown';

  @override
  String get eventTypePtq => 'PTQ';

  @override
  String get eventTypeContinental => 'Continentale';

  @override
  String get eventTypeWorlds => 'Mondiale';

  @override
  String get tournamentStatusPlanned => 'Pianificato';

  @override
  String get tournamentStatusOngoing => 'In corso';

  @override
  String get tournamentStatusFinished => 'Concluso';

  @override
  String get tournamentFinish => 'Concludi torneo';

  @override
  String get tournamentReopen => 'Riapri';

  @override
  String get tournamentEdit => 'Modifica torneo';

  @override
  String get tournamentDelete => 'Elimina torneo';

  @override
  String get tournamentDeleteConfirm =>
      'Eliminando questo torneo si eliminano anche i suoi round. L\'operazione non è annullabile.';

  @override
  String get tournamentsEmpty => 'Nessun torneo';

  @override
  String get tournamentsEmptyHint =>
      'Registra un evento e i suoi round compariranno qui.';

  @override
  String get tournamentNeedsDeck => 'Aggiungi prima un mazzo';

  @override
  String get tournamentNeedsDeckHint =>
      'Un torneo registra con quale mazzo hai giocato, quindi ce ne deve essere almeno uno da scegliere.';

  @override
  String get filterStatus => 'Stato';

  @override
  String roundNumber(int number) {
    return 'Round $number';
  }

  @override
  String get roundTopCut => 'Top cut';

  @override
  String get roundNew => 'Nuovo round';

  @override
  String get roundEdit => 'Modifica round';

  @override
  String get roundDelete => 'Elimina round';

  @override
  String get roundsEmpty => 'Nessun round registrato';

  @override
  String get roundsEmptyHint => 'Aggiungi il primo appena finisci di giocarlo.';

  @override
  String get matchOpponentName => 'Avversario';

  @override
  String get matchOpponentDeck => 'Mazzo dell\'avversario';

  @override
  String get matchOpponentDeckUnknown => 'Mazzo sconosciuto';

  @override
  String get matchOnThePlay => 'Ho iniziato io';

  @override
  String get matchPlayShort => 'Play';

  @override
  String get matchDrawShort => 'Draw';

  @override
  String get matchGames => 'Game';

  @override
  String get matchGamesWon => 'Vinti';

  @override
  String get matchGamesLost => 'Persi';

  @override
  String get matchGamesDrawn => 'Pari';

  @override
  String get lifeTitle => 'Punti vita';

  @override
  String get lifeSetupHint =>
      'Contatore da tavolo. Niente di quello che succede qui viene salvato nello storico.';

  @override
  String get lifeStartingLife => 'Vita iniziale';

  @override
  String get lifeStart => 'Inizia';

  @override
  String get lifeRestart => 'Ricomincia';

  @override
  String lifeRestartConfirm(int life) {
    return 'Riporto entrambi i giocatori a $life e cancello la cronologia?';
  }

  @override
  String get lifeNewSetup => 'Cambia impostazioni';

  @override
  String get lifeMe => 'Io';

  @override
  String get lifeOpponent => 'Avversario';

  @override
  String get lifeStep => 'Passo';

  @override
  String get lifeUndo => 'Annulla ultima modifica';

  @override
  String get lifeHistory => 'Cronologia';

  @override
  String get lifeHistoryEmpty => 'Ancora niente da mostrare.';

  @override
  String get lifeCounters => 'Contatori';

  @override
  String lifeDefeated(String player) {
    return '$player a zero';
  }

  @override
  String get counterPoison => 'Veleno';

  @override
  String get counterEnergy => 'Energia';

  @override
  String get counterExperience => 'Esperienza';

  @override
  String get counterGeneric => 'Segnalini';

  @override
  String get toolDice => 'Dado';

  @override
  String get toolCoin => 'Moneta';

  @override
  String get toolTimer => 'Timer';

  @override
  String get coinHeads => 'Testa';

  @override
  String get coinTails => 'Croce';

  @override
  String get timerLength => 'Durata del round';

  @override
  String get timerStart => 'Avvia';

  @override
  String get timerPause => 'Pausa';

  @override
  String get timerReset => 'Azzera';

  @override
  String get timerOver => 'Tempo scaduto';

  @override
  String get matchIsBye => 'Questo round è stato un bye';

  @override
  String get matchIsByeHint => 'Un bye conta nel record ma mai nel winrate.';

  @override
  String get matchIsTopCut => 'Partita di top cut';

  @override
  String get resultWin => 'Vittoria';

  @override
  String get resultLoss => 'Sconfitta';

  @override
  String get resultDraw => 'Pareggio';

  @override
  String get resultBye => 'Bye';

  @override
  String get statRecord => 'Record';

  @override
  String get statPoints => 'Punti';

  @override
  String recordPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count punti',
      one: '1 punto',
    );
    return '$_temp0';
  }

  @override
  String recordByes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count bye',
      one: '1 bye',
    );
    return '$_temp0';
  }

  @override
  String recordSample(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partite',
      one: '1 partita',
    );
    return '$_temp0';
  }

  @override
  String get actionRecordRound => 'Registra round';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get backupExport => 'Esporta dati';

  @override
  String get backupExportHint =>
      'Scarica tutto in un file JSON. Fallo con regolarità: iOS può cancellare i dati locali di una web app dopo un periodo di inattività.';

  @override
  String get backupImport => 'Ripristina da file';

  @override
  String get backupImportConfirm =>
      'Il ripristino sostituisce tutto quello che c\'è ora nell\'app. L\'operazione non è annullabile.';

  @override
  String get backupImportAction => 'Ripristina';

  @override
  String get backupExportDone => 'Backup scaricato';

  @override
  String get backupImportDone => 'Backup ripristinato';

  @override
  String backupImportFailed(String reason) {
    return 'Ripristino non riuscito: $reason';
  }

  @override
  String get settingsAccount => 'Account e sync';

  @override
  String get syncHowItWorks =>
      'Il database viaggia come una copia sola, non modifica per modifica. Se sincronizzi da un dispositivo alla volta non c\'è niente da decidere; se ne modifichi due senza sincronizzare in mezzo, l\'app ti chiede quale tenere.';

  @override
  String get syncNotConfigured => 'Sync non configurata in questa build';

  @override
  String get syncNotConfiguredHint =>
      'Questa copia dell\'app è stata compilata senza le credenziali del cloud, quindi tutto resta su questo dispositivo. Continua a esportare il file di backup.';

  @override
  String get syncSignedOutTitle => 'Tieni una copia nel cloud';

  @override
  String get syncSignedOutHint =>
      'Un account tiene una copia di tutto su un server e te la riporta su qualsiasi dispositivo da cui accedi. Finché non accedi, niente esce da questo dispositivo.';

  @override
  String get syncEmail => 'Email';

  @override
  String get syncPassword => 'Password';

  @override
  String get syncActionSignIn => 'Accedi';

  @override
  String get syncActionSignUp => 'Crea account';

  @override
  String get syncSwitchToSignUp => 'Non hai un account? Creane uno';

  @override
  String get syncSwitchToSignIn => 'Hai già un account? Accedi';

  @override
  String get syncActionForgotPassword => 'Password dimenticata?';

  @override
  String syncResetSent(String email) {
    return 'Abbiamo mandato un link per reimpostarla a $email';
  }

  @override
  String get syncEmailInvalid => 'Inserisci un indirizzo email valido';

  @override
  String get syncPasswordTooShort => 'Usa almeno 6 caratteri';

  @override
  String syncSignedInAs(String email) {
    return 'Accesso come $email';
  }

  @override
  String get syncActionSignOut => 'Esci';

  @override
  String get syncSignOutHint =>
      'Uscire lascia tutti i mazzi e i tornei su questo dispositivo.';

  @override
  String get syncStateSynced => 'Tutto salvato nel cloud';

  @override
  String get syncStatePending => 'Modifiche non ancora inviate';

  @override
  String get syncStateWorking => 'Sincronizzazione…';

  @override
  String get syncStateNever => 'Mai sincronizzato su questo dispositivo';

  @override
  String syncLastSync(String when) {
    return 'Ultima sincronizzazione $when';
  }

  @override
  String get syncActionSyncNow => 'Sincronizza ora';

  @override
  String get syncActionDownload => 'Prendi la copia del cloud';

  @override
  String get syncActionDownloadConfirm =>
      'Sostituisce tutto quello che c\'è su questo dispositivo con la copia del cloud. L\'operazione non è annullabile.';

  @override
  String get syncAuto => 'Sincronizza da sola';

  @override
  String get syncAutoHint =>
      'Manda le modifiche pochi secondi dopo che le fai. Disattivala per sincronizzare solo quando lo chiedi tu.';

  @override
  String get syncConflictTitle => 'Due versioni';

  @override
  String syncConflictBody(String device, String when) {
    return 'Questo dispositivo e il cloud sono cambiati entrambi dall\'ultima volta che erano d\'accordo. La copia nel cloud arriva da $device il $when. Tenerne una scarta l\'altra.';
  }

  @override
  String get syncConflictUnknownDevice => 'un altro dispositivo';

  @override
  String get syncActionKeepLocal => 'Tieni questo dispositivo';

  @override
  String get syncActionKeepCloud => 'Tieni la copia del cloud';

  @override
  String get syncErrorTitle => 'Sincronizzazione non riuscita';

  @override
  String get analyticsEmpty => 'Ancora niente da analizzare';

  @override
  String get analyticsEmptyHint =>
      'Registra un round di torneo e i numeri cominciano da qui.';

  @override
  String get analyticsNoMatchesForFilters =>
      'Nessuna partita con questi filtri';

  @override
  String get analyticsAllDecks => 'Tutti i mazzi';

  @override
  String get analyticsPeriod30 => '30 giorni';

  @override
  String get analyticsPeriod90 => '90 giorni';

  @override
  String get analyticsPeriodYear => '1 anno';

  @override
  String get analyticsPeriodAll => 'Sempre';

  @override
  String get analyticsOverview => 'Riepilogo';

  @override
  String get analyticsMatchWinrate => 'Winrate match';

  @override
  String get analyticsGameWinrate => 'Winrate game';

  @override
  String get analyticsCompetitiveOnly =>
      'Contano solo i round di torneo. I bye stanno nel record ma mai in un winrate.';

  @override
  String get analyticsByDeck => 'Per mazzo';

  @override
  String get analyticsMatchup => 'Matchup matrix';

  @override
  String analyticsMatchupHint(int count) {
    return 'I miei archetipi di lato, i loro in alto. Le celle sbiadite hanno meno di $count partite dietro.';
  }

  @override
  String get analyticsMatchupEmpty =>
      'Nessun matchup ha ancora abbastanza avversari registrati.';

  @override
  String get analyticsPlayDraw => 'Play e draw';

  @override
  String get analyticsOnThePlay => 'Inizio io';

  @override
  String get analyticsOnTheDraw => 'Inizia lui';

  @override
  String analyticsPlayAdvantage(String points) {
    return 'Iniziare qui vale $points punti';
  }

  @override
  String analyticsPlayDrawUnrecorded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count partite senza chi ha iniziato',
      one: '1 partita senza chi ha iniziato',
    );
    return '$_temp0';
  }

  @override
  String get analyticsTrend => 'Andamento';

  @override
  String get analyticsTrendHint => 'Winrate match mese per mese.';

  @override
  String get analyticsMeta => 'Meta locale';

  @override
  String get analyticsMetaHint =>
      'Quello che si è visto davvero dall\'altra parte del tavolo, non quello che gioca internet.';

  @override
  String get analyticsReset => 'Azzera questo storico';

  @override
  String get analyticsResetHint =>
      'Cancella i tornei del gioco e del formato qui sopra. Mazzi e archetipi restano.';

  @override
  String analyticsResetConfirm(int tournaments, int matches, String format) {
    String _temp0 = intl.Intl.pluralLogic(
      tournaments,
      locale: localeName,
      other: '$tournaments tornei',
      one: '1 torneo',
    );
    String _temp1 = intl.Intl.pluralLogic(
      matches,
      locale: localeName,
      other: '$matches partite',
      one: '1 partita',
    );
    return '$_temp0 e $_temp1 di $format verranno cancellati per sempre. Non si torna indietro: se vuoi conservarli, esporta prima un backup dalle impostazioni.';
  }

  @override
  String analyticsResetDone(String format) {
    return 'Storico di $format cancellato';
  }

  @override
  String analyticsFaced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'incontrato $count volte',
      one: 'incontrato una volta',
    );
    return '$_temp0';
  }

  @override
  String get analyticsThinSample => 'Troppe poche partite per farci conto';
}
