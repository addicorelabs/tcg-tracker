import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/stats/analytics.dart';
import '../../../core/utils/catalog_names.dart';
import '../../../core/utils/formatting.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/analytics_repository.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/layout/floating_bar_inset.dart';
import '../../../shared/widgets/deck_label.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/section_label.dart';
import '../../../shared/widgets/stat_tile.dart';
import '../providers/analytics_providers.dart';
import 'widgets/matchup_grid.dart';
import 'widgets/trend_chart.dart';
import 'widgets/winrate_row.dart';

/// Everything the recorded matches add up to.
///
/// Only tournament rounds are counted, and byes never reach a winrate: the
/// rules live in `core/stats/`, and this screen only draws what they return.
class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final matches = ref.watch(analyticsMatchesProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.navAnalytics)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32).clearingFloatingBar,
        children: [
          const _Filters(),
          const SizedBox(height: 24),
          switch (matches) {
            AsyncData(:final value) when value.isEmpty => const _Empty(),
            AsyncData() => const _Report(),
            AsyncError() => Text(l10n.errorGeneric),
            _ => const SizedBox(height: 200),
          },
          const _ClearHistory(),
        ],
      ),
    );
  }
}

/// Nothing to show, with the reason it is empty.
///
/// A filtered-out list and a database with no matches look identical on
/// screen, so they say different things: one is an instruction, the other is a
/// hint to widen the filters. Which of the two it is comes from asking whether
/// any round exists at all, not from inspecting the filters — the period is
/// always set to something, so by that measure the section would be "filtered"
/// on the day it is installed.
class _Empty extends ConsumerWidget {
  const _Empty();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final narrowed =
        ref.watch(analyticsHasAnyMatchProvider).valueOrNull ?? false;

    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: EmptyState(
        icon: Icons.insights_outlined,
        title: narrowed
            ? l10n.analyticsNoMatchesForFilters
            : l10n.analyticsEmpty,
        message: narrowed ? null : l10n.analyticsEmptyHint,
      ),
    );
  }
}

class _Report extends ConsumerWidget {
  const _Report();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final record = ref.watch(analyticsRecordProvider);
    final games = ref.watch(analyticsGameRecordProvider);
    final decks = ref.watch(analyticsDeckRecordsProvider);
    final matchup = ref.watch(analyticsMatchupProvider);
    final playDraw = ref.watch(analyticsPlayDrawProvider);
    final trend = ref.watch(analyticsTrendProvider);
    final meta = ref.watch(analyticsMetaProvider);

    final quiet = theme.textTheme.bodySmall?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(l10n.analyticsOverview),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: l10n.analyticsMatchWinrate,
                value: winratePercent(record.winrate),
                caption: l10n.recordSample(record.decidedMatches),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                label: l10n.analyticsGameWinrate,
                value: winratePercent(games.winrate),
                caption: '${games.won}-${games.lost}',
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Card(
          child: WinrateRow(title: l10n.statRecord, record: record),
        ),
        const SizedBox(height: 8),
        Text(l10n.analyticsCompetitiveOnly, style: quiet),

