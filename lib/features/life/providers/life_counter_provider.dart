import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/life/life_rules.dart';
import '../domain/life_game.dart';

/// The game currently on the table, or null when none has been started.
///
/// Held in a provider rather than in the screen so walking over to the
/// tournament list mid-game and coming back does not reset the totals. It is
/// deliberately not persisted: a life counter is for the game being played, and
/// finding yesterday's totals waiting would be worse than finding none.
class LifeCounterNotifier extends Notifier<LifeGame?> {
  LifeCounterNotifier({Random? random}) : _random = random ?? Random();

  final Random _random;

  @override
  LifeGame? build() => null;

  void start({required String gameId, int? startingLife}) {
    state = LifeGame.fresh(
      gameId: gameId,
      startingLife: startingLife ?? LifeRules.startingLifeFor(gameId),
    );
  }

  void clear() => state = null;

  /// Replays the current game from its starting totals, keeping the setup.
  void restart() {
    final game = state;
    if (game == null) return;

    state = LifeGame.fresh(
      gameId: game.gameId,
      startingLife: game.startingLife,
    );
  }

  void adjustLife(Seat seat, int delta) {
    final game = state;
    if (game == null || delta == 0) return;

    final total = game.seat(seat).life + delta;
    final updated = game.seat(seat).copyWith(life: total);

    state = _withSeat(game, seat, updated).copyWith(
      log: [
        ...game.log,
        LifeChanged(seat: seat, delta: delta, total: total, at: DateTime.now()),
      ],
    );
  }

  void adjustCounter(Seat seat, CounterKind kind, int delta) {
    final game = state;
    if (game == null || delta == 0) return;

    // Counters never go negative: there is no such thing as minus one poison.
    final total = max(0, game.seat(seat).counter(kind) + delta);
    if (total == game.seat(seat).counter(kind)) return;

    final updated = game
        .seat(seat)
        .copyWith(counters: {...game.seat(seat).counters, kind: total});

    state = _withSeat(game, seat, updated).copyWith(
      log: [
        ...game.log,
        CounterChanged(
          seat: seat,
          kind: kind,
          delta: delta,
          total: total,
          at: DateTime.now(),
        ),
      ],
    );
  }

  /// Takes back the last change to a total.
  ///
  /// Dice and coin results are left alone: they are a record of what happened
  /// at the table, and undoing one would be rewriting it.
  void undo() {
    final game = state;
    if (game == null) return;

    final index = game.log.lastIndexWhere(
      (event) => event is LifeChanged || event is CounterChanged,
    );
    if (index < 0) return;

    final event = game.log[index];
    final log = [...game.log]..removeAt(index);

    state = switch (event) {
      LifeChanged(:final seat, :final delta) => _withSeat(
        game,
        seat,
        game.seat(seat).copyWith(life: game.seat(seat).life - delta),
      ).copyWith(log: log),
      CounterChanged(:final seat, :final kind, :final delta) => _withSeat(
        game,
        seat,
        game
            .seat(seat)
            .copyWith(
              counters: {
                ...game.seat(seat).counters,
                kind: max(0, game.seat(seat).counter(kind) - delta),
              },
            ),
      ).copyWith(log: log),
      _ => game,
    };
  }

  /// Rolls a die and returns the result, which is also written to the log.
  int rollDice(int sides) {
    final value = _random.nextInt(sides) + 1;
    _record(DiceRolled(sides: sides, value: value, at: DateTime.now()));
    return value;
  }

  /// Flips a coin, true for heads.
  bool flipCoin() {
    final heads = _random.nextBool();
    _record(CoinFlipped(heads: heads, at: DateTime.now()));
    return heads;
  }

  void _record(LifeEvent event) {
    final game = state;
    if (game == null) return;
    state = game.copyWith(log: [...game.log, event]);
  }

  LifeGame _withSeat(LifeGame game, Seat seat, SeatState updated) {
    return seat == Seat.me
        ? game.copyWith(me: updated)
        : game.copyWith(opponent: updated);
  }
}

final lifeCounterProvider = NotifierProvider<LifeCounterNotifier, LifeGame?>(
  LifeCounterNotifier.new,
);
