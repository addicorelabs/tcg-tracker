import '../../data/db/app_database.dart';
import '../../data/models/enums.dart';

/// Win-loss-draw record over a set of matches.
///
/// Byes are counted separately on purpose: they belong in the record a player
/// quotes, but they have no opponent, so including them in a winrate would
/// inflate it. See `docs/architettura.md`, section 7.
class MatchRecord {
  const MatchRecord({
    this.wins = 0,
    this.losses = 0,
    this.draws = 0,
    this.byes = 0,
  });

  final int wins;
  final int losses;
  final int draws;
  final int byes;

  /// Matches with a real opponent. This, not the number of rounds, is the
  /// denominator of every winrate in the app.
  int get decidedMatches => wins + losses + draws;

  int get roundsPlayed => decidedMatches + byes;

  /// Null when nothing has been played yet: no data and a zero winrate are
  /// different things and must look different on screen.
  double? get winrate => decidedMatches == 0 ? null : wins / decidedMatches;

  /// Swiss points: 3 for a win, 1 for a draw, 0 for a loss.
  ///
  /// A bye scores as a win, and this is the only place it counts for anything.
  /// The organiser awards it exactly like a win, so a record that scored it as
  /// anything else would not match the standings sheet the user is reading
  /// from. Winrates and every analytics figure still ignore byes entirely.
  int get points => (wins + byes) * 3 + draws;

  bool get isEmpty => roundsPlayed == 0;

  /// "5-2", or "5-2-1" once there is a draw. Byes are not part of this string:
  /// the interface appends them itself, so they stay visible as an aside.
  String get shortForm => draws == 0 ? '$wins-$losses' : '$wins-$losses-$draws';

  MatchRecord operator +(MatchRecord other) => MatchRecord(
    wins: wins + other.wins,
    losses: losses + other.losses,
    draws: draws + other.draws,
    byes: byes + other.byes,
  );
}

/// Individual games won and lost, again ignoring byes.
class GameRecord {
  const GameRecord({this.won = 0, this.lost = 0, this.drawn = 0});

  final int won;
  final int lost;
  final int drawn;

  int get total => won + lost + drawn;

  double? get winrate => total == 0 ? null : won / total;
}

/// Every rule about how matches turn into numbers, in one place.
///
/// Screens never re-implement any of this: a bye or a top cut match must behave
/// the same everywhere, and the only way to guarantee that is to have a single
/// implementation.
abstract final class MatchStats {
  static MatchRecord recordOf(Iterable<Match> matches) {
    var wins = 0;
    var losses = 0;
    var draws = 0;
    var byes = 0;

    for (final match in matches) {
      switch (match.result) {
        case MatchResult.win:
          wins++;
        case MatchResult.loss:
          losses++;
        case MatchResult.draw:
          draws++;
        case MatchResult.bye:
          byes++;
      }
    }

    return MatchRecord(wins: wins, losses: losses, draws: draws, byes: byes);
  }

  static GameRecord gameRecordOf(Iterable<Match> matches) {
    var won = 0;
    var lost = 0;
    var drawn = 0;

    for (final match in matches.where(_counts)) {
      won += match.gamesWon;
      lost += match.gamesLost;
      drawn += match.gamesDrawn;
    }

    return GameRecord(won: won, lost: lost, drawn: drawn);
  }

  /// The matches that feed statistics: everything with a real opponent.
  static Iterable<Match> decided(Iterable<Match> matches) =>
      matches.where(_counts);

  /// Works out the result from the games, since a match result is never typed
  /// in directly.
  static MatchResult resultOf({
    required bool isBye,
    required int gamesWon,
    required int gamesLost,
  }) {
    if (isBye) return MatchResult.bye;
    if (gamesWon > gamesLost) return MatchResult.win;
    if (gamesWon < gamesLost) return MatchResult.loss;
    return MatchResult.draw;
  }

  static bool _counts(Match match) => match.result.countsTowardsWinrate;
}