        if (decks.length > 1) ...[
          const SizedBox(height: 28),
          SectionLabel(l10n.analyticsByDeck),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                for (final (index, deck) in decks.indexed) ...[
                  if (index > 0) const Divider(height: 1),
                  WinrateRow(
                    title: deck.name,
                    subtitle: deck.archetype,
                    record: deck.record,
                  ),
                ],
              ],
            ),
          ),
        ],

        const SizedBox(height: 28),
        SectionLabel(l10n.analyticsMatchup),
        const SizedBox(height: 12),
        if (matchup.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Text(l10n.analyticsMatchupEmpty, style: quiet),
            ),
          )
        else ...[
          MatchupGrid(matrix: matchup),
          const SizedBox(height: 8),
          Text(l10n.analyticsMatchupHint(Analytics.smallSample), style: quiet),
        ],

        const SizedBox(height: 28),
        SectionLabel(l10n.analyticsPlayDraw),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: StatTile(
                label: l10n.analyticsOnThePlay,
                value: winratePercent(playDraw.onThePlay.winrate),
                caption: l10n.recordSample(playDraw.onThePlay.decidedMatches),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: StatTile(
                label: l10n.analyticsOnTheDraw,
                value: winratePercent(playDraw.onTheDraw.winrate),
                caption: l10n.recordSample(playDraw.onTheDraw.decidedMatches),
              ),
            ),
          ],
        ),
        if (playDraw.advantage case final advantage?) ...[
          const SizedBox(height: 8),
          Text(
            l10n.analyticsPlayAdvantage(percentagePoints(advantage)),
            style: quiet,
          ),
        ],
        if (playDraw.unrecorded.decidedMatches > 0) ...[
          const SizedBox(height: 4),
          Text(
            l10n.analyticsPlayDrawUnrecorded(
              playDraw.unrecorded.decidedMatches,
            ),
            style: quiet,
          ),
        ],

        if (trend.length > 1) ...[
          const SizedBox(height: 28),
          SectionLabel(l10n.analyticsTrend),
          const SizedBox(height: 12),
          TrendChart(points: trend),
          const SizedBox(height: 8),
          Text(l10n.analyticsTrendHint, style: quiet),
        ],

        if (meta.isNotEmpty) ...[
          const SizedBox(height: 28),
          SectionLabel(l10n.analyticsMeta),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                for (final (index, share) in meta.indexed) ...[
                  if (index > 0) const Divider(height: 1),
                  _MetaRow(share: share),
                ],
              ],
            ),
          ),
          const SizedBox(height: 8),
          Text(l10n.analyticsMetaHint, style: quiet),
        ],
      ],
    );
  }
}

/// One opponent archetype: how often it turned up, and how it went.
class _MetaRow extends ConsumerWidget {
  const _MetaRow({required this.share});

