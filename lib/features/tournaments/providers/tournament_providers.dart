import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/stats/match_stats.dart';
import '../../../data/db/app_database.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/match_repository.dart';
import '../../../data/repositories/tournament_repository.dart';

class TournamentFilterNotifier extends Notifier<TournamentFilter> {
  @override
  TournamentFilter build() => const TournamentFilter();

  /// Switching game always clears the format, which belonged to the old one.
  void selectGame(String? gameId) {
    state = gameId == null
        ? state.copyWith(clearGame: true, clearFormat: true)
        : state.copyWith(gameId: gameId, clearFormat: true);
  }

  void selectFormat(String? formatId) {
    state = formatId == null
        ? state.copyWith(clearFormat: true)
        : state.copyWith(formatId: formatId);
  }

  void selectStatus(TournamentStatus? status) {
    state = status == null
        ? state.copyWith(clearStatus: true)
        : state.copyWith(status: status);
  }
}

final tournamentFilterProvider =
    NotifierProvider<TournamentFilterNotifier, TournamentFilter>(
      TournamentFilterNotifier.new,
    );

final tournamentsProvider = StreamProvider<List<Tournament>>((ref) {
  return ref
      .watch(tournamentRepositoryProvider)
      .watchTournaments(ref.watch(tournamentFilterProvider));
});

final tournamentByIdProvider = StreamProvider.family<Tournament?, String>((
  ref,
  id,
) {
  return ref.watch(tournamentRepositoryProvider).watchTournament(id);
});

final ongoingTournamentProvider = StreamProvider<Tournament?>((ref) {
  return ref.watch(tournamentRepositoryProvider).watchOngoing();
});

final tournamentMatchesProvider = StreamProvider.family<List<Match>, String>((
  ref,
  tournamentId,
) {
  return ref
      .watch(matchRepositoryProvider)
      .watchTournamentMatches(tournamentId);
});

/// Record of a tournament, always derived from its matches so the two can
/// never disagree.
final tournamentRecordProvider = Provider.family<MatchRecord, String>((
  ref,
  tournamentId,
) {
  final matches =
      ref.watch(tournamentMatchesProvider(tournamentId)).valueOrNull ??
      const <Match>[];

  return MatchStats.recordOf(matches);
});

final matchByIdProvider = StreamProvider.family<Match?, String>((ref, id) {
  return ref.watch(matchRepositoryProvider).watchMatch(id);
});

/// Tournament matches of the last 30 days, behind the dashboard tiles.
///
/// Casual matches are left out, matching the default of the analytics section.
final recentCompetitiveMatchesProvider = StreamProvider<List<Match>>((ref) {
  final since = DateTime.now().subtract(const Duration(days: 30));
  return ref.watch(matchRepositoryProvider).watchCompetitiveMatchesSince(since);
});

/// Every tournament, ignoring the list filters.
///
/// Separate from [tournamentsProvider] on purpose: the dashboard must not
/// change because of a filter the user set on another screen.
final allTournamentsProvider = StreamProvider<List<Tournament>>((ref) {
  return ref.watch(tournamentRepositoryProvider).watchTournaments();
});

/// Tournaments played in the last 30 days.
final recentTournamentCountProvider = Provider<int>((ref) {
  final since = DateTime.now().subtract(const Duration(days: 30));
  final tournaments =
      ref.watch(allTournamentsProvider).valueOrNull ?? const <Tournament>[];

  return tournaments.where((t) => t.date.isAfter(since)).length;
});
