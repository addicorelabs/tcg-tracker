import 'package:flutter/material.dart';

import '../../../../app/theme.dart';
import '../../../../core/stats/analytics.dart';
import '../../../../core/stats/match_stats.dart';
import '../../../../core/utils/formatting.dart';
import '../../../../l10n/app_localizations.dart';

/// One line of "this thing, this winrate, over this many matches".
///
/// The sample is never optional. A winrate without the number behind it is the
/// single easiest way to read too much into three games, and every screen in
/// this section shows both or neither.
class WinrateRow extends StatelessWidget {
  const WinrateRow({
    required this.title,
    required this.record,
    this.subtitle,
    super.key,
  });

  final String title;
  final String? subtitle;
  final MatchRecord record;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final winrate = record.winrate;
    final thin = Analytics.isThin(record);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              Tooltip(
                message: thin ? l10n.analyticsThinSample : '',
                child: Text(
                  winratePercent(winrate) ?? '—',
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: thin
                        ? theme.colorScheme.onSurfaceVariant
                        : theme.colorScheme.onSurface,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          WinrateBar(record: record),
          const SizedBox(height: 6),
          Text(
            '${record.shortForm} · ${l10n.recordSample(record.decidedMatches)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// Wins, draws and losses as one bar, in that order.
///
/// Proportional rather than a single winrate fill: a 50% winrate made of
/// draws and one made of wins and losses are different seasons, and the bar is
/// where that difference is visible for free.
class WinrateBar extends StatelessWidget {
  const WinrateBar({required this.record, this.height = 8, super.key});

  final MatchRecord record;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).appColors;
    final total = record.decidedMatches;

    if (total == 0) {
      return Container(
        height: height,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(height),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: SizedBox(
        height: height,
        child: Row(
          children: [
            if (record.wins > 0)
              Expanded(
                flex: record.wins,
                child: ColoredBox(color: colors.win),
              ),
            if (record.draws > 0)
              Expanded(
                flex: record.draws,
                child: ColoredBox(color: colors.draw),
              ),
            if (record.losses > 0)
              Expanded(
                flex: record.losses,
                child: ColoredBox(color: colors.loss),
              ),
          ],
        ),
      ),
    );
  }
}
