import '../../data/db/seed.dart';

/// What a life total means in each game.
///
/// Yu-Gi-Oh! starts at 8000 and moves in hundreds; Magic starts at 20 and moves
/// in ones. Sharing one set of buttons between them would make one of the two
/// unusable: 8000 life in steps of 1, or 20 life in steps of 500.
///
/// A game the user added has no rules written for it and gets the Magic set:
/// a small total in steps of one, which is what nearly every card game outside
/// Yu-Gi-Oh! uses, and which the free field can always override. That fallback
/// is the `else` of every branch below on purpose — there is no third set of
/// numbers that would be right more often.
abstract final class LifeRules {
  static const _yugiohStart = 8000;
  static const _magicStart = 20;

  static const _yugiohSteps = [50, 100, 500, 1000];
  static const _magicSteps = [1, 2, 5, 10];

  static int startingLifeFor(String gameId) =>
      gameId == Seed.yugiohId ? _yugiohStart : _magicStart;

  static List<int> stepsFor(String gameId) =>
      gameId == Seed.yugiohId ? _yugiohSteps : _magicSteps;

  /// The step selected when a game opens: the one that covers a normal attack
  /// rather than the smallest possible change.
  static int defaultStepFor(String gameId) => gameId == Seed.yugiohId ? 500 : 1;

  /// Starting totals offered as one-tap presets, alongside the free field.
  ///
  /// 40 is Commander, 30 is two-headed giant, 4000 is the shorter Yu-Gi-Oh!
  /// format some locals use.
  static List<int> presetsFor(String gameId) =>
      gameId == Seed.yugiohId ? [8000, 4000, 2000] : [20, 40, 30];
}
