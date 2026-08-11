import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/utils/catalog_names.dart';
import '../../../data/db/app_database.dart';

import '../../../data/models/enums.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/layout/bar_insets.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/glass_app_bar.dart';
import '../providers/tournament_providers.dart';

/// Every tournament the user has recorded, newest first.
class TournamentsScreen extends ConsumerWidget {
  const TournamentsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tournaments = ref.watch(tournamentsProvider);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(title: Text(l10n.navTournaments)),
      floatingActionButton: LiftedFab(
        child: FloatingActionButton.extended(
          onPressed: () => context.push(AppRoute.newTournament.path),
          icon: const Icon(Icons.add),
          label: Text(l10n.actionNewTournament),
        ),
      ),
      // The filters are fixed rather than scrolling, so they are pushed clear
      // of the bar instead of passing under it; only the list below them moves.
      body: Padding(
        padding: const EdgeInsets.only(top: TopBar.inset),
        child: Column(
          children: [
            const _Filters(),
            const Divider(height: 1),
            Expanded(
              child: switch (tournaments) {
                AsyncData(:final value) when value.isEmpty => EmptyState(
                  icon: Icons.emoji_events_outlined,
                  title: l10n.tournamentsEmpty,
                  message: l10n.tournamentsEmptyHint,
                ),
                AsyncData(:final value) => ListView.separated(
                  padding: const EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    96,
                  ).clearingFloatingBar,
                  itemCount: value.length,
                  separatorBuilder: (_, _) => const SizedBox(height: 10),
                  itemBuilder: (context, index) =>
                      _TournamentCard(tournament: value[index]),
                ),
                AsyncError() => Center(child: Text(l10n.errorGeneric)),
                _ => const SizedBox.shrink(),
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _Filters extends ConsumerWidget {
  const _Filters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final filter = ref.watch(tournamentFilterProvider);
    final notifier = ref.read(tournamentFilterProvider.notifier);
    final games = ref.watch(gamesProvider).valueOrNull ?? const <Game>[];
    final formats = filter.gameId == null
        ? const <Format>[]
        : ref.watch(formatsProvider(filter.gameId!)).valueOrNull ??
              const <Format>[];

    // One row per question — game, then format, then status — instead of games
    // and formats sharing a line. Two different questions on one row read as
    // one list of alternatives, and the format chips ended up off the right
    // edge of a phone, where nobody looks for them.
    //
    // The format row is absent, not empty, until a game is chosen: a format
    // belongs to a game, and there is nothing sensible to offer before one is
    // picked.
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ChipRow(
            children: [
              _Chip(
                label: l10n.filterAll,
                selected: filter.gameId == null,
                onSelected: () => notifier.selectGame(null),
              ),
              for (final game in games)
                _Chip(
                  label: l10n.gameName(game.id, game.name),
                  selected: filter.gameId == game.id,
                  onSelected: () => notifier.selectGame(game.id),
                ),
            ],
          ),
          if (formats.isNotEmpty) ...[
            const SizedBox(height: 8),
            _ChipRow(
              children: [
                for (final format in formats)
                  _Chip(
                    label: l10n.formatName(format.id, format.name),
                    selected: filter.formatId == format.id,
                    onSelected: () => notifier.selectFormat(
                      filter.formatId == format.id ? null : format.id,
                    ),
                  ),
              ],
            ),
          ],
          const SizedBox(height: 8),
          _ChipRow(
            children: [
              for (final status in TournamentStatus.values)
                _Chip(
                  label: l10n.tournamentStatusName(status),
                  selected: filter.status == status,
                  onSelected: () => notifier.selectStatus(
                    filter.status == status ? null : status,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

/// One line of chips that scrolls sideways when it runs out of room.
class _ChipRow extends StatelessWidget {
  const _ChipRow({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 40,
      child: ListView(scrollDirection: Axis.horizontal, children: children),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
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

class _TournamentCard extends ConsumerWidget {
  const _TournamentCard({required this.tournament});

  final Tournament tournament;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final record = ref.watch(tournamentRecordProvider(tournament.id));
    // Hidden formats included: a tournament played in a format the user later
    // hid still has to name it.
    final formats =
        ref.watch(allFormatsProvider(tournament.gameId)).valueOrNull ??
        const <Format>[];
    final format = formats
        .where((f) => f.id == tournament.formatId)
        .firstOrNull;

    final accent = theme.gameAccent(tournament.gameId);

    return Card(
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRoute.tournamentDetail.routeName,
          pathParameters: {'id': tournament.id},
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: accent,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      tournament.name,
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (tournament.status == TournamentStatus.ongoing)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 3,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(
                          alpha: 0.18,
                        ),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        l10n.tournamentStatusOngoing.toUpperCase(),
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.primary,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                [
                  DateFormat.yMMMd(
                    Localizations.localeOf(context).toString(),
                  ).format(tournament.date),
                  if (format != null) l10n.formatName(format.id, format.name),
                  l10n.eventTypeName(tournament.eventType),
                ].join(' · '),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    record.isEmpty ? '—' : record.shortForm,
                    style: theme.textTheme.headlineSmall,
                  ),
                  if (!record.isEmpty) ...[
                    const SizedBox(width: 8),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        [
                          l10n.recordPoints(record.points),
                          if (record.byes > 0) l10n.recordByes(record.byes),
                        ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ],
                  const Spacer(),
                  if (tournament.finalStanding != null)
                    Text(
                      l10n.tournamentStandingValue(tournament.finalStanding!),
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