  final ArchetypeShare share;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final records = ref.watch(analyticsMatchupProvider);
    final against = [
      for (final mine in records.mine) ?records.cell(mine, share.archetype),
    ];
    final combined = against.isEmpty ? null : against.reduce((a, b) => a + b);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  share.archetype,
                  style: theme.textTheme.titleSmall,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  l10n.analyticsFaced(share.faced),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 60,
            child: Text(
              '${(share.share * 100).round()}%',
              textAlign: TextAlign.end,
              style: theme.textTheme.titleMedium,
            ),
          ),
          const SizedBox(width: 12),
          SizedBox(
            width: 54,
            child: Text(
              combined == null ? '—' : winratePercent(combined.winrate) ?? '—',
              textAlign: TextAlign.end,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Throws away the recorded results the section is computing from.
///
/// Scoped to the game and format on screen, and absent while there is nothing
/// to clear: an enabled button that would delete nothing invites the tap that
/// finds out what it does.
///
/// The confirmation counts the whole history of that format, not the rows the
/// filters are showing. The period alone hides most of it most of the time, and
/// a warning that understates the damage is worse than none.
class _ClearHistory extends ConsumerWidget {
  const _ClearHistory();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final formatId = ref.watch(analyticsFormatProvider);
    final size = ref.watch(analyticsHistorySizeProvider).valueOrNull;

    if (formatId == null || size == null || size.tournaments == 0) {
      return const SizedBox.shrink();
    }

    final formats =
        ref
            .watch(allFormatsProvider(ref.watch(analyticsGameProvider) ?? ''))
            .valueOrNull ??
        const <Format>[];
    final format = formats.where((f) => f.id == formatId).firstOrNull;
    final formatLabel = format == null
        ? formatId
        : l10n.formatName(format.id, format.name);

    return Padding(
      padding: const EdgeInsets.only(top: 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          OutlinedButton.icon(
            onPressed: () => _confirm(context, ref, size, formatLabel),
            icon: const Icon(Icons.delete_outline),
            label: Text(l10n.analyticsReset),
            style: OutlinedButton.styleFrom(
              foregroundColor: theme.colorScheme.error,
              side: BorderSide(color: theme.colorScheme.error),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.analyticsResetHint,
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _confirm(
    BuildContext context,
    WidgetRef ref,
    HistorySize size,
    String formatLabel,
  ) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final gameId = ref.read(analyticsGameProvider);
    final formatId = ref.read(analyticsFormatProvider);
    if (gameId == null || formatId == null) return;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.analyticsReset),
        content: Text(
          l10n.analyticsResetConfirm(
            size.tournaments,
            size.matches,
            formatLabel,
          ),
        ),
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

    if (!(confirmed ?? false)) return;

    await ref
        .read(analyticsRepositoryProvider)
        .clearHistory(gameId: gameId, formatId: formatId);

    messenger.showSnackBar(
      SnackBar(content: Text(l10n.analyticsResetDone(formatLabel))),
    );
  }
}

/// Game, format, deck and period, all optional and all remembered.
class _Filters extends ConsumerWidget {
  const _Filters();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selection = ref.watch(analyticsSelectionProvider);
    final notifier = ref.read(analyticsSelectionProvider.notifier);
    final games = ref.watch(gamesProvider).valueOrNull ?? const <Game>[];

    // What the section reports on, which is not always what was last picked:
    // see `analyticsGameProvider`. The chips have to show the former, or the
    // numbers below would be answering a question nothing on screen asked.
    final gameId = ref.watch(analyticsGameProvider);
    final formatId = ref.watch(analyticsFormatProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final game in games)
                  ChoiceChip(
                    label: Text(l10n.gameName(game.id, game.name)),
                    selected: gameId == game.id,
                    onSelected: (_) => notifier.selectGame(game.id),
                  ),
              ],
            ),
            if (gameId != null) ...[
              const SizedBox(height: 10),
              _FormatChips(gameId: gameId, selected: formatId),
            ],
            const SizedBox(height: 10),
            const _DeckPicker(),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final period in AnalyticsPeriod.values)
                  ChoiceChip(
                    label: Text(_periodName(l10n, period)),
                    selected: selection.period == period,
                    onSelected: (_) => notifier.selectPeriod(period),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _periodName(AppLocalizations l10n, AnalyticsPeriod period) {
    return switch (period) {
      AnalyticsPeriod.last30 => l10n.analyticsPeriod30,
      AnalyticsPeriod.last90 => l10n.analyticsPeriod90,
      AnalyticsPeriod.lastYear => l10n.analyticsPeriodYear,
      AnalyticsPeriod.all => l10n.analyticsPeriodAll,
    };
  }
}

class _FormatChips extends ConsumerWidget {
  const _FormatChips({required this.gameId, required this.selected});

  final String gameId;
  final String? selected;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final notifier = ref.read(analyticsSelectionProvider.notifier);
    final formats =
        ref.watch(formatsProvider(gameId)).valueOrNull ?? const <Format>[];

    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final format in formats)
          ChoiceChip(
            label: Text(l10n.formatName(format.id, format.name)),
            selected: selected == format.id,
            onSelected: (_) => notifier.selectFormat(format.id),
          ),
      ],
    );
  }
}

class _DeckPicker extends ConsumerWidget {
  const _DeckPicker();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final selection = ref.watch(analyticsSelectionProvider);
    final decks =
        ref.watch(analyticsDeckChoicesProvider).valueOrNull ?? const <Deck>[];

    // A deck chosen before the game or format filter moved may no longer be on
    // the list; showing it selected would be a lie, so the field falls back to
    // "every deck" until the user picks again.
    final value = decks.any((deck) => deck.id == selection.deckId)
        ? selection.deckId
        : null;

    return DropdownButtonFormField<String?>(
      initialValue: value,
      isExpanded: true,
      decoration: const InputDecoration(isDense: true),
      onChanged: (id) =>
          ref.read(analyticsSelectionProvider.notifier).selectDeck(id),
      items: [
        DropdownMenuItem(value: null, child: Text(l10n.analyticsAllDecks)),
        for (final deck in decks)
          DropdownMenuItem(
            value: deck.id,
            child: DeckLabel(deck: deck),
          ),
      ],
    );
  }
}
