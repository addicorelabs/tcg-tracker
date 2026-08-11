import '../../data/db/seed.dart';
import '../../data/models/enums.dart';

/// What each game's tournament circuit actually looks like.
///
/// The two games share one `event_type` column and one `top_cut_size` column,
/// but not one circuit: Yu-Gi-Oh! runs OTS and continental events and cuts as
/// deep as a top 64, while Magic runs store championships, showdowns and PTQs
/// and stops at a top 16. Offering either game the other's options would let
/// the user record a tournament that cannot exist.
abstract final class EventOptions {
  static const _yugioh = [
    EventType.local,
    EventType.online,
    EventType.ots,
    EventType.regional,
    EventType.ycs,
    EventType.national,
    EventType.continental,
    EventType.worlds,
  ];

  static const _magic = [
    EventType.local,
    EventType.storeChampionship,
    EventType.showdown,
    EventType.regional,
    EventType.ptq,
    EventType.worlds,
    EventType.online,
  ];

  /// What a game the user added is offered: the kinds of event that exist in
  /// every circuit, with nothing specific to either of the two shipped ones.
  /// The app knows nothing about that game, so the honest answer is the small
  /// list rather than a guess at which of the two it resembles.
  static const _fallback = [
    EventType.local,
    EventType.online,
    EventType.regional,
    EventType.national,
    EventType.worlds,
  ];

  static const _yugiohTopCuts = [4, 8, 16, 32, 64];
  static const _magicTopCuts = [4, 8, 16];

  static List<EventType> typesFor(String gameId) => switch (gameId) {
    Seed.yugiohId => _yugioh,
    Seed.magicId => _magic,
    _ => _fallback,
  };

  /// A game the user added gets the shorter list: a top 4, 8 or 16 covers what
  /// a local event actually cuts to, and a stored size outside it stays
  /// visible anyway through [topCutSizesForEditing].
  static List<int> topCutSizesFor(String gameId) => switch (gameId) {
    Seed.yugiohId => _yugiohTopCuts,
    Seed.magicId || _ => _magicTopCuts,
  };

  /// The types to show in an editor, which is the game's own list plus
  /// [current] when it is not in it.
  ///
  /// Without this, a tournament recorded before these lists existed — or under
  /// a game whose circuit has since changed — would open with its own type
  /// missing from the chips, and saving would silently move it to another one.
  static List<EventType> typesForEditing(String gameId, EventType? current) {
    final types = typesFor(gameId);
    if (current == null || types.contains(current)) return types;
    return [...types, current];
  }

  /// The top cut sizes to show, likewise keeping a stored odd size visible.
  static List<int> topCutSizesForEditing(String gameId, int? current) {
    final sizes = topCutSizesFor(gameId);
    if (current == null || sizes.contains(current)) return sizes;
    return [...sizes, current]..sort();
  }
}
