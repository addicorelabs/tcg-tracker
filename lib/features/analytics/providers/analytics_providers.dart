import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/stats/analytics.dart';
import '../../../core/stats/match_stats.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/analytics_repository.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/deck_repository.dart';
import '../../settings/providers/app_settings_provider.dart';

/// How far back the analytics look.
enum AnalyticsPeriod {
  last30(30),
  last90(90),
  lastYear(365),
  all(null);

  const AnalyticsPeriod(this.days);

  final int? days;

  DateTime? since(DateTime now) {
    final days = this.days;
    return days == null ? null : now.subtract(Duration(days: days));
  }
}

/// The filters the analytics section is showing.
///
/// [gameId] and [formatId] are what the user last *picked*, which is not
/// necessarily what the section is reporting on: nothing is picked before the
/// first visit, and a game or a format can be hidden after being picked. What
/// the section actually reports on comes from [analyticsGameProvider] and
/// [analyticsFormatProvider], and is never null while a game exists.
///
/// The two are kept apart so that hiding a format and unhiding it again returns
/// the section to where the user left it, rather than to the first entry in the
/// list.
@immutable
class AnalyticsSelection {
  const AnalyticsSelection({
    this.gameId,
    this.formatId,
    this.deckId,
    this.period = AnalyticsPeriod.last90,
  });

  final String? gameId;
  final String? formatId;
  final String? deckId;
  final AnalyticsPeriod period;

  AnalyticsSelection copyWith({
    String? gameId,
    bool clearGame = false,
    String? formatId,
    bool clearFormat = false,
    String? deckId,
    bool clearDeck = false,
    AnalyticsPeriod? period,
  }) {
    return AnalyticsSelection(
      gameId: clearGame ? null : (gameId ?? this.gameId),
      formatId: clearFormat ? null : (formatId ?? this.formatId),
      deckId: clearDeck ? null : (deckId ?? this.deckId),
      period: period ?? this.period,
    );
  }
}

/// The filters, remembered between sessions.
///
/// They are persisted because they are a question, not a view state: someone
/// who tracks Edison looks at Edison every time, and re-picking it on every
/// visit would be busywork.
class AnalyticsSelectionNotifier extends Notifier<AnalyticsSelection> {
  static const _gameKey = 'analytics.gameId';
  static const _formatKey = 'analytics.formatId';
  static const _deckKey = 'analytics.deckId';
  static const _periodKey = 'analytics.period';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AnalyticsSelection build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final periodName = prefs.getString(_periodKey);

    return AnalyticsSelection(
      gameId: prefs.getString(_gameKey),
      formatId: prefs.getString(_formatKey),
      deckId: prefs.getString(_deckKey),
      period: AnalyticsPeriod.values.firstWhere(
        (period) => period.name == periodName,
        orElse: () => AnalyticsPeriod.last90,
      ),
    );
  }

  /// Changing game drops the format and the deck: both belonged to the old one.
  void selectGame(String gameId) {
    state = state.copyWith(gameId: gameId, clearFormat: true, clearDeck: true);
    _save();
  }

  void selectFormat(String formatId) {
    state = state.copyWith(formatId: formatId, clearDeck: true);
    _save();
  }

  void selectDeck(String? deckId) {
    state = deckId == null
        ? state.copyWith(clearDeck: true)
        : state.copyWith(deckId: deckId);
    _save();
  }

  void selectPeriod(AnalyticsPeriod period) {
    state = state.copyWith(period: period);
    _save();
  }

  void _save() {
    _write(_gameKey, state.gameId);
    _write(_formatKey, state.formatId);
    _write(_deckKey, state.deckId);
    _prefs.setString(_periodKey, state.period.name);
  }

  void _write(String key, String? value) {
    if (value == null) {
      _prefs.remove(key);
    } else {
      _prefs.setString(key, value);
    }
  }
}

final analyticsSelectionProvider =
    NotifierProvider<AnalyticsSelectionNotifier, AnalyticsSelection>(
      AnalyticsSelectionNotifier.new,
    );

/// The game the section is reporting on.
///
/// The filters offer no "both games", so one is always in force — including
/// before the user has chosen anything, and after the chosen game has been
/// hidden. Falls back to the first visible game without writing that fallback
/// back to the saved selection, so unhiding the game returns the section to it.
///
/// Null only while there are no games at all, a state the catalogue refuses to
/// reach on purpose but which is still worth not crashing on.
final analyticsGameProvider = Provider<String?>((ref) {
  final saved = ref.watch(analyticsSelectionProvider).gameId;
  final games = ref.watch(gamesProvider).valueOrNull ?? const <Game>[];

  if (games.any((game) => game.id == saved)) return saved;
  return games.firstOrNull?.id;
});

