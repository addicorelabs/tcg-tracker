import 'package:flutter/material.dart';

import '../../data/db/app_database.dart';

/// A deck's name with its archetype trailing it, quieter and smaller.
///
/// Two builds of the same deck are often called the same thing, and a menu of
/// names alone gives no way to tell them apart.
///
/// The archetype is left out when it repeats the name, which is the common case
/// and reads as a stutter. Both halves shrink and ellipsize, so a long name
/// cannot push the archetype off the row and a long archetype cannot bury the
/// name.
class DeckLabel extends StatelessWidget {
  const DeckLabel({required this.deck, super.key});

  final Deck deck;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final archetype = deck.archetype.trim();
    final repeats = archetype.toLowerCase() == deck.name.trim().toLowerCase();

    return Row(
      children: [
        Flexible(child: Text(deck.name, overflow: TextOverflow.ellipsis)),
        if (archetype.isNotEmpty && !repeats) ...[
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              archetype,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ],
    );
  }
}
