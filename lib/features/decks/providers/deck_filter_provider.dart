import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/db/app_database.dart';
import '../../../data/db/seed.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/archetype_repository.dart';
import '../../../data/repositories/deck_repository.dart';

/// What the deck library is currently showing.
///
/// A null [formatId] means every format of the selected game.
@immutable
class DeckFilter {
  const DeckFilter({
    this.gameId = Seed.yugiohId,
    this.formatId,
    this.showArchived = false,
  });

  final String gameId;
  final String? formatId;
  final bool showArchived;

  DeckFilter copyWith({
    String? gameId,
    String? formatId,
    bool clearFormat = false,
    bool? showArchived,
  }) {
    return DeckFilter(
      gameId: gameId ?? this.gameId,
      formatId: clearFormat ? null : (formatId ?? this.formatId),
      showArchived: showArchived ?? this.showArchived,
    );
  }
}

class DeckFilterNotifier extends Notifier<DeckFilter> {
  @override
  DeckFilter build() => const DeckFilter();

  /// Switching game always clears the format: a Modern filter means nothing
  /// once the list is showing Yu-Gi-Oh! decks.
  void selectGame(String gameId) {
    state = state.copyWith(gameId: gameId, clearFormat: true);
  }

  void selectFormat(String? formatId) {
    state = formatId == null
        ? state.copyWith(clearFormat: true)
        : state.copyWith(formatId: formatId);
  }

  void toggleArchived() {
    state = state.copyWith(showArchived: !state.showArchived);
  }

  /// Moves the library so a deck just saved is actually on screen.
  ///
  /// Without this, saving a deck for the other game — or for a format the
  /// filter is currently excluding — dropped it out of the list the moment it
  /// was created, which is indistinguishable from the save having failed.
  void reveal({required String gameId, required String formatId}) {
    final formatWouldHide =
        state.formatId != null && state.formatId != formatId;

    state = DeckFilter(
      gameId: gameId,
      formatId: formatWouldHide ? formatId : state.formatId,
      showArchived: state.showArchived,
    );
  }
}

final deckFilterProvider = NotifierProvider<DeckFilterNotifier, DeckFilter>(
  DeckFilterNotifier.new,
);

/// The game the library is actually showing.
///
/// The filter remembers a game id, and a game can be hidden — or deleted —
/// after it was remembered. Reading the filter directly would then leave the
/// library on a game with no chip to move off, showing nothing and looking
/// broken. Falling back to the first visible game keeps it usable, and the
/// filter's own value is left alone so bringing the game back restores it.
final deckGameProvider = Provider<String>((ref) {
  final selected = ref.watch(deckFilterProvider).gameId;
  final games = ref.watch(gamesProvider).valueOrNull ?? const <Game>[];

  if (games.isEmpty || games.any((game) => game.id == selected)) {
    return selected;
  }
  return games.first.id;
});

/// One shelf of the library: an archetype, and the builds filed under it.
///
/// [decks] is empty for an archetype that exists in the catalogue but that the
/// user has not built yet, which is most of them on a fresh install.
typedef DeckGroup = ({
  String archetype,
  String gameId,
  List<String> formatIds,
  List<Deck> decks,
});

/// The library at archetype level: every archetype of the scope, with the
/// user's builds filed under the right one.
///
/// Grouping is case-insensitive, so "Snake-Eye" and "snake-eye" are one pile
/// rather than two, and the pile takes the spelling of its most recent deck —
/// the user's spelling wins over the catalogue's.
///
/// Order: archetypes the user actually plays come first, in the order the deck
/// list came in (most recently updated first), because the deck being worked
/// on this week is the one worth having at the top. Everything else follows
/// alphabetically, which is the only useful order for a catalogue of two
/// hundred entries nobody has touched.
List<DeckGroup> buildArchetypeShelf({
  required String gameId,
  required List<Deck> decks,
  required List<OpponentArchetype> catalogue,
}) {
  String keyOf(String name) => name.trim().toLowerCase();

  final names = <String, String>{};
  final builds = <String, List<Deck>>{};
  final deckFormats = <String, List<String>>{};
  final catalogueFormats = <String, List<String>>{};
  final built = <String>[];

  for (final deck in decks) {
    final key = keyOf(deck.archetype);
    names.putIfAbsent(key, () => deck.archetype.trim());
    if (!built.contains(key)) built.add(key);
    builds.putIfAbsent(key, () => []).add(deck);
    deckFormats.putIfAbsent(key, () => []).add(deck.formatId);
  }

  final unbuilt = <String>[];
  for (final archetype in catalogue) {
    final key = keyOf(archetype.name);
    catalogueFormats.putIfAbsent(key, () => []).add(archetype.formatId);

    if (names.containsKey(key)) continue;
    names[key] = archetype.name.trim();
    unbuilt.add(key);
  }

  unbuilt.sort(
    (a, b) => names[a]!.toLowerCase().compareTo(names[b]!.toLowerCase()),
  );

  return [
    for (final key in [...built, ...unbuilt])
      (
        archetype: names[key]!,
        gameId: gameId,
        // The formats a built archetype is shown in are the ones it is built
        // in, not every format its name exists in: an Edison entry on a row
        // whose only deck is Advanced would be a claim about a deck that does
        // not exist.
        formatIds:
            (deckFormats[key] ?? catalogueFormats[key] ?? const <String>[])
                .toSet()
                .toList(),
        decks: builds[key] ?? const <Deck>[],
      ),
  ];
}

/// Every archetype the current game and format filter covers.
///
/// The library shows all of them, not only the ones with a deck behind them:
/// the archetype list is a catalogue of what is played in the format, and an
/// archetype with no build yet is exactly where a new deck gets filed.
final archetypeCatalogueProvider = StreamProvider<List<OpponentArchetype>>((
  ref,
) {
  final filter = ref.watch(deckFilterProvider);

  return ref
      .watch(archetypeRepositoryProvider)
      .watchScope(
        gameId: ref.watch(deckGameProvider),
        formatId: filter.formatId,
      );
});

/// The library at archetype level, builds and empty archetypes together.
final archetypeShelfProvider = Provider<List<DeckGroup>>((ref) {
  return buildArchetypeShelf(
    gameId: ref.watch(deckGameProvider),
    decks: ref.watch(filteredDecksProvider).valueOrNull ?? const [],
    catalogue: ref.watch(archetypeCatalogueProvider).valueOrNull ?? const [],
  );
});

final filteredDecksProvider = StreamProvider<List<Deck>>((ref) {
  final filter = ref.watch(deckFilterProvider);

  return ref
      .watch(deckRepositoryProvider)
      .watchDecks(
        gameId: ref.watch(deckGameProvider),
        formatId: filter.formatId,
        includeArchived: filter.showArchived,
      );
});

final deckByIdProvider = StreamProvider.family<Deck?, String>((ref, id) {
  return ref.watch(deckRepositoryProvider).watchDeck(id);
});

final deckCardsProvider = StreamProvider.family<List<DeckCard>, String>((
  ref,
  deckId,
) {
  return ref.watch(deckRepositoryProvider).watchCards(deckId);
});
