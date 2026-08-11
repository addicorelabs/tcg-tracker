import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../data/db/app_database.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/layout/floating_bar_inset.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/deck_filter_provider.dart';
import 'widgets/deck_tile.dart';

/// Every build of one archetype.
///
/// It reads the same filtered list as the library rather than querying by name:
/// the game and format chips the user set are still in force here, so the
/// archetype opens on exactly the decks its row was counting.
class ArchetypeDecksScreen extends ConsumerWidget {
  const ArchetypeDecksScreen({required this.archetype, super.key});

  final String archetype;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final decks =
        ref.watch(filteredDecksProvider).valueOrNull ?? const <Deck>[];

    final mine = [
      for (final deck in decks)
        if (deck.archetype.trim().toLowerCase() ==
            archetype.trim().toLowerCase())
          deck,
    ];

    return Scaffold(
      appBar: AppBar(title: Text(archetype, overflow: TextOverflow.ellipsis)),
      floatingActionButton: LiftedFab(
        child: FloatingActionButton.extended(
          // Opens the editor already on this archetype: adding a build from
          // inside an archetype can only mean a build of that archetype.
          onPressed: () => context.push(
            '${AppRoute.newDeck.path}'
            '?archetype=${Uri.encodeQueryComponent(archetype)}',
          ),
          icon: const Icon(Icons.add),
          label: Text(l10n.deckNew),
        ),
      ),
      body: mine.isEmpty
          // Reachable by deleting the last build while standing here, which
          // leaves the screen open on an archetype that no longer exists.
          ? EmptyState(
              icon: Icons.style_outlined,
              title: l10n.decksEmpty,
              message: l10n.decksEmptyHint,
            )
          : ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                16,
                16,
                16,
                96,
              ).clearingFloatingBar,
              itemCount: mine.length,
              separatorBuilder: (_, _) => const SizedBox(height: 10),
              itemBuilder: (context, index) => DeckTile(deck: mine[index]),
            ),
    );
  }
}
