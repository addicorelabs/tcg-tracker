import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/utils/catalog_names.dart';
import '../../../data/db/app_database.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/archetype_repository.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/tournament_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/layout/bar_insets.dart';
import '../../../shared/widgets/deck_label.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/glass_app_bar.dart';
import '../../../shared/widgets/result_chip.dart';
import '../../../shared/widgets/section_label.dart';
import '../../decks/providers/deck_filter_provider.dart';
import '../providers/tournament_providers.dart';

/// A single tournament: what it was, how it went, and every round in it.
class TournamentDetailScreen extends ConsumerWidget {
  const TournamentDetailScreen({required this.tournamentId, super.key});

  final String tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tournament = ref.watch(tournamentByIdProvider(tournamentId));

    return switch (tournament) {
      AsyncData(value: final tournament?) => _Detail(tournament: tournament),
      AsyncData() || AsyncError() => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.errorGeneric)),
      ),
      _ => Scaffold(appBar: AppBar(), body: const SizedBox.shrink()),
    };
  }
}

class _Detail extends ConsumerWidget {
  const _Detail({required this.tournament});

  final Tournament tournament;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final matches =
        ref.watch(tournamentMatchesProvider(tournament.id)).valueOrNull ??
        const <Match>[];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(
        title: Text(tournament.name, overflow: TextOverflow.ellipsis),
        actions: [
          PopupMenuButton<_DetailAction>(
            onSelected: (action) => _handle(context, ref, action),
            itemBuilder: (context) => [
              PopupMenuItem(
                value: _DetailAction.edit,
                child: Text(l10n.tournamentEdit),
              ),
              if (tournament.status == TournamentStatus.finished)
                PopupMenuItem(
                  value: _DetailAction.reopen,
                  child: Text(l10n.tournamentReopen),
                )
              else
                PopupMenuItem(
                  value: _DetailAction.finish,
                  child: Text(l10n.tournamentFinish),
                ),
              PopupMenuItem(
                value: _DetailAction.delete,
                child: Text(l10n.tournamentDelete),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: LiftedFab(
        child: FloatingActionButton.extended(
          onPressed: () => context.pushNamed(
            AppRoute.newRound.routeName,
            pathParameters: {'id': tournament.id},
          ),
          icon: const Icon(Icons.add),
          label: Text(l10n.roundNew),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          16,
          16,
          96,
        ).clearingFloatingBar.clearingAppBar,
        children: [
          _Header(tournament: tournament),
          const SizedBox(height: 24),
          SectionLabel(l10n.navTournaments),
          const SizedBox(height: 12),
          if (matches.isEmpty)
            EmptyState(
              icon: Icons.playlist_add_outlined,
              title: l10n.roundsEmpty,
              message: l10n.roundsEmptyHint,
            )
          else
            for (final match in matches) ...[
              _RoundTile(tournament: tournament, match: match),
              const SizedBox(height: 8),
            ],
        ],
      ),
    );
  }

  Future<void> _handle(
    BuildContext context,
    WidgetRef ref,
    _DetailAction action,
  ) async {
    final l10n = AppLocalizations.of(context);
    final router = GoRouter.of(context);
    final repository = ref.read(tournamentRepositoryProvider);

    switch (action) {
      case _DetailAction.edit:
        await router.pushNamed(
          AppRoute.editTournament.routeName,
          pathParameters: {'id': tournament.id},
        );

      case _DetailAction.reopen:
        await repository.reopen(tournament.id);

      case _DetailAction.finish:
        if (!context.mounted) return;
        final standing = await _askStanding(context);
        await repository.finish(tournament.id, finalStanding: standing);

      case _DetailAction.delete:
        if (!context.mounted) return;
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(l10n.tournamentDelete),
            content: Text(l10n.tournamentDeleteConfirm),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(l10n.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(l10n.actionDelete),
              ),
            ],
          ),
        );

        if (confirmed ?? false) {
          await repository.delete(tournament.id);
          router.pop();
        }
    }
  }

