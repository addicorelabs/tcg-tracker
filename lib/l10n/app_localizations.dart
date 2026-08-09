import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_it.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('it'),
  ];

  /// Application name, shown in the browser tab and app bar
  ///
  /// In en, this message translates to:
  /// **'TCG Tracker'**
  String get appTitle;

  /// Bottom navigation label for the dashboard
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// Bottom navigation label for the tournament list
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get navTournaments;

  /// Bottom navigation label for the statistics section
  ///
  /// In en, this message translates to:
  /// **'Analytics'**
  String get navAnalytics;

  /// Bottom navigation label for the deck library
  ///
  /// In en, this message translates to:
  /// **'Decks'**
  String get navDecks;

  /// Bottom navigation label for the settings section
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// Starts the tournament creation wizard
  ///
  /// In en, this message translates to:
  /// **'New tournament'**
  String get actionNewTournament;

  /// Records a casual match played outside a tournament
  ///
  /// In en, this message translates to:
  /// **'New match'**
  String get actionNewMatch;

  /// Display name of the Yu-Gi-Oh! trading card game
  ///
  /// In en, this message translates to:
  /// **'Yu-Gi-Oh!'**
  String get gameYugioh;

  /// Display name of the Magic: The Gathering trading card game
  ///
  /// In en, this message translates to:
  /// **'Magic: The Gathering'**
  String get gameMagic;

  /// Yu-Gi-Oh! Advanced format. The only format name that is translated
  ///
  /// In en, this message translates to:
  /// **'Advanced'**
  String get formatAdvanced;

  /// Placeholder shown on screens that are not implemented yet
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoon;

  /// Secondary line under the coming soon placeholder
  ///
  /// In en, this message translates to:
  /// **'This section is built in a later phase.'**
  String get comingSoonHint;

  /// Header of the dashboard card showing the active tournament
  ///
  /// In en, this message translates to:
  /// **'Tournament in progress'**
  String get ongoingTournament;

  /// Empty state of the dashboard card when nothing is being played
  ///
  /// In en, this message translates to:
  /// **'No tournament in progress'**
  String get noOngoingTournament;

  /// Secondary line of the empty ongoing-tournament card
  ///
  /// In en, this message translates to:
  /// **'Start one and its rounds will show up here.'**
  String get noOngoingTournamentHint;

  /// Time range covered by the dashboard summary tiles
  ///
  /// In en, this message translates to:
  /// **'Last 30 days'**
  String get statsLast30Days;

  /// Percentage of matches won, byes excluded
  ///
  /// In en, this message translates to:
  /// **'Winrate'**
  String get statWinrate;

  /// Number of tournaments played
  ///
  /// In en, this message translates to:
  /// **'Tournaments'**
  String get statTournaments;

  /// Number of matches played
  ///
  /// In en, this message translates to:
  /// **'Matches'**
  String get statMatches;

  /// Section header above the create buttons on the dashboard
  ///
  /// In en, this message translates to:
  /// **'Quick actions'**
  String get quickActions;

  /// Settings entry to override the interface language
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get settingsLanguage;

  /// Language option that follows the device setting
  ///
  /// In en, this message translates to:
  /// **'System language'**
  String get settingsLanguageSystem;

  /// Settings section listing the formats of each game
  ///
  /// In en, this message translates to:
  /// **'Games and formats'**
  String get settingsFormats;

  /// Note under the catalogue on the settings screen
  ///
  /// In en, this message translates to:
  /// **'Add the games and formats you play, and hide the ones you no longer do.'**
  String get settingsFormatsHint;

  /// Row that opens the catalogue screen
  ///
  /// In en, this message translates to:
  /// **'Manage games and formats'**
  String get settingsFormatsManage;

  /// Title of the catalogue screen
  ///
  /// In en, this message translates to:
  /// **'Games and formats'**
  String get catalogTitle;

  /// Explanation at the top of the catalogue screen
  ///
  /// In en, this message translates to:
  /// **'Hiding a game or a format takes it out of the menus. Nothing already recorded in it is lost.'**
  String get catalogHint;

  /// Marks a game or format that ships with the app
  ///
  /// In en, this message translates to:
  /// **'Built in'**
  String get catalogSystem;

  /// Marks a game or format the user has hidden
  ///
  /// In en, this message translates to:
  /// **'Hidden'**
  String get catalogHidden;

  /// Action that takes a game or format out of the menus
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get catalogHide;

  /// Action that puts a hidden game or format back in the menus
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get catalogShow;

  /// Subtitle of a game or format no deck or tournament points at
  ///
  /// In en, this message translates to:
  /// **'Not used yet'**
  String get catalogUnused;

  /// How much history a game or format carries
  ///
  /// In en, this message translates to:
  /// **'{decks, plural, =1{1 deck} other{{decks} decks}} · {tournaments, plural, =1{1 tournament} other{{tournaments} tournaments}}'**
  String catalogUsage(int decks, int tournaments);

  /// Shown under a game that has no formats
  ///
  /// In en, this message translates to:
  /// **'No formats yet. Add the first one below.'**
  String get catalogNoFormats;

  /// Refusal shown when deleting a system game or format
  ///
  /// In en, this message translates to:
  /// **'Built-in entries cannot be deleted. Hide it instead.'**
  String get catalogDeleteSystem;

  /// Refusal shown when deleting a game or format that carries history
  ///
  /// In en, this message translates to:
  /// **'This has decks or tournaments in it. Hide it instead.'**
  String get catalogDeleteInUse;

  /// Button that creates a game
  ///
  /// In en, this message translates to:
  /// **'New game'**
  String get gameNew;

  /// Label of the game name field
  ///
  /// In en, this message translates to:
  /// **'Game name'**
  String get gameNameLabel;

  /// Refusal shown when a game name is already in use
  ///
  /// In en, this message translates to:
  /// **'There is already a game with that name.'**
  String get gameNameTaken;

  /// Refusal shown when hiding or deleting the last visible game
  ///
  /// In en, this message translates to:
  /// **'At least one game has to stay visible.'**
  String get gameLastOne;

  /// Asked before deleting a user game
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? Its formats and their opponent archetypes go with it.'**
  String gameDeleteConfirm(String name);

  /// Row that creates a format under a game
  ///
  /// In en, this message translates to:
  /// **'New format'**
  String get formatNew;

  /// Label of the format name field
  ///
  /// In en, this message translates to:
  /// **'Format name'**
  String get formatNameLabel;

  /// Refusal shown when a format name is already in use
  ///
  /// In en, this message translates to:
  /// **'This game already has a format with that name.'**
  String get formatNameTaken;

  /// Asked before deleting a user format
  ///
  /// In en, this message translates to:
  /// **'Delete {name}? Its opponent archetypes go with it.'**
  String formatDeleteConfirm(String name);

  /// Fallback message when data cannot be read
  ///
  /// In en, this message translates to:
  /// **'Something went wrong.'**
  String get errorGeneric;

  /// Told to the user when a save is refused by validation
  ///
  /// In en, this message translates to:
  /// **'Fill in the highlighted fields before saving.'**
  String get formIncomplete;

  /// Shown when writing to the database throws, with the reason
  ///
  /// In en, this message translates to:
  /// **'Could not save: {error}'**
  String saveFailed(String error);

  /// Settings entry to choose the colour theme
  ///
  /// In en, this message translates to:
  /// **'Theme'**
  String get settingsTheme;

  /// Theme option that follows the device setting
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get settingsThemeSystem;

  /// Light theme option
  ///
  /// In en, this message translates to:
  /// **'Light'**
  String get settingsThemeLight;

  /// Dark theme option
  ///
  /// In en, this message translates to:
  /// **'Dark'**
  String get settingsThemeDark;

  /// Confirms a form
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get actionSave;

  /// Dismisses a dialog without applying it
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get actionCancel;

  /// Dismisses a dialog that only shows a result
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get actionClose;

  /// Creates a new entry
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get actionAdd;

  /// Changes the name of an existing entry
  ///
  /// In en, this message translates to:
  /// **'Rename'**
  String get actionRename;

  /// Removes an entry permanently
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get actionDelete;

  /// Validation error shown under an empty mandatory field
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get fieldRequired;

  /// Title of the deck editor when creating
  ///
  /// In en, this message translates to:
  /// **'New deck'**
  String get deckNew;

  /// Title of the deck editor when changing an existing deck
  ///
  /// In en, this message translates to:
  /// **'Edit deck'**
  String get deckEdit;

  /// Deck field: which card game the deck belongs to
  ///
  /// In en, this message translates to:
  /// **'Game'**
  String get deckGame;

  /// Deck field: which format the deck is legal in
  ///
  /// In en, this message translates to:
  /// **'Format'**
  String get deckFormat;

  /// Deck field: the name the user gives this particular build
  ///
  /// In en, this message translates to:
  /// **'Deck name'**
  String get deckName;

  /// Deck field: the canonical archetype name
  ///
  /// In en, this message translates to:
  /// **'Archetype'**
  String get deckArchetype;

  /// Helper text under the archetype field
  ///
  /// In en, this message translates to:
  /// **'The same list as the opponents\': it is how the analytics group results.'**
  String get deckArchetypeHint;

  /// Deck field: Magic colour identity
  ///
  /// In en, this message translates to:
  /// **'Colours'**
  String get deckColors;

  /// Deck field: free text
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get deckNotes;

  /// Hides a deck without deleting its history
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get deckArchive;

  /// Brings an archived deck back into the active list
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get deckRestore;

  /// Badge on a deck that is no longer in rotation
  ///
  /// In en, this message translates to:
  /// **'Archived'**
  String get deckArchived;

  /// Copies a deck as the starting point for a new build
  ///
  /// In en, this message translates to:
  /// **'Duplicate'**
  String get deckDuplicate;

  /// Appended to the name of a duplicated deck
  ///
  /// In en, this message translates to:
  /// **'copy'**
  String get deckCopySuffix;

  /// Explains why a deck with history cannot be deleted
  ///
  /// In en, this message translates to:
  /// **'This deck appears in saved tournaments, so it can only be archived.'**
  String get deckDeleteInUse;

  /// Toggle that reveals archived decks in the list
  ///
  /// In en, this message translates to:
  /// **'Show archived'**
  String get deckShowArchived;

  /// How many builds an archetype has
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 deck} other{{count} decks}}'**
  String deckCount(int count);

  /// Subtitle of an archetype row with no build filed under it
  ///
  /// In en, this message translates to:
  /// **'No deck yet'**
  String get deckNone;

  /// Empty state of the deck library
  ///
  /// In en, this message translates to:
  /// **'No decks yet'**
  String get decksEmpty;

  /// Secondary line of the deck library empty state
  ///
  /// In en, this message translates to:
  /// **'Add the decks you play, one entry per format.'**
  String get decksEmptyHint;

  /// Filter chip that removes the format restriction
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get filterAll;

  /// Deck section holding a picture of the physical deck
  ///
  /// In en, this message translates to:
  /// **'Photo'**
  String get deckPhoto;

  /// Opens the picker to attach a deck photo
  ///
  /// In en, this message translates to:
  /// **'Add photo'**
  String get deckPhotoAdd;

  /// Swaps the current deck photo for another
  ///
  /// In en, this message translates to:
  /// **'Replace'**
  String get deckPhotoReplace;

  /// Deletes the deck photo
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get deckPhotoRemove;

  /// Explains that photos are downscaled on import
  ///
  /// In en, this message translates to:
  /// **'Shrunk to 1280 px before saving, so backups stay small.'**
  String get deckPhotoHint;

  /// Deck section holding the imported list of cards
  ///
  /// In en, this message translates to:
  /// **'Decklist'**
  String get deckList;

  /// Reads a decklist from a plain text file
  ///
  /// In en, this message translates to:
  /// **'Import .txt'**
  String get deckListImport;

  /// Removes the imported decklist
  ///
  /// In en, this message translates to:
  /// **'Clear list'**
  String get deckListClear;

  /// Shown when a deck has no decklist attached
  ///
  /// In en, this message translates to:
  /// **'No list imported'**
  String get deckListEmpty;

  /// Explains what the decklist importer accepts
  ///
  /// In en, this message translates to:
  /// **'Reads the plain text lists exported by deckbuilding sites. Card names are stored exactly as written.'**
  String get deckListHint;

  /// Shown when a text file yields no card lines
  ///
  /// In en, this message translates to:
  /// **'No cards found in that file.'**
  String get deckListImportFailed;

  /// Total number of physical cards in a section
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 card} other{{count} cards}}'**
  String deckListCards(int count);

  /// Decklist section: the main deck
  ///
  /// In en, this message translates to:
  /// **'Main deck'**
  String get sectionMain;

  /// Decklist section: the sideboard, called side deck in Yu-Gi-Oh!
  ///
  /// In en, this message translates to:
  /// **'Sideboard'**
  String get sectionSide;

  /// Decklist section: the Yu-Gi-Oh! extra deck
  ///
  /// In en, this message translates to:
  /// **'Extra deck'**
  String get sectionExtra;

  /// Decklist section: the commander of a Magic Commander deck
  ///
  /// In en, this message translates to:
  /// **'Commander'**
  String get sectionCommander;

  /// Screen listing the known decks the user plays against
  ///
  /// In en, this message translates to:
  /// **'Opponent archetypes'**
  String get archetypesTitle;

  /// Explains why opponent archetypes are a controlled list
  ///
  /// In en, this message translates to:
  /// **'A shared list per format keeps the matchup matrix from splitting one deck across several spellings.'**
  String get archetypesHint;

  /// Dialog title when adding an opponent archetype
  ///
  /// In en, this message translates to:
  /// **'New archetype'**
  String get archetypeNew;

  /// Hint of the opponent deck menu, which filters as you type
  ///
  /// In en, this message translates to:
  /// **'Search an archetype'**
  String get archetypeSearch;

  /// Field holding the archetype name
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get archetypeName;

  /// Empty state of the archetype list
  ///
  /// In en, this message translates to:
  /// **'No archetypes for this format'**
  String get archetypesEmpty;

  /// Explains why an archetype with history cannot be deleted
  ///
  /// In en, this message translates to:
  /// **'Matches were recorded against this archetype, so it cannot be deleted.'**
  String get archetypeDeleteInUse;

  /// How often this opponent archetype has been played against
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =0{Never faced} =1{Faced once} other{Faced {count} times}}'**
  String archetypeTimesFaced(int count);

  /// Free text field shared by several forms
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get fieldNotes;

  /// Helper text marking a field that can be left empty
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get fieldOptional;

  /// What the tournament was called
  ///
  /// In en, this message translates to:
  /// **'Event name'**
  String get tournamentName;

  /// Day the tournament was played
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get tournamentDate;

  /// Which of the user's decks was brought to the event
  ///
  /// In en, this message translates to:
  /// **'Deck played'**
  String get tournamentDeck;

  /// Scale of the event
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get tournamentEventType;

  /// How many players entered
  ///
  /// In en, this message translates to:
  /// **'Participants'**
  String get tournamentParticipants;

  /// Number of swiss rounds the event was scheduled for
  ///
  /// In en, this message translates to:
  /// **'Swiss rounds'**
  String get tournamentRounds;

  /// Whether the event had a knockout stage
  ///
  /// In en, this message translates to:
  /// **'Top cut'**
  String get tournamentTopCut;

  /// How many players made the knockout stage
  ///
  /// In en, this message translates to:
  /// **'Top cut size'**
  String get tournamentTopCutSize;

  /// Where the user placed
  ///
  /// In en, this message translates to:
  /// **'Final standing'**
  String get tournamentStanding;

  /// Final placing, shown next to the record
  ///
  /// In en, this message translates to:
  /// **'#{position}'**
  String tournamentStandingValue(int position);

  /// A shop or club event
  ///
  /// In en, this message translates to:
  /// **'Local'**
  String get eventTypeLocal;

  /// A regional event
  ///
  /// In en, this message translates to:
  /// **'Regional'**
  String get eventTypeRegional;

  /// A national event
  ///
  /// In en, this message translates to:
  /// **'National'**
  String get eventTypeNational;

  /// An event played online
  ///
  /// In en, this message translates to:
  /// **'Online'**
  String get eventTypeOnline;

  /// Yu-Gi-Oh! Official Tournament Store event
  ///
  /// In en, this message translates to:
  /// **'OTS'**
  String get eventTypeOts;

  /// Magic store-level championship
  ///
  /// In en, this message translates to:
  /// **'Store Championship'**
  String get eventTypeStoreChampionship;

  /// Magic Regional Championship Qualifier showdown
  ///
  /// In en, this message translates to:
  /// **'Showdown'**
  String get eventTypeShowdown;

  /// Magic Pro Tour Qualifier
  ///
  /// In en, this message translates to:
  /// **'PTQ'**
  String get eventTypePtq;

  /// A continent-wide championship
  ///
  /// In en, this message translates to:
  /// **'Continental'**
  String get eventTypeContinental;

  /// The world championship
  ///
  /// In en, this message translates to:
  /// **'Worlds'**
  String get eventTypeWorlds;

  /// Tournament that has not started
  ///
  /// In en, this message translates to:
  /// **'Planned'**
  String get tournamentStatusPlanned;

  /// Tournament currently being played
  ///
  /// In en, this message translates to:
  /// **'In progress'**
  String get tournamentStatusOngoing;

  /// Tournament that is over
  ///
  /// In en, this message translates to:
  /// **'Finished'**
  String get tournamentStatusFinished;

  /// Closes a tournament and asks for the final standing
  ///
  /// In en, this message translates to:
  /// **'Finish tournament'**
  String get tournamentFinish;

  /// Puts a finished tournament back in progress
  ///
  /// In en, this message translates to:
  /// **'Reopen'**
  String get tournamentReopen;

  /// Title of the tournament form when changing an existing event
  ///
  /// In en, this message translates to:
  /// **'Edit tournament'**
  String get tournamentEdit;

  /// Removes a tournament
  ///
  /// In en, this message translates to:
  /// **'Delete tournament'**
  String get tournamentDelete;

  /// Warning before deleting a tournament
  ///
  /// In en, this message translates to:
  /// **'Deleting this tournament also deletes its rounds. This cannot be undone.'**
  String get tournamentDeleteConfirm;

  /// Empty state of the tournament list
  ///
  /// In en, this message translates to:
  /// **'No tournaments yet'**
  String get tournamentsEmpty;

  /// Secondary line of the tournament list empty state
  ///
  /// In en, this message translates to:
  /// **'Record an event and its rounds show up here.'**
  String get tournamentsEmptyHint;

  /// Shown when a tournament cannot be created because the library is empty
  ///
  /// In en, this message translates to:
  /// **'Add a deck first'**
  String get tournamentNeedsDeck;

  /// Explains why a deck is required before a tournament
  ///
  /// In en, this message translates to:
  /// **'A tournament records which deck you played, so there has to be one to choose.'**
  String get tournamentNeedsDeckHint;

  /// Filter selecting planned, ongoing or finished tournaments
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get filterStatus;

  /// Heading of a single swiss round
  ///
  /// In en, this message translates to:
  /// **'Round {number}'**
  String roundNumber(int number);

  /// Heading of a knockout match
  ///
  /// In en, this message translates to:
  /// **'Top cut'**
  String get roundTopCut;

  /// Title of the round form when recording
  ///
  /// In en, this message translates to:
  /// **'New round'**
  String get roundNew;

  /// Title of the round form when changing a recorded round
  ///
  /// In en, this message translates to:
  /// **'Edit round'**
  String get roundEdit;

  /// Removes a recorded round
  ///
  /// In en, this message translates to:
  /// **'Delete round'**
  String get roundDelete;

  /// Empty state of a tournament with no matches yet
  ///
  /// In en, this message translates to:
  /// **'No rounds recorded'**
  String get roundsEmpty;

  /// Secondary line of the empty round list
  ///
  /// In en, this message translates to:
  /// **'Add the first one as soon as you finish playing it.'**
  String get roundsEmptyHint;

  /// Name of the person played against
  ///
  /// In en, this message translates to:
  /// **'Opponent'**
  String get matchOpponentName;

  /// Archetype the opponent was playing
  ///
  /// In en, this message translates to:
  /// **'Opponent\'s deck'**
  String get matchOpponentDeck;

  /// Shown for a match recorded without an opponent archetype
  ///
  /// In en, this message translates to:
  /// **'Unknown deck'**
  String get matchOpponentDeckUnknown;

  /// Whether the user went first in game one
  ///
  /// In en, this message translates to:
  /// **'I was on the play'**
  String get matchOnThePlay;

  /// Compact label for having gone first, as used at the table
  ///
  /// In en, this message translates to:
  /// **'Play'**
  String get matchPlayShort;

  /// Compact label for having gone second, as used at the table
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get matchDrawShort;

  /// Section holding the game counts of a match
  ///
  /// In en, this message translates to:
  /// **'Games'**
  String get matchGames;

  /// Games won in this match
  ///
  /// In en, this message translates to:
  /// **'Won'**
  String get matchGamesWon;

  /// Games lost in this match
  ///
  /// In en, this message translates to:
  /// **'Lost'**
  String get matchGamesLost;

  /// Games drawn in this match
  ///
  /// In en, this message translates to:
  /// **'Drawn'**
  String get matchGamesDrawn;

  /// Title of the life counter screen
  ///
  /// In en, this message translates to:
  /// **'Life points'**
  String get lifeTitle;

  /// Says the life counter records nothing
  ///
  /// In en, this message translates to:
  /// **'A tool for the table. Nothing that happens here is saved to your history.'**
  String get lifeSetupHint;

  /// The total both players start from
  ///
  /// In en, this message translates to:
  /// **'Starting life'**
  String get lifeStartingLife;

  /// Begins a game on the life counter
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get lifeStart;

  /// Puts both players back to the starting total
  ///
  /// In en, this message translates to:
  /// **'Restart'**
  String get lifeRestart;

  /// Confirmation before restarting a game
  ///
  /// In en, this message translates to:
  /// **'Put both players back to {life} and clear the history?'**
  String lifeRestartConfirm(int life);

  /// Goes back to picking game and starting life
  ///
  /// In en, this message translates to:
  /// **'Change setup'**
  String get lifeNewSetup;

  /// The user's own seat
  ///
  /// In en, this message translates to:
  /// **'Me'**
  String get lifeMe;

  /// The other seat
  ///
  /// In en, this message translates to:
  /// **'Opponent'**
  String get lifeOpponent;

  /// How much one tap adds or removes
  ///
  /// In en, this message translates to:
  /// **'Step'**
  String get lifeStep;

  /// Takes back the last change to a total
  ///
  /// In en, this message translates to:
  /// **'Undo last change'**
  String get lifeUndo;

  /// Every change, roll and flip of this game
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get lifeHistory;

  /// Empty state of the life counter history
  ///
  /// In en, this message translates to:
  /// **'Nothing to show yet.'**
  String get lifeHistoryEmpty;

  /// Tokens tracked beside life
  ///
  /// In en, this message translates to:
  /// **'Counters'**
  String get lifeCounters;

  /// Shown when a player runs out of life
  ///
  /// In en, this message translates to:
  /// **'{player} at zero'**
  String lifeDefeated(String player);

  /// Magic poison counters
  ///
  /// In en, this message translates to:
  /// **'Poison'**
  String get counterPoison;

  /// Magic energy counters
  ///
  /// In en, this message translates to:
  /// **'Energy'**
  String get counterEnergy;

  /// Magic experience counters
  ///
  /// In en, this message translates to:
  /// **'Experience'**
  String get counterExperience;

  /// Anything else worth counting
  ///
  /// In en, this message translates to:
  /// **'Counters'**
  String get counterGeneric;

  /// Rolls a die
  ///
  /// In en, this message translates to:
  /// **'Dice'**
  String get toolDice;

  /// Flips a coin
  ///
  /// In en, this message translates to:
  /// **'Coin'**
  String get toolCoin;

  /// The round clock
  ///
  /// In en, this message translates to:
  /// **'Timer'**
  String get toolTimer;

  /// Coin result
  ///
  /// In en, this message translates to:
  /// **'Heads'**
  String get coinHeads;

  /// Coin result
  ///
  /// In en, this message translates to:
  /// **'Tails'**
  String get coinTails;

  /// How long the round clock runs for
  ///
  /// In en, this message translates to:
  /// **'Round length'**
  String get timerLength;

  /// Starts the round clock
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get timerStart;

  /// Pauses the round clock
  ///
  /// In en, this message translates to:
  /// **'Pause'**
  String get timerPause;

  /// Puts the round clock back to its full length
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get timerReset;

  /// Shown when the round clock reaches zero
  ///
  /// In en, this message translates to:
  /// **'Time is up'**
  String get timerOver;

  /// Marks a round with no opponent
  ///
  /// In en, this message translates to:
  /// **'This round was a bye'**
  String get matchIsBye;

  /// Explains how byes are treated
  ///
  /// In en, this message translates to:
  /// **'A bye counts in the record but never in the winrate.'**
  String get matchIsByeHint;

  /// Marks a knockout match rather than a swiss round
  ///
  /// In en, this message translates to:
  /// **'Top cut match'**
  String get matchIsTopCut;

  /// Match won
  ///
  /// In en, this message translates to:
  /// **'Win'**
  String get resultWin;

  /// Match lost
  ///
  /// In en, this message translates to:
  /// **'Loss'**
  String get resultLoss;

  /// Match drawn
  ///
  /// In en, this message translates to:
  /// **'Draw'**
  String get resultDraw;

  /// Round awarded without playing
  ///
  /// In en, this message translates to:
  /// **'Bye'**
  String get resultBye;

  /// Win-loss record of a tournament
  ///
  /// In en, this message translates to:
  /// **'Record'**
  String get statRecord;

  /// Swiss points scored in a tournament: 3 a win, 1 a draw
  ///
  /// In en, this message translates to:
  /// **'Points'**
  String get statPoints;

  /// Points scored, shown beside a tournament record
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 point} other{{count} points}}'**
  String recordPoints(int count);

  /// Byes shown alongside a record, never inside it
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 bye} other{{count} byes}}'**
  String recordByes(int count);

  /// How many matches a winrate was calculated from
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 match} other{{count} matches}}'**
  String recordSample(int count);

  /// Call to action on the dashboard card of an ongoing tournament
  ///
  /// In en, this message translates to:
  /// **'Record round'**
  String get actionRecordRound;

  /// Settings section for exporting and restoring data
  ///
  /// In en, this message translates to:
  /// **'Backup'**
  String get settingsBackup;

  /// Downloads the whole database as a JSON file
  ///
  /// In en, this message translates to:
  /// **'Export data'**
  String get backupExport;

  /// Explains why exporting matters on a PWA
  ///
  /// In en, this message translates to:
  /// **'Downloads everything as a JSON file. Do this regularly: iOS can clear a web app\'s local data after a stretch of inactivity.'**
  String get backupExportHint;

  /// Replaces the database with the contents of a backup file
  ///
  /// In en, this message translates to:
  /// **'Restore from file'**
  String get backupImport;

  /// Warning shown before a restore
  ///
  /// In en, this message translates to:
  /// **'Restoring replaces everything currently stored in the app. This cannot be undone.'**
  String get backupImportConfirm;

  /// Confirms the restore in the warning dialog
  ///
  /// In en, this message translates to:
  /// **'Restore'**
  String get backupImportAction;

  /// Confirmation after a successful export
  ///
  /// In en, this message translates to:
  /// **'Backup downloaded'**
  String get backupExportDone;

  /// Confirmation after a successful restore
  ///
  /// In en, this message translates to:
  /// **'Backup restored'**
  String get backupImportDone;

  /// Shown when a backup file cannot be read
  ///
  /// In en, this message translates to:
  /// **'Could not restore: {reason}'**
  String backupImportFailed(String reason);

  /// Settings section holding the cloud account and sync
  ///
  /// In en, this message translates to:
  /// **'Account and sync'**
  String get settingsAccount;

  /// Explains the snapshot model and its one limitation
  ///
  /// In en, this message translates to:
  /// **'The whole database travels as one copy, not change by change. Sync from one device at a time and there is nothing to decide; edit two without syncing in between and the app asks which one to keep.'**
  String get syncHowItWorks;

  /// Shown when the app was built without Supabase credentials
  ///
  /// In en, this message translates to:
  /// **'Sync is not set up in this build'**
  String get syncNotConfigured;

  /// What to do instead when sync is unavailable
  ///
  /// In en, this message translates to:
  /// **'This copy of the app was built without cloud credentials, so everything stays on this device. Keep exporting the backup file.'**
  String get syncNotConfiguredHint;

  /// Headline of the signed-out account screen
  ///
  /// In en, this message translates to:
  /// **'Keep a copy in the cloud'**
  String get syncSignedOutTitle;

  /// Explains what an account is for
  ///
  /// In en, this message translates to:
  /// **'An account keeps a copy of everything on a server and brings it back on any device you sign in from. Until you sign in, nothing leaves this device.'**
  String get syncSignedOutHint;

  /// Email field label
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get syncEmail;

  /// Password field label
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get syncPassword;

  /// Signs into an existing account
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get syncActionSignIn;

  /// Creates a new account
  ///
  /// In en, this message translates to:
  /// **'Create account'**
  String get syncActionSignUp;

  /// Switches the form to sign up
  ///
  /// In en, this message translates to:
  /// **'No account yet? Create one'**
  String get syncSwitchToSignUp;

  /// Switches the form to sign in
  ///
  /// In en, this message translates to:
  /// **'Already have an account? Sign in'**
  String get syncSwitchToSignIn;

  /// Sends a password reset email
  ///
  /// In en, this message translates to:
  /// **'Forgot your password?'**
  String get syncActionForgotPassword;

  /// Confirmation after requesting a password reset
  ///
  /// In en, this message translates to:
  /// **'We sent a reset link to {email}'**
  String syncResetSent(String email);

  /// Validation message for the email field
  ///
  /// In en, this message translates to:
  /// **'Enter a valid email address'**
  String get syncEmailInvalid;

  /// Validation message for the password field
  ///
  /// In en, this message translates to:
  /// **'Use at least 6 characters'**
  String get syncPasswordTooShort;

  /// Who the app is signed in as
  ///
  /// In en, this message translates to:
  /// **'Signed in as {email}'**
  String syncSignedInAs(String email);

  /// Ends the session, leaving local data untouched
  ///
  /// In en, this message translates to:
  /// **'Sign out'**
  String get syncActionSignOut;

  /// Reassures that signing out is not a delete
  ///
  /// In en, this message translates to:
  /// **'Signing out leaves every deck and tournament on this device.'**
  String get syncSignOutHint;

  /// Status line when local and cloud agree
  ///
  /// In en, this message translates to:
  /// **'Everything is in the cloud'**
  String get syncStateSynced;

  /// Status line when there is unpushed local work
  ///
  /// In en, this message translates to:
  /// **'Changes not sent yet'**
  String get syncStatePending;

  /// Status line while a sync runs
  ///
  /// In en, this message translates to:
  /// **'Syncing…'**
  String get syncStateWorking;

  /// Status line before the first successful sync
  ///
  /// In en, this message translates to:
  /// **'Never synced on this device'**
  String get syncStateNever;

  /// When the last successful sync happened
  ///
  /// In en, this message translates to:
  /// **'Last sync {when}'**
  String syncLastSync(String when);

  /// Runs a sync immediately
  ///
  /// In en, this message translates to:
  /// **'Sync now'**
  String get syncActionSyncNow;

  /// Replaces local data with the cloud snapshot
  ///
  /// In en, this message translates to:
  /// **'Take the cloud copy'**
  String get syncActionDownload;

  /// Warning before overwriting local data
  ///
  /// In en, this message translates to:
  /// **'This replaces everything on this device with the cloud copy. It cannot be undone.'**
  String get syncActionDownloadConfirm;

  /// Toggle for background pushes
  ///
  /// In en, this message translates to:
  /// **'Sync automatically'**
  String get syncAuto;

  /// Explains what the automatic sync toggle does
  ///
  /// In en, this message translates to:
  /// **'Sends changes a few seconds after you make them. Turn it off to sync only when you ask.'**
  String get syncAutoHint;

  /// Heading of the conflict card
  ///
  /// In en, this message translates to:
  /// **'Two versions'**
  String get syncConflictTitle;

  /// Explains the conflict and what resolving it costs
  ///
  /// In en, this message translates to:
  /// **'This device and the cloud both changed since they last agreed. The cloud copy came from {device} on {when}. Keeping one discards the other.'**
  String syncConflictBody(String device, String when);

  /// Stands in for a snapshot with no device label
  ///
  /// In en, this message translates to:
  /// **'another device'**
  String get syncConflictUnknownDevice;

  /// Resolves the conflict by overwriting the cloud
  ///
  /// In en, this message translates to:
  /// **'Keep this device'**
  String get syncActionKeepLocal;

  /// Resolves the conflict by discarding local changes
  ///
  /// In en, this message translates to:
  /// **'Keep the cloud copy'**
  String get syncActionKeepCloud;

  /// Heading above the last sync error
  ///
  /// In en, this message translates to:
  /// **'Sync failed'**
  String get syncErrorTitle;

  /// Empty state of the analytics section
  ///
  /// In en, this message translates to:
  /// **'Nothing to analyse yet'**
  String get analyticsEmpty;

  /// What to do to fill the analytics section
  ///
  /// In en, this message translates to:
  /// **'Record a tournament round and the numbers start here.'**
  String get analyticsEmptyHint;

  /// Shown when data exists but the current filters exclude all of it
  ///
  /// In en, this message translates to:
  /// **'No matches match these filters'**
  String get analyticsNoMatchesForFilters;

  /// Filter option covering Yu-Gi-Oh! and Magic together
  ///
  /// In en, this message translates to:
  /// **'Both games'**
  String get analyticsAllGames;

  /// Filter option covering all decks
  ///
  /// In en, this message translates to:
  /// **'Every deck'**
  String get analyticsAllDecks;

  /// Date range filter, last 30 days
  ///
  /// In en, this message translates to:
  /// **'30 days'**
  String get analyticsPeriod30;

  /// Date range filter, last 90 days
  ///
  /// In en, this message translates to:
  /// **'90 days'**
  String get analyticsPeriod90;

  /// Date range filter, last year
  ///
  /// In en, this message translates to:
  /// **'1 year'**
  String get analyticsPeriodYear;

  /// Date range filter covering the whole history
  ///
  /// In en, this message translates to:
  /// **'Always'**
  String get analyticsPeriodAll;

  /// Heading of the summary block
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get analyticsOverview;

  /// Share of matches won
  ///
  /// In en, this message translates to:
  /// **'Match winrate'**
  String get analyticsMatchWinrate;

  /// Share of individual games won
  ///
  /// In en, this message translates to:
  /// **'Game winrate'**
  String get analyticsGameWinrate;

  /// States what the analytics section counts
  ///
  /// In en, this message translates to:
  /// **'Only tournament rounds count. Byes are in the record but never in a winrate.'**
  String get analyticsCompetitiveOnly;

  /// Heading of the per-deck breakdown
  ///
  /// In en, this message translates to:
  /// **'By deck'**
  String get analyticsByDeck;

  /// Heading of the archetype-versus-archetype grid
  ///
  /// In en, this message translates to:
  /// **'Matchup matrix'**
  String get analyticsMatchup;

  /// How to read the matchup grid
  ///
  /// In en, this message translates to:
  /// **'My archetypes down the side, theirs across the top. Faded cells have fewer than {count} matches behind them.'**
  String analyticsMatchupHint(int count);

  /// Shown when no match has an opponent archetype
  ///
  /// In en, this message translates to:
  /// **'No matchup has enough recorded opponents yet.'**
  String get analyticsMatchupEmpty;

  /// Heading of the play/draw block
  ///
  /// In en, this message translates to:
  /// **'Play and draw'**
  String get analyticsPlayDraw;

  /// Matches where the user went first
  ///
  /// In en, this message translates to:
  /// **'On the play'**
  String get analyticsOnThePlay;

  /// Matches where the opponent went first
  ///
  /// In en, this message translates to:
  /// **'On the draw'**
  String get analyticsOnTheDraw;

  /// Difference in winrate between play and draw
  ///
  /// In en, this message translates to:
  /// **'Going first is worth {points} points here'**
  String analyticsPlayAdvantage(String points);

  /// How many matches have no play/draw information
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{1 match without who started} other{{count} matches without who started}}'**
  String analyticsPlayDrawUnrecorded(int count);

  /// Heading of the monthly winrate chart
  ///
  /// In en, this message translates to:
  /// **'Over time'**
  String get analyticsTrend;

  /// What the trend chart shows
  ///
  /// In en, this message translates to:
  /// **'Match winrate month by month.'**
  String get analyticsTrendHint;

  /// Heading of the opponent archetype frequency block
  ///
  /// In en, this message translates to:
  /// **'Local meta'**
  String get analyticsMeta;

  /// What the meta block means
  ///
  /// In en, this message translates to:
  /// **'What actually turned up across the table, not what the internet plays.'**
  String get analyticsMetaHint;

  /// How often an opponent archetype was played against
  ///
  /// In en, this message translates to:
  /// **'{count, plural, =1{faced once} other{faced {count} times}}'**
  String analyticsFaced(int count);

  /// Tooltip on a figure built from a small sample
  ///
  /// In en, this message translates to:
  /// **'Too few matches to read much into'**
  String get analyticsThinSample;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'it'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'it':
      return AppLocalizationsIt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
