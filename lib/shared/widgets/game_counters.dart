import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import 'number_stepper.dart';

/// Games won, lost and drawn, one row each.
///
/// The match result is never typed in: it follows from these three numbers, so
/// a "win" with more games lost than won cannot be recorded. Shared by the
/// tournament round editor and the casual match editor, because a match is a
/// match and the two must never drift apart.
class GameCounters extends StatelessWidget {
  const GameCounters({
    required this.won,
    required this.lost,
    required this.drawn,
    required this.onChanged,
    this.showDrawn = true,
    super.key,
  });

  final int won;
  final int lost;
  final int drawn;
  final void Function(int won, int lost, int drawn) onChanged;

  /// Whether the drawn-games row is offered.
  ///
  /// Off for a game whose matches cannot end level. [drawn] is still reported
  /// back unchanged rather than forced to zero: a match recorded before the
  /// rule existed keeps its count, and hiding a field is not a reason to
  /// rewrite what it held.
  final bool showDrawn;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        _CounterRow(
          label: l10n.matchGamesWon,
          value: won,
          onChanged: (value) => onChanged(value, lost, drawn),
        ),
        const SizedBox(height: 8),
        _CounterRow(
          label: l10n.matchGamesLost,
          value: lost,
          onChanged: (value) => onChanged(won, value, drawn),
        ),
        if (showDrawn) ...[
          const SizedBox(height: 8),
          _CounterRow(
            label: l10n.matchGamesDrawn,
            value: drawn,
            onChanged: (value) => onChanged(won, lost, value),
          ),
        ],
      ],
    );
  }
}

class _CounterRow extends StatelessWidget {
  const _CounterRow({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  final String label;
  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyLarge),
        ),
        NumberStepper(value: value, max: 9, onChanged: onChanged),
      ],
    );
  }
}