  /// Asks where the user placed. Skipping it is fine: not every event
  /// publishes standings.
  Future<int?> _askStanding(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();

    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.tournamentStanding),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(helperText: l10n.fieldOptional),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionSave),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(context).pop(int.tryParse(controller.text.trim())),
            child: Text(l10n.tournamentFinish),
          ),
        ],
      ),
    );
  }
}

enum _DetailAction { edit, finish, reopen, delete }

class _Header extends ConsumerWidget {
  const _Header({required this.tournament});

  final Tournament tournament;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final record = ref.watch(tournamentRecordProvider(tournament.id));

    // Hidden formats included: this names the format the tournament was
    // played in, which does not change because the format left the menus.
    final formats =
        ref.watch(allFormatsProvider(tournament.gameId)).valueOrNull ??
        const <Format>[];
    final format = formats
        .where((f) => f.id == tournament.formatId)
        .firstOrNull;
    final deck = ref.watch(deckByIdProvider(tournament.deckId)).valueOrNull;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              [
                DateFormat.yMMMMd(
                  Localizations.localeOf(context).toString(),
                ).format(tournament.date),
                if (format != null) l10n.formatName(format.id, format.name),
                l10n.eventTypeName(tournament.eventType),
                if (tournament.participantCount != null)
                  '${tournament.participantCount} ${l10n.tournamentParticipants.toLowerCase()}',
              ].join(' · '),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (deck != null) ...[
              const SizedBox(height: 6),
              DeckLabel(deck: deck, nameStyle: theme.textTheme.titleMedium),
            ],
            const SizedBox(height: 20),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.statRecord.toUpperCase(),
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.isEmpty ? '—' : record.shortForm,
                      style: theme.textTheme.displaySmall,
                    ),
                    if (record.byes > 0)
                      Text(
                        l10n.recordByes(record.byes),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                  ],
                ),
                const SizedBox(width: 20),
                // Points sit next to the record because they answer a
                // different question: the record is how it went, the points are
                // what the standings sheet says.
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      l10n.statPoints.toUpperCase(),
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      record.isEmpty ? '—' : '${record.points}',
                      style: theme.textTheme.displaySmall,
                    ),
                  ],
                ),
                const Spacer(),
                // Flexible, because the record and the points take priority:
                // a long status word must shorten rather than push the numbers
                // off the card.
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        l10n
                            .tournamentStatusName(tournament.status)
                            .toUpperCase(),
                        style: theme.textTheme.labelSmall,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (tournament.finalStanding != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          l10n.tournamentStandingValue(
                            tournament.finalStanding!,
                          ),
                          style: theme.textTheme.headlineSmall,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundTile extends ConsumerWidget {
  const _RoundTile({required this.tournament, required this.match});

  final Tournament tournament;
  final Match match;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final archetypes =
        ref
            .watch(
              archetypesProvider((
                gameId: match.gameId,
                formatId: match.formatId,
              )),
            )
            .valueOrNull ??
        const <OpponentArchetype>[];
    final archetype = archetypes
        .where((a) => a.id == match.opponentArchetypeId)
        .firstOrNull;

    final heading = match.isTopCut
        ? l10n.roundTopCut
        : l10n.roundNumber(match.roundNumber ?? 0);

    return Card(
      child: InkWell(
        onTap: () => context.pushNamed(
          AppRoute.editRound.routeName,
          pathParameters: {'id': tournament.id, 'matchId': match.id},
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      heading.toUpperCase(),
                      style: theme.textTheme.labelSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      archetype?.name ??
                          match.opponentName ??
                          (match.result == MatchResult.bye
                              ? l10n.resultBye
                              : l10n.matchOpponentDeckUnknown),
                      style: theme.textTheme.titleMedium,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (match.result != MatchResult.bye) ...[
                      const SizedBox(height: 2),
                      Text(
                        [
                          '${match.gamesWon}-${match.gamesLost}'
                              '${match.gamesDrawn > 0 ? '-${match.gamesDrawn}' : ''}',
                          if (match.onThePlay != null)
                            match.onThePlay!
                                ? l10n.matchPlayShort
                                : l10n.matchDrawShort,
                        ].join(' · '),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(width: 12),
              ResultChip(match.result),
            ],
          ),
        ),
      ),
    );
  }
}
