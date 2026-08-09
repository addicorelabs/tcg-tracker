import 'package:flutter/material.dart';

import '../../app/theme.dart';
import '../../core/utils/catalog_names.dart';
import '../../data/models/enums.dart';
import '../../l10n/app_localizations.dart';

/// Coloured badge for the outcome of a match.
///
/// A bye is deliberately grey rather than green: it is not a win, and nothing
/// in the interface should suggest otherwise.
class ResultChip extends StatelessWidget {
  const ResultChip(this.result, {this.compact = false, super.key});

  final MatchResult result;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    final color = switch (result) {
      MatchResult.win => theme.appColors.win,
      MatchResult.loss => theme.appColors.loss,
      MatchResult.draw || MatchResult.bye => theme.appColors.draw,
    };

    final label = l10n.matchResultName(result);

    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 10,
        vertical: compact ? 3 : 5,
      ),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        compact ? label.substring(0, 1).toUpperCase() : label.toUpperCase(),
        style: theme.textTheme.labelSmall?.copyWith(color: color),
      ),
    );
  }
}
