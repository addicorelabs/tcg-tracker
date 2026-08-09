import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/stats/analytics.dart';
import '../../../../core/stats/match_stats.dart';
import '../../../../core/utils/formatting.dart';
import '../../../../l10n/app_localizations.dart';

/// My archetypes against theirs, as a grid.
///
/// The left column is pinned and the rest scrolls sideways: on a phone the
/// grid is always wider than the screen, and a matchup row is unreadable once
/// you cannot see whose deck it belongs to.
class MatchupGrid extends StatelessWidget {
  const MatchupGrid({required this.matrix, super.key});

  final MatchupMatrix matrix;

  // Two lines of text in a cell, at the label weights this theme uses, need
  // more room than they look like they do.
  static const _rowHeight = 64.0;
  static const _headerHeight = 58.0;
  static const _nameWidth = 108.0;
  static const _cellWidth = 62.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: _headerHeight),
                for (final mine in matrix.mine)
                  SizedBox(
                    height: _rowHeight,
                    width: _nameWidth,
                    child: Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        mine,
                        style: theme.textTheme.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ),
              ],
            ),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        for (final theirs in matrix.theirs)
                          SizedBox(
                            height: _headerHeight,
                            width: _cellWidth,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 2,
                              ),
                              child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Text(
                                  theirs,
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.labelSmall,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                    for (final mine in matrix.mine)
                      Row(
                        children: [
                          for (final theirs in matrix.theirs)
                            _Cell(
                              record: matrix.cell(mine, theirs),
                              width: _cellWidth,
                              height: _rowHeight,
                            ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Cell extends StatelessWidget {
  const _Cell({
    required this.record,
    required this.width,
    required this.height,
  });

  final MatchRecord? record;
  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final record = this.record;

    if (record == null || record.decidedMatches == 0) {
      return SizedBox(
        width: width,
        height: height,
        child: Center(
          child: Text(
            '—',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4),
            ),
          ),
        ),
      );
    }

    final thin = Analytics.isThin(record);
    final winrate = record.winrate ?? 0;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Tooltip(
        message: thin ? l10n.analyticsThinSample : record.shortForm,
        child: Container(
          width: width - 4,
          height: height - 4,
          decoration: BoxDecoration(
            color: _shade(
              context,
              winrate,
            ).withValues(alpha: thin ? 0.16 : 0.4),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                winratePercent(winrate)!,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: thin
                      ? theme.colorScheme.onSurfaceVariant
                      : theme.colorScheme.onSurface,
                ),
              ),
              Text(
                '${record.decidedMatches}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Red at zero, grey at even, green at one.
  ///
  /// Two ramps meeting at 50% rather than one from red to green: the middle of
  /// a single ramp is a muddy colour that reads as "bad" long before the
  /// winrate actually is.
  Color _shade(BuildContext context, double winrate) {
    final colors = Theme.of(context).appColors;

    if (winrate < 0.5) {
      return Color.lerp(colors.loss, colors.draw, winrate * 2)!;
    }
    return Color.lerp(colors.draw, colors.win, (winrate - 0.5) * 2)!;
  }
}
