import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../app/routes.dart';
import '../../../../app/theme.dart';
import '../../../../core/utils/catalog_names.dart';
import '../../../../data/db/app_database.dart';

import '../../../../data/repositories/catalog_repository.dart';
import '../../../../data/repositories/deck_repository.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../shared/widgets/mana_pips.dart';

/// One deck, as a row: what it is called and what it is legal in.
///
/// The archetype is deliberately absent: a deck is only ever shown inside its
/// own archetype, so naming it again would say the same thing twice.
class DeckTile extends ConsumerWidget {
  const DeckTile({required this.deck, super.key});

  final Deck deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    // Hidden formats included: this reads a name back, it does not offer a
    // choice, and a deck filed under a format the user later hid still has to
    // say which format that was.
    final formats =
        ref.watch(allFormatsProvider(deck.gameId)).valueOrNull ??
        const <Format>[];

    final format = formats.where((f) => f.id == deck.formatId).firstOrNull;
    final accent = theme.gameAccent(deck.gameId);

    return Card(
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRoute.editDeck.routeName,
          pathParameters: {'id': deck.id},
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 8, 14),
          child: Row(
            children: [
              // The photo doubles as the game's colour bar when there is one.
              if (deck.photo != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.memory(
                    deck.photo!,
                    width: 44,
                    height: 44,
                    fit: BoxFit.cover,
                  ),
                )
              else
                Container(
                  width: 4,
                  height: 40,
                  decoration: BoxDecoration(
                    color: deck.isActive
                        ? accent
                        : theme.colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            deck.name,
                            style: theme.textTheme.titleMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (deck.colors != null) ...[
                          const SizedBox(width: 8),
                          ManaPips(deck.colors),
                        ],
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (format != null)
                          l10n.formatName(format.id, format.name),
                        if (!deck.isActive) l10n.deckArchived,
                      ].join(' Â· '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              _DeckMenu(deck: deck),
            ],
          ),
        ),
      ),
    );
  }
}

class _DeckMenu extends ConsumerWidget {
  const _DeckMenu({required this.deck});

  final Deck deck;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repository = ref.read(deckRepositoryProvider);

    return PopupMenuButton<_DeckAction>(
      onSelected: (action) async {
        switch (action) {
          case _DeckAction.duplicate:
            await repository.duplicateDeck(
              deck.id,
              newName: '${deck.name} (${l10n.deckCopySuffix})',
            );
          case _DeckAction.archive:
            await repository.setArchived(deck.id, isArchived: deck.isActive);
          case _DeckAction.delete:
            final result = await repository.deleteDeck(deck.id);
            if (result == DeckDeletionResult.inUse) {
              messenger.showSnackBar(
                SnackBar(content: Text(l10n.deckDeleteInUse)),
              );
            }
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: _DeckAction.duplicate,
          child: Text(l10n.deckDuplicate),
        ),
        PopupMenuItem(
          value: _DeckAction.archive,
          child: Text(deck.isActive ? l10n.deckArchive : l10n.deckRestore),
        ),
        PopupMenuItem(
          value: _DeckAction.delete,
          child: Text(l10n.actionDelete),
        ),
      ],
    );
  }
}

enum _DeckAction { duplicate, archive, delete }
