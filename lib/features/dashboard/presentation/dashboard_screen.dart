import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/stats/match_stats.dart';
import '../../../core/utils/catalog_names.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/section_label.dart';
import '../../../shared/widgets/stat_tile.dart';
import '../../tournaments/providers/tournament_providers.dart';

/// Landing screen.
///
/// The numbers are placeholders until F1 lands the database: the layout is
/// built around the empty state on purpose, because that is what the app looks
/// like on the day it is installed.
class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          const SliverToBoxAdapter(child: _Hero()),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            sliver: SliverList.list(
              children: [
                const _OngoingTournamentCard(),
                const SizedBox(height: 28),
                SectionLabel(l10n.statsLast30Days),
                const SizedBox(height: 12),
                const _StatsGrid(),
                const SizedBox(height: 28),
                SectionLabel(l10n.quickActions),
                const SizedBox(height: 12),
                const _QuickActions(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Gradient banner that gives the app a face before any data exists.
class _Hero extends ConsumerWidget {
  const _Hero();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    // Read from the catalogue rather than written out: a game the user added
    // belongs on the banner exactly as much as the two that ship with the app.
    final games = ref.watch(gamesProvider).valueOrNull ?? const <Game>[];

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: theme.appColors.heroGradient,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 28, 20, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    l10n.appTitle.toUpperCase(),
                    style: theme.textTheme.titleMedium?.copyWith(
                      letterSpacing: 3,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              // Wrap, not Row: "Magic: The Gathering" written in full does not
              // fit next to the other chip on a narrow phone.
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final game in games)
                    _GameChip(
                      label: l10n.gameName(game.id, game.name),
                      color: theme.gameAccent(game.id),
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

/// Game identity in its smallest form: a coloured dot plus the name.
class _GameChip extends StatelessWidget {
  const _GameChip({required this.label, required this.color});

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 7,
            height: 7,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 7),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 0.6,
            ),
          ),
        ],
      ),
    );
  }
}

class _OngoingTournamentCard extends ConsumerWidget {
  const _OngoingTournamentCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final tournament = ref.watch(ongoingTournamentProvider).valueOrNull;

    if (tournament == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionLabel(l10n.ongoingTournament),
              const SizedBox(height: 16),
              Row(
                children: [
                  Icon(
                    Icons.emoji_events_outlined,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          l10n.noOngoingTournament,
                          style: theme.textTheme.titleMedium,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          l10n.noOngoingTournamentHint,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
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

    final record = ref.watch(tournamentRecordProvider(tournament.id));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(l10n.ongoingTournament),
            const SizedBox(height: 12),
            Text(tournament.name, style: theme.textTheme.titleMedium),
            const SizedBox(height: 16),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  record.isEmpty ? '—' : record.shortForm,
                  style: theme.textTheme.displaySmall,
                ),
                const SizedBox(width: 12),
                Padding(
                  padding: const EdgeInsets.only(bottom: 6),
                  child: Text(
                    l10n.roundNumber(record.roundsPlayed + 1),
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => context.pushNamed(
                  AppRoute.newRound.routeName,
                  pathParameters: {'id': tournament.id},
                ),
                icon: const Icon(Icons.add),
                label: Text(l10n.actionRecordRound.toUpperCase()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatsGrid extends ConsumerWidget {
  const _StatsGrid();

  static const double _gap = 12;
  static const double _threeColumnBreakpoint = 520;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final matches =
        ref.watch(recentCompetitiveMatchesProvider).valueOrNull ??
        const <Match>[];
    final record = MatchStats.recordOf(matches);
    final tournaments = ref.watch(recentTournamentCountProvider);
    final winrate = record.winrate;

    final tiles = [
      StatTile(
        label: l10n.statWinrate,
        value: winrate == null ? null : '${(winrate * 100).round()}%',
        // The sample matters as much as the number: 100% off two matches is
        // not the same claim as 62% off forty.
        caption: record.decidedMatches == 0
            ? null
            : l10n.recordSample(record.decidedMatches),
      ),
      StatTile(
        label: l10n.statTournaments,
        value: tournaments == 0 ? null : '$tournaments',
      ),
      StatTile(
        label: l10n.statMatches,
        value: record.isEmpty ? null : '${record.roundsPlayed}',
      ),
    ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = constraints.maxWidth >= _threeColumnBreakpoint ? 3 : 2;
        final columnWidth =
            (constraints.maxWidth - _gap * (columns - 1)) / columns;

        return Wrap(
          spacing: _gap,
          runSpacing: _gap,
          children: [
            for (var i = 0; i < tiles.length; i++)
              SizedBox(
                // In two-column mode the last tile spans the full row, so the
                // grid never ends with a hole next to it.
                width: columns == 2 && i == tiles.length - 1
                    ? constraints.maxWidth
                    : columnWidth,
                child: tiles[i],
              ),
          ],
        );
      },
    );
  }
}

class _QuickActions extends StatelessWidget {
  const _QuickActions();

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () => context.push(AppRoute.newTournament.path),
            icon: const Icon(Icons.add),
            label: Text(l10n.actionNewTournament.toUpperCase()),
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => context.push(AppRoute.newMatch.path),
            icon: const Icon(Icons.favorite_outline),
            label: Text(l10n.actionNewMatch.toUpperCase()),
          ),
        ),
      ],
    );
  }
}
