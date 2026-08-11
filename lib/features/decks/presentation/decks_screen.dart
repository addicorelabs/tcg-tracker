import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/utils/catalog_names.dart';
import '../../../data/db/app_database.dart';

import '../../../data/repositories/catalog_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/layout/floating_bar_inset.dart';
import '../../../shared/widgets/empty_state.dart';
import '../providers/deck_filter_provider.dart';

/// The deck library: everything the user plays, grouped by game and format.
class DecksScreen extends ConsumerWidget {
  const DecksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(deckFilterProvider);
    final decks = ref.watch(filteredDecksProvider);
    final shelf = ref.watch(archetypeShelfProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navDecks),
        actions: [
          IconButton(
            tooltip: l10n.archetypesTitle,
            icon: const Icon(Icons.groups_outlined),
            onPressed: () => context.push(AppRoute.archetypes.path),
          ),
          PopupMenuButton<void>(
            itemBuilder: (context) => [
              PopupMenuItem<void>(
                onTap: ref.read(deckFilterProvider.notifier).toggleArchived,
                child: Row(
                  children: [
                    Icon(
                      filter.showArchived
                          ? Icons.check_box_outlined
                          : Icons.check_box_outline_blank,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(l10n.deckShowArchived),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: LiftedFab(
        child: FloatingActionButton.extended(
          onPressed: () => context.push(AppRoute.newDeck.path),
          icon: const Icon(Icons.add),
          label: Text(l10n.deckNew),
        ),
      ),
      body: Column(
        children: [
          const _GameSelector(),
          const _FormatFilter(),
          const Divider(height: 1),
          Expanded(
            child: switch (decks) {
              // The shelf carries the archetype catalogue too, so it is empty
              // only when even that is — a database that has not seeded.
              AsyncData() when shelf.isEmpty => EmptyState(
                icon: Icons.style_outlined,
                title: l10n.decksEmpty,
                message: l10n.decksEmptyHint,
              ),
              AsyncData() => _ArchetypeList(groups: shelf),
              // The reason is on screen, not only in the console: when the
              // local database refuses to open there is no other way for the
              // user to tell that apart from an empty library.
              AsyncError(:final error) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    '${l10n.errorGeneric}\n\n$error',
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
              _ => const SizedBox.shrink(),
            },
          ),
        ],
      ),
    );
  }
}

/// The library at archetype level: one row per archetype, opening onto its
/// builds.
///
/// A library of thirty decks read as thirty rows is a wall; read as eight
/// archetypes it is a shelf. The individual builds are one tap away.
class _ArchetypeList extends StatelessWidget {
  const _ArchetypeList({required this.groups});

  final List<DeckGroup> groups;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96).clearingFloatingBar,
      itemCount: groups.length,
      separatorBuilder: (_, _) => const SizedBox(height: 10),
      itemBuilder: (context, index) => _ArchetypeCard(group: groups[index]),
    );
  }
}

class _ArchetypeCard extends ConsumerWidget {
  const _ArchetypeCard({required this.group});

  final DeckGroup group;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final decks = group.decks;

    // Hidden formats included: the row names the formats its builds are in.
    final formats =
        ref.watch(allFormatsProvider(group.gameId)).valueOrNull ??
        const <Format>[];
    final accent = theme.gameAccent(group.gameId);

    // The formats behind this row, in the order they came, so the newest
    // build's format leads.
    final names = <String>[];
    for (final formatId in group.formatIds) {
      final format = formats.where((f) => f.id == formatId).firstOrNull;
      if (format == null) continue;
      final name = l10n.formatName(format.id, format.name);
      if (!names.contains(name)) names.add(name);
    }

    // An archetype nobody has built yet is drawn quieter than one with decks
    // in it: on a fresh install the catalogue is two hundred rows long, and
    // the handful the user actually plays has to stand out of it.
    final empty = decks.isEmpty;

    return Card(
      child: InkWell(
        onTap: () => context.push(
          '${AppRoute.archetypeDecks.path}'
          '?name=${Uri.encodeQueryComponent(group.archetype)}',
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 12, 16),
          child: Row(
            children: [
              Container(
                width: 4,
                height: 40,
                decoration: BoxDecoration(
                  color: empty ? accent.withValues(alpha: 0.3) : accent,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      group.archetype,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: empty
                            ? theme.colorScheme.onSurfaceVariant
                            : theme.colorScheme.onSurface,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      [
                        if (empty)
                          l10n.deckNone
                        else
                          l10n.deckCount(decks.length),
                        ...names,
                      ].join(' · '),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GameSelector extends ConsumerWidget {
  const _GameSelector();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final games = ref.watch(gamesProvider).valueOrNull ?? const <Game>[];
    final selected = ref.watch(deckGameProvider);

    if (games.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: SizedBox(
        width: double.infinity,
        child: SegmentedButton<String>(
          segments: [
            for (final game in games)
              ButtonSegment(
                value: game.id,
                label: Text(
                  l10n.gameName(game.id, game.name),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
          selected: {selected},
          showSelectedIcon: false,
          onSelectionChanged: (selection) =>
              ref.read(deckFilterProvider.notifier).selectGame(selection.first),
        ),
      ),
    );
  }
}

class _FormatFilter extends ConsumerWidget {
  const _FormatFilter();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(deckFilterProvider);
    final formats =
        ref.watch(formatsProvider(ref.watch(deckGameProvider))).valueOrNull ??
        const <Format>[];

    return SizedBox(
      height: 52,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          _FilterChip(
            label: l10n.filterAll,
            selected: filter.formatId == null,
            onSelected: () =>
                ref.read(deckFilterProvider.notifier).selectFormat(null),
          ),
          for (final format in formats)
            _FilterChip(
              label: l10n.formatName(format.id, format.name),
              selected: filter.formatId == format.id,
              onSelected: () =>
                  ref.read(deckFilterProvider.notifier).selectFormat(format.id),
            ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onSelected,
  });

  final String label;
  final bool selected;
  final VoidCallback onSelected;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: ChoiceChip(
        label: Text(label),
        selected: selected,
        onSelected: (_) => onSelected(),
      ),
    );
  }
}