/// The format the section is reporting on, under [analyticsGameProvider].
///
/// Same rule as the game, one level down: a saved format that belongs to
/// another game, or that has been hidden, gives way to the first format of the
/// current game. Null while that game has no visible format, which is possible —
/// unlike games, formats can all be hidden.
final analyticsFormatProvider = Provider<String?>((ref) {
  final gameId = ref.watch(analyticsGameProvider);
  if (gameId == null) return null;

  final saved = ref.watch(analyticsSelectionProvider).formatId;
  final formats =
      ref.watch(formatsProvider(gameId)).valueOrNull ?? const <Format>[];

  if (formats.any((format) => format.id == saved)) return saved;
  return formats.firstOrNull?.id;
});

/// Every match the current filters admit, with its archetypes attached.
///
/// The one query the whole section reads: each figure below is a fold over
/// this list, so the numbers on screen can never come from different data.
final analyticsMatchesProvider = StreamProvider<List<AnalyzedMatch>>((ref) {
  final selection = ref.watch(analyticsSelectionProvider);

  return ref
      .watch(analyticsRepositoryProvider)
      .watchMatches(
        AnalyticsFilter(
          gameId: ref.watch(analyticsGameProvider),
          formatId: ref.watch(analyticsFormatProvider),
          deckId: selection.deckId,
          since: selection.period.since(DateTime.now()),
        ),
      );
});

List<AnalyzedMatch> _matches(Ref ref) =>
    ref.watch(analyticsMatchesProvider).valueOrNull ?? const [];

final analyticsRecordProvider = Provider<MatchRecord>(
  (ref) => MatchStats.recordOf([for (final e in _matches(ref)) e.match]),
);

final analyticsGameRecordProvider = Provider<GameRecord>(
  (ref) => MatchStats.gameRecordOf([for (final e in _matches(ref)) e.match]),
);

final analyticsDeckRecordsProvider = Provider<List<DeckRecord>>(
  (ref) => Analytics.byDeck(_matches(ref)),
);

final analyticsMatchupProvider = Provider<MatchupMatrix>(
  (ref) => Analytics.matchup(_matches(ref)),
);

final analyticsPlayDrawProvider = Provider<PlayDrawSplit>(
  (ref) => Analytics.playDraw(_matches(ref)),
);

final analyticsTrendProvider = Provider<List<TrendPoint>>(
  (ref) => Analytics.monthlyTrend(_matches(ref)),
);

final analyticsMetaProvider = Provider<List<ArchetypeShare>>(
  (ref) => Analytics.meta(_matches(ref)),
);

/// How much history the shown game and format hold, other filters ignored.
///
/// What clearing would destroy, which is not what the section is drawing: the
/// period filter alone hides most of it most of the time.
final analyticsHistorySizeProvider = StreamProvider<HistorySize>((ref) {
  final gameId = ref.watch(analyticsGameProvider);
  final formatId = ref.watch(analyticsFormatProvider);

  if (gameId == null || formatId == null) {
    return Stream.value((tournaments: 0, matches: 0));
  }

  return ref
      .watch(analyticsRepositoryProvider)
      .watchHistorySize(gameId: gameId, formatId: formatId);
});

/// Whether any tournament round has ever been recorded, filters ignored.
///
/// It exists so the empty state can tell two situations apart that look
/// identical on screen: an app with nothing in it yet, which needs an
/// instruction, and filters that happen to exclude everything, which needs the
/// filters widened. Guessing from the filters themselves gets it wrong — the
/// period always has a value.
final analyticsHasAnyMatchProvider = StreamProvider<bool>((ref) {
  return ref
      .watch(analyticsRepositoryProvider)
      .watchMatches(const AnalyticsFilter())
      .map((matches) => matches.isNotEmpty);
});

/// The decks the deck filter can offer, archived ones included.
///
/// An archived deck is still the deck that played last season's tournaments,
/// and leaving it out would make that season impossible to look at.
final analyticsDeckChoicesProvider = StreamProvider<List<Deck>>((ref) {
  return ref
      .watch(deckRepositoryProvider)
      .watchDecks(
        gameId: ref.watch(analyticsGameProvider),
        formatId: ref.watch(analyticsFormatProvider),
        includeArchived: true,
      );
});
