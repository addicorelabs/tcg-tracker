import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/repositories/archetype_repository.dart';
import '../../l10n/app_localizations.dart';

/// The opponent's deck, picked from a controlled list.
///
/// A menu rather than free text: the matchup matrix is only readable if the
/// same deck is always named the same way, and a text field guarantees it will
/// not be. Typing filters the list.
///
/// Beside the menu sits a button for an archetype nobody has recorded yet,
/// which is saved straight away so it is there the next time. It is a button
/// and not the menu's last entry, which is where it used to be: once the app
/// started shipping sixty archetypes per format, that entry was both a long
/// scroll away and — worse — hidden by the filter as soon as the user typed a
/// name that was not on the list, which is exactly when they need it.
class ArchetypePicker extends ConsumerWidget {
  const ArchetypePicker({
    required this.value,
    required this.onChanged,
    required this.gameId,
    required this.formatId,
    this.errorText,
    this.helperText,
    super.key,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String gameId;
  final String formatId;
  final String? errorText;

  /// Overrides the default explanation, for callers picking their own deck's
  /// archetype rather than the opponent's.
  final String? helperText;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final scope = (gameId: gameId, formatId: formatId);
    final choices = ref.watch(opponentArchetypeChoicesProvider(scope));

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: DropdownMenu<String>(
            // Keyed on the value so the menu's own text field follows a
            // selection made from the dialog, which it has no other way of
            // hearing about.
            //
            // The number of choices is part of the key because
            // `initialSelection` is only honoured against the entries that
            // exist when the menu is built. The list arrives from the database
            // a frame later, so without this a pre-filled archetype — opening
            // the editor from inside one — would show an empty field.
            key: ValueKey('$formatId/$value/${choices.length}'),
            initialSelection: value,
            enableFilter: true,
            requestFocusOnTap: true,
            expandedInsets: EdgeInsets.zero,
            menuHeight: 320,
            hintText: l10n.archetypeSearch,
            errorText: errorText,
            helperText: helperText ?? l10n.archetypesHint,
            dropdownMenuEntries: [
              for (final name in choices)
                DropdownMenuEntry(value: name, label: name),
            ],
            onSelected: onChanged,
          ),
        ),
        const SizedBox(width: 8),
        Padding(
          // Lines the button up with the field, which sits below its own label.
          padding: const EdgeInsets.only(top: 4),
          child: IconButton.filledTonal(
            onPressed: () async {
              final created = await _askNewArchetype(context, ref);
              onChanged(created ?? value);
            },
            icon: const Icon(Icons.add),
            tooltip: l10n.archetypeNew,
          ),
        ),
      ],
    );
  }

  /// Asks for a name and records it, so the new archetype is available
  /// everywhere and not only for this match.
  Future<String?> _askNewArchetype(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final controller = TextEditingController();

    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.archetypeNew),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: InputDecoration(labelText: l10n.archetypeName),
          onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(controller.text.trim()),
            child: Text(l10n.actionSave),
          ),
        ],
      ),
    );

    if (name == null || name.isEmpty) return null;

    final archetype = await ref
        .read(archetypeRepositoryProvider)
        .findOrCreate(gameId: gameId, formatId: formatId, name: name);

    return archetype.name;
  }
}
