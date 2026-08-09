import 'package:flutter/material.dart';

/// One number with its caption, sized to be read at a glance.
///
/// [value] is null while there is nothing to show yet, which renders a dash
/// instead of a zero: no data and a genuine zero mean different things.
class StatTile extends StatelessWidget {
  const StatTile({
    required this.label,
    required this.value,
    this.caption,
    this.accent,
    super.key,
  });

  final String label;
  final String? value;
  final String? caption;
  final Color? accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final hasValue = value != null;
    final valueColor = hasValue
        ? (accent ?? theme.colorScheme.onSurface)
        : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5);

    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(label.toUpperCase(), style: theme.textTheme.labelSmall),
            const SizedBox(height: 8),
            Text(
              value ?? '—',
              style: theme.textTheme.headlineMedium?.copyWith(
                color: valueColor,
              ),
            ),
            if (caption != null) ...[
              const SizedBox(height: 2),
              Text(
                caption!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
