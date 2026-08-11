// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TCG Tracker';

  @override
  String get navHome => 'Home';

  @override
  String get navTournaments => 'Tournaments';

  @override
  String get navAnalytics => 'Analytics';

  @override
  String get navDecks => 'Decks';

  @override
  String get navSettings => 'Settings';

  @override
  String get actionNewTournament => 'New tournament';

  @override
  String get actionNewMatch => 'New match';

  @override
  String get gameYugioh => 'Yu-Gi-Oh!';

  @override
  String get gameMagic => 'Magic: The Gathering';

  @override
  String get formatAdvanced => 'Advanced';

  @override
  String get comingSoon => 'Coming soon';

  @override
  String get comingSoonHint => 'This section is built in a later phase.';

  @override
  String get ongoingTournament => 'Tournament in progress';

  @override
  String get noOngoingTournament => 'No tournament in progress';

  @override
  String get noOngoingTournamentHint =>
      'Start one and its rounds will show up here.';

  @override
  String get statsLast30Days => 'Last 30 days';

  @override
  String get statWinrate => 'Winrate';

  @override
  String get statTournaments => 'Tournaments';

  @override
  String get statMatches => 'Matches';

  @override
  String get quickActions => 'Quick actions';

  @override
  String get settingsLanguage => 'Language';

  @override
  String get settingsLanguageSystem => 'System language';

  @override
  String get settingsFormats => 'Games and formats';

  @override
  String get settingsFormatsHint =>
      'Add the games and formats you play, and hide the ones you no longer do.';

  @override
  String get settingsFormatsManage => 'Manage games and formats';

  @override
  String get catalogTitle => 'Games and formats';

  @override
  String get catalogHint =>
      'Hiding a game or a format takes it out of the menus. Nothing already recorded in it is lost.';

  @override
  String get catalogSystem => 'Built in';

  @override
  String get catalogHidden => 'Hidden';

  @override
  String get catalogHide => 'Hide';

  @override
  String get catalogShow => 'Show';

  @override
  String get catalogUnused => 'Not used yet';

  @override
  String catalogUsage(int decks, int tournaments) {
    String _temp0 = intl.Intl.pluralLogic(
      decks,
      locale: localeName,
      other: '$decks decks',
      one: '1 deck',
    );
    String _temp1 = intl.Intl.pluralLogic(
      tournaments,
      locale: localeName,
      other: '$tournaments tournaments',
      one: '1 tournament',
    );
    return '$_temp0 · $_temp1';
  }

  @override
  String get catalogNoFormats => 'No formats yet. Add the first one below.';

  @override
  String get catalogDeleteSystem =>
      'Built-in entries cannot be deleted. Hide it instead.';

  @override
  String get catalogDeleteInUse =>
      'This has decks or tournaments in it. Hide it instead.';

  @override
  String get gameNew => 'New game';

  @override
  String get gameNameLabel => 'Game name';

  @override
  String get gameNameTaken => 'There is already a game with that name.';

  @override
  String get gameLastOne => 'At least one game has to stay visible.';

  @override
  String gameDeleteConfirm(String name) {
    return 'Delete $name? Its formats and their opponent archetypes go with it.';
  }

  @override
  String get formatNew => 'New format';

  @override
  String get formatNameLabel => 'Format name';

  @override
  String get formatNameTaken =>
      'This game already has a format with that name.';

  @override
  String formatDeleteConfirm(String name) {
    return 'Delete $name? Its opponent archetypes go with it.';
  }

  @override
  String get errorGeneric => 'Something went wrong.';

  @override
  String get formIncomplete => 'Fill in the highlighted fields before saving.';

  @override
  String saveFailed(String error) {
    return 'Could not save: $error';
  }

  @override
  String get settingsTheme => 'Theme';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get actionSave => 'Save';

  @override
  String get actionCancel => 'Cancel';

  @override
  String get actionClose => 'Close';

  @override
  String get actionAdd => 'Add';

  @override
  String get actionRename => 'Rename';

  @override
  String get actionDelete => 'Delete';

  @override
  String get fieldRequired => 'Required';

  @override
  String get deckNew => 'New deck';

  @override
  String get deckEdit => 'Edit deck';

  @override
  String get deckGame => 'Game';

  @override
  String get deckFormat => 'Format';

  @override
  String get deckName => 'Deck name';

  @override
  String get deckArchetype => 'Archetype';

  @override
  String get deckArchetypeHint =>
      'The same list as the opponents\': it is how the analytics group results.';

  @override
  String get deckColors => 'Colours';

  @override
  String get deckNotes => 'Notes';

  @override
  String get deckArchive => 'Archive';

  @override
  String get deckRestore => 'Restore';

  @override
  String get deckArchived => 'Archived';

  @override
  String get deckDuplicate => 'Duplicate';

  @override
  String get deckCopySuffix => 'copy';

  @override
  String get deckDeleteInUse =>
      'This deck appears in saved tournaments, so it can only be archived.';

  @override
  String get deckShowArchived => 'Show archived';

  @override
  String deckCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count decks',
      one: '1 deck',
    );
    return '$_temp0';
  }

  @override
  String get deckNone => 'No deck yet';

  @override
  String get decksEmpty => 'No decks yet';

  @override
  String get decksEmptyHint => 'Add the decks you play, one entry per format.';

  @override
  String get filterAll => 'All';

  @override
  String get deckPhoto => 'Photo';

  @override
  String get deckPhotoAdd => 'Add photo';

  @override
  String get deckPhotoReplace => 'Replace';

  @override
  String get deckPhotoRemove => 'Remove';

  @override
  String get deckPhotoHint =>
      'Shrunk to 1280 px before saving, so backups stay small.';

  @override
  String get deckList => 'Decklist';

  @override
  String get deckListImport => 'Import .txt';

  @override
  String get deckListClear => 'Clear list';

  @override
  String get deckListEmpty => 'No list imported';

  @override
  String get deckListHint =>
      'Reads the plain text lists exported by deckbuilding sites. Card names are stored exactly as written.';

  @override
  String get deckListImportFailed => 'No cards found in that file.';

  @override
  String deckListCards(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count cards',
      one: '1 card',
    );
    return '$_temp0';
  }

  @override
  String get sectionMain => 'Main deck';

  @override
  String get sectionSide => 'Sideboard';

  @override
  String get sectionExtra => 'Extra deck';

  @override
  String get sectionCommander => 'Commander';

  @override
  String get archetypesTitle => 'Opponent archetypes';

  @override
  String get archetypesHint =>
      'A shared list per format keeps the matchup matrix from splitting one deck across several spellings.';

  @override
  String get archetypeNew => 'New archetype';

  @override
  String get archetypeSearch => 'Search an archetype';

  @override
  String get archetypeName => 'Name';

  @override
  String get archetypesEmpty => 'No archetypes for this format';

  @override
  String get archetypeDeleteInUse =>
      'Matches were recorded against this archetype, so it cannot be deleted.';

  @override
  String archetypeTimesFaced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'Faced $count times',
      one: 'Faced once',
      zero: 'Never faced',
    );
    return '$_temp0';
  }

  @override
  String get fieldNotes => 'Notes';

  @override
  String get fieldOptional => 'Optional';

  @override
  String get tournamentName => 'Event name';

  @override
  String get tournamentDate => 'Date';

  @override
  String get tournamentDeck => 'Deck played';

  @override
  String get tournamentEventType => 'Type';

  @override
  String get tournamentParticipants => 'Participants';

  @override
  String get tournamentRounds => 'Swiss rounds';

  @override
  String get tournamentTopCut => 'Top cut';

  @override
  String get tournamentTopCutSize => 'Top cut size';

  @override
  String get tournamentStanding => 'Final standing';

  @override
  String tournamentStandingValue(int position) {
    return '#$position';
  }

  @override
  String get eventTypeLocal => 'Local';

  @override
  String get eventTypeRegional => 'Regional';

  @override
  String get eventTypeNational => 'National';

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
  String get eventTypeContinental => 'Continental';

  @override
  String get eventTypeWorlds => 'Worlds';

  @override
  String get tournamentStatusPlanned => 'Planned';

  @override
  String get tournamentStatusOngoing => 'In progress';

  @override
  String get tournamentStatusFinished => 'Finished';

  @override
  String get tournamentFinish => 'Finish tournament';

  @override
  String get tournamentReopen => 'Reopen';

  @override
  String get tournamentEdit => 'Edit tournament';

  @override
  String get tournamentDelete => 'Delete tournament';

  @override
  String get tournamentDeleteConfirm =>
      'Deleting this tournament also deletes its rounds. This cannot be undone.';

  @override
  String get tournamentsEmpty => 'No tournaments yet';

  @override
  String get tournamentsEmptyHint =>
      'Record an event and its rounds show up here.';

  @override
  String get tournamentNeedsDeck => 'Add a deck first';

  @override
  String get tournamentNeedsDeckHint =>
      'A tournament records which deck you played, so there has to be one to choose.';

  @override
  String get filterStatus => 'Status';

  @override
  String roundNumber(int number) {
    return 'Round $number';
  }

  @override
  String get roundTopCut => 'Top cut';

  @override
  String get roundNew => 'New round';

  @override
  String get roundEdit => 'Edit round';

  @override
  String get roundDelete => 'Delete round';

  @override
  String get roundsEmpty => 'No rounds recorded';

  @override
  String get roundsEmptyHint =>
      'Add the first one as soon as you finish playing it.';

  @override
  String get matchOpponentName => 'Opponent';

  @override
  String get matchOpponentDeck => 'Opponent\'s deck';

  @override
  String get matchOpponentDeckUnknown => 'Unknown deck';

  @override
  String get matchOnThePlay => 'I was on the play';

  @override
  String get matchPlayShort => 'Play';

  @override
  String get matchDrawShort => 'Draw';

  @override
  String get matchGames => 'Games';

  @override
  String get matchGamesWon => 'Won';

  @override
  String get matchGamesLost => 'Lost';

  @override
  String get matchGamesDrawn => 'Drawn';

  @override
  String get lifeTitle => 'Life points';

  @override
  String get lifeSetupHint =>
      'A tool for the table. Nothing that happens here is saved to your history.';

  @override
  String get lifeStartingLife => 'Starting life';

  @override
  String get lifeStart => 'Start';

  @override
  String get lifeRestart => 'Restart';

  @override
  String lifeRestartConfirm(int life) {
    return 'Put both players back to $life and clear the history?';
  }

  @override
  String get lifeNewSetup => 'Change setup';

  @override
  String get lifeMe => 'Me';

  @override
  String get lifeOpponent => 'Opponent';

  @override
  String get lifeStep => 'Step';

  @override
  String get lifeUndo => 'Undo last change';

  @override
  String get lifeHistory => 'History';

  @override
  String get lifeHistoryEmpty => 'Nothing to show yet.';

  @override
  String get lifeCounters => 'Counters';

  @override
  String lifeDefeated(String player) {
    return '$player at zero';
  }

  @override
  String get counterPoison => 'Poison';

  @override
  String get counterEnergy => 'Energy';

  @override
  String get counterExperience => 'Experience';

  @override
  String get counterGeneric => 'Counters';

  @override
  String get toolDice => 'Dice';

  @override
  String get toolCoin => 'Coin';

  @override
  String get toolTimer => 'Timer';

  @override
  String get coinHeads => 'Heads';

  @override
  String get coinTails => 'Tails';

  @override
  String get timerLength => 'Round length';

  @override
  String get timerStart => 'Start';

  @override
  String get timerPause => 'Pause';

  @override
  String get timerReset => 'Reset';

  @override
  String get timerOver => 'Time is up';

  @override
  String get matchIsBye => 'This round was a bye';

  @override
  String get matchIsByeHint =>
      'A bye counts in the record but never in the winrate.';

  @override
  String get matchIsTopCut => 'Top cut match';

  @override
  String get resultWin => 'Win';

  @override
  String get resultLoss => 'Loss';

  @override
  String get resultDraw => 'Draw';

  @override
  String get resultBye => 'Bye';

  @override
  String get statRecord => 'Record';

  @override
  String get statPoints => 'Points';

  @override
  String recordPoints(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count points',
      one: '1 point',
    );
    return '$_temp0';
  }

  @override
  String recordByes(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count byes',
      one: '1 bye',
    );
    return '$_temp0';
  }

  @override
  String recordSample(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches',
      one: '1 match',
    );
    return '$_temp0';
  }

  @override
  String get actionRecordRound => 'Record round';

  @override
  String get settingsBackup => 'Backup';

  @override
  String get backupExport => 'Export data';

  @override
  String get backupExportHint =>
      'Downloads everything as a JSON file. Do this regularly: iOS can clear a web app\'s local data after a stretch of inactivity.';

  @override
  String get backupImport => 'Restore from file';

  @override
  String get backupImportConfirm =>
      'Restoring replaces everything currently stored in the app. This cannot be undone.';

  @override
  String get backupImportAction => 'Restore';

  @override
  String get backupExportDone => 'Backup downloaded';

  @override
  String get backupImportDone => 'Backup restored';

  @override
  String backupImportFailed(String reason) {
    return 'Could not restore: $reason';
  }

  @override
  String get settingsAccount => 'Account and sync';

  @override
  String get syncHowItWorks =>
      'The whole database travels as one copy, not change by change. Sync from one device at a time and there is nothing to decide; edit two without syncing in between and the app asks which one to keep.';

  @override
  String get syncNotConfigured => 'Sync is not set up in this build';

  @override
  String get syncNotConfiguredHint =>
      'This copy of the app was built without cloud credentials, so everything stays on this device. Keep exporting the backup file.';

  @override
  String get syncSignedOutTitle => 'Keep a copy in the cloud';

  @override
  String get syncSignedOutHint =>
      'An account keeps a copy of everything on a server and brings it back on any device you sign in from. Until you sign in, nothing leaves this device.';

  @override
  String get syncEmail => 'Email';

  @override
  String get syncPassword => 'Password';

  @override
  String get syncActionSignIn => 'Sign in';

  @override
  String get syncActionSignUp => 'Create account';

  @override
  String get syncSwitchToSignUp => 'No account yet? Create one';

  @override
  String get syncSwitchToSignIn => 'Already have an account? Sign in';

  @override
  String get syncActionForgotPassword => 'Forgot your password?';

  @override
  String syncResetSent(String email) {
    return 'We sent a reset link to $email';
  }

  @override
  String get syncEmailInvalid => 'Enter a valid email address';

  @override
  String get syncPasswordTooShort => 'Use at least 6 characters';

  @override
  String syncSignedInAs(String email) {
    return 'Signed in as $email';
  }

  @override
  String get syncActionSignOut => 'Sign out';

  @override
  String get syncSignOutHint =>
      'Signing out leaves every deck and tournament on this device.';

  @override
  String get syncStateSynced => 'Everything is in the cloud';

  @override
  String get syncStatePending => 'Changes not sent yet';

  @override
  String get syncStateWorking => 'Syncing…';

  @override
  String get syncStateNever => 'Never synced on this device';

  @override
  String syncLastSync(String when) {
    return 'Last sync $when';
  }

  @override
  String get syncActionSyncNow => 'Sync now';

  @override
  String get syncActionDownload => 'Take the cloud copy';

  @override
  String get syncActionDownloadConfirm =>
      'This replaces everything on this device with the cloud copy. It cannot be undone.';

  @override
  String get syncAuto => 'Sync automatically';

  @override
  String get syncAutoHint =>
      'Sends changes a few seconds after you make them. Turn it off to sync only when you ask.';

  @override
  String get syncConflictTitle => 'Two versions';

  @override
  String syncConflictBody(String device, String when) {
    return 'This device and the cloud both changed since they last agreed. The cloud copy came from $device on $when. Keeping one discards the other.';
  }

  @override
  String get syncConflictUnknownDevice => 'another device';

  @override
  String get syncActionKeepLocal => 'Keep this device';

  @override
  String get syncActionKeepCloud => 'Keep the cloud copy';

  @override
  String get syncErrorTitle => 'Sync failed';

  @override
  String get analyticsEmpty => 'Nothing to analyse yet';

  @override
  String get analyticsEmptyHint =>
      'Record a tournament round and the numbers start here.';

  @override
  String get analyticsNoMatchesForFilters => 'No matches match these filters';

  @override
  String get analyticsAllDecks => 'Every deck';

  @override
  String get analyticsPeriod30 => '30 days';

  @override
  String get analyticsPeriod90 => '90 days';

  @override
  String get analyticsPeriodYear => '1 year';

  @override
  String get analyticsPeriodAll => 'Always';

  @override
  String get analyticsOverview => 'Overview';

  @override
  String get analyticsMatchWinrate => 'Match winrate';

  @override
  String get analyticsGameWinrate => 'Game winrate';

  @override
  String get analyticsCompetitiveOnly =>
      'Only tournament rounds count. Byes are in the record but never in a winrate.';

  @override
  String get analyticsByDeck => 'By deck';

  @override
  String get analyticsMatchup => 'Matchup matrix';

  @override
  String analyticsMatchupHint(int count) {
    return 'My archetypes down the side, theirs across the top. Faded cells have fewer than $count matches behind them.';
  }

  @override
  String get analyticsMatchupEmpty =>
      'No matchup has enough recorded opponents yet.';

  @override
  String get analyticsPlayDraw => 'Play and draw';

  @override
  String get analyticsOnThePlay => 'On the play';

  @override
  String get analyticsOnTheDraw => 'On the draw';

  @override
  String analyticsPlayAdvantage(String points) {
    return 'Going first is worth $points points here';
  }

  @override
  String analyticsPlayDrawUnrecorded(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count matches without who started',
      one: '1 match without who started',
    );
    return '$_temp0';
  }

  @override
  String get analyticsTrend => 'Over time';

  @override
  String get analyticsTrendHint => 'Match winrate month by month.';

  @override
  String get analyticsMeta => 'Local meta';

  @override
  String get analyticsMetaHint =>
      'What actually turned up across the table, not what the internet plays.';

  @override
  String analyticsFaced(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: 'faced $count times',
      one: 'faced once',
    );
    return '$_temp0';
  }

  @override
  String get analyticsThinSample => 'Too few matches to read much into';
}
