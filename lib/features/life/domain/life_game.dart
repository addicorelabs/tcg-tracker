import 'package:flutter/foundation.dart';

/// The two seats at the table.
///
/// Only two: the counter is for a match, and both games are played one against
/// one in every format this app tracks.
enum Seat { me, opponent }

/// Tokens worth counting beside life.
///
/// Poison and energy are Magic's; a plain counter covers everything else,
/// including anything Yu-Gi-Oh! needs, without inventing a list per game.
enum CounterKind { poison, energy, experience, generic }

/// Something that happened, in the order it happened.
///
/// Kept so a contested count can be rebuilt, and so the last mistake can be
/// taken back without recomputing the total by hand.
@immutable
sealed class LifeEvent {
  const LifeEvent(this.at);

  final DateTime at;
}

class LifeChanged extends LifeEvent {
  const LifeChanged({
    required this.seat,
    required this.delta,
    required this.total,
    required DateTime at,
  }) : super(at);

  final Seat seat;
  final int delta;

  /// The total this change produced, so the log reads without adding up.
  final int total;
}

class CounterChanged extends LifeEvent {
  const CounterChanged({
    required this.seat,
    required this.kind,
    required this.delta,
    required this.total,
    required DateTime at,
  }) : super(at);

  final Seat seat;
  final CounterKind kind;
  final int delta;
  final int total;
}

class DiceRolled extends LifeEvent {
  const DiceRolled({
    required this.sides,
    required this.value,
    required DateTime at,
  }) : super(at);

  final int sides;
  final int value;
}

class CoinFlipped extends LifeEvent {
  const CoinFlipped({required this.heads, required DateTime at}) : super(at);

  final bool heads;
}

/// One player's totals.
@immutable
class SeatState {
  const SeatState({required this.life, this.counters = const {}});

  final int life;
  final Map<CounterKind, int> counters;

  int counter(CounterKind kind) => counters[kind] ?? 0;

  /// Counters actually in play, so an untouched counter never takes up room.
  Map<CounterKind, int> get active => {
    for (final entry in counters.entries)
      if (entry.value != 0) entry.key: entry.value,
  };

  SeatState copyWith({int? life, Map<CounterKind, int>? counters}) {
    return SeatState(
      life: life ?? this.life,
      counters: counters ?? this.counters,
    );
  }
}

/// A game in progress at the table.
@immutable
class LifeGame {
  const LifeGame({
    required this.gameId,
    required this.startingLife,
    required this.me,
    required this.opponent,
    this.log = const [],
  });

  LifeGame.fresh({required this.gameId, required this.startingLife})
    : me = SeatState(life: startingLife),
      opponent = SeatState(life: startingLife),
      log = const [];

  final String gameId;
  final int startingLife;
  final SeatState me;
  final SeatState opponent;
  final List<LifeEvent> log;

  SeatState seat(Seat seat) => seat == Seat.me ? me : opponent;

  /// Whoever has run out. Null while both are still standing.
  ///
  /// Reported, never acted on: the app does not end the game, because a player
  /// at 0 life may still be about to gain some back before anyone scoops.
  Seat? get defeated {
    if (me.life <= 0) return Seat.me;
    if (opponent.life <= 0) return Seat.opponent;
    return null;
  }

  LifeGame copyWith({
    SeatState? me,
    SeatState? opponent,
    List<LifeEvent>? log,
  }) {
    return LifeGame(
      gameId: gameId,
      startingLife: startingLife,
      me: me ?? this.me,
      opponent: opponent ?? this.opponent,
      log: log ?? this.log,
    );
  }
}
