import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/catalog_names.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/archetype_repository.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/layout/bar_insets.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/glass_app_bar.dart';
import '../providers/deck_filter_provider.dart';

/// Manages the controlled list of opponent archetypes, one list per format.
class ArchetypesScreen extends ConsumerStatefulWidget {
  const ArchetypesScreen({super.key});

  @override
  ConsumerState<ArchetypesScreen> createState() => _ArchetypesScreenState();
}

class _ArchetypesScreenState extends ConsumerState<ArchetypesScreen> {
  String? _formatId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final gameId = ref.watch(deckGameProvider);
    final formats =
        ref.watch(formatsProvider(gameId)).valueOrNull ?? const <Format>[];

    if (_formatId == null && formats.isNotEmpty) _formatId = formats.first.id;
    final formatId = _formatId;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(title: Text(l10n.archetypesTitle)),
      floatingActionButton: formatId == null
          ? null
          : LiftedFab(
              child: FloatingActionButton.extended(
                onPressed: () => _addArchetype(gameId, formatId),
                icon: const Icon(Icons.add),
                label: Text(l10n.actionAdd),
              ),
            ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // The hint and the format chips are fixed rather than scrolling, so
          // they are pushed clear of the bar; only the list below them moves.
          const SizedBox(height: TopBar.inset),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: Text(
              l10n.archetypesHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              children: [
                for (final format in formats)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(l10n.formatName(format.id, format.name)),
                      selected: formatId == format.id,
                      onSelected: (_) => setState(() => _formatId = format.id),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: formatId == null
                ? const SizedBox.shrink()
                : _ArchetypeList(gameId: gameId, formatId: formatId),
          ),
        ],
      ),
    );
  }

  Future<void> _addArchetype(String gameId, String formatId) async {
    final l10n = AppLocalizations.of(context);
    final name = await _promptForName(context, title: l10n.archetypeNew);
    if (name == null || !mounted) return;

    await ref
        .read(archetypeRepositoryProvider)
        .findOrCreate(gameId: gameId, formatId: formatId, name: name);
  }
}

class _ArchetypeList extends ConsumerWidget {
  const _ArchetypeList({required this.gameId, required this.formatId});

  final String gameId;
  final String formatId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repository = ref.read(archetypeRepositoryProvider);
    final archetypes = ref.watch(
      archetypesProvider((gameId: gameId, formatId: formatId)),
    );

    return switch (archetypes) {
      AsyncData(:final value) when value.isEmpty => EmptyState(
        icon: Icons.groups_outlined,
        title: l10n.archetypesEmpty,
      ),
      AsyncData(:final value) => ListView.separated(
        padding: const EdgeInsets.only(bottom: 96).clearingFloatingBar,
        itemCount: value.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final archetype = value[index];

          return ListTile(
            title: Text(archetype.name),
            subtitle: Text(
              l10n.archetypeTimesFaced(archetype.timesFaced),
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: PopupMenuButton<_ArchetypeAction>(
              onSelected: (action) async {
                switch (action) {
                  case _ArchetypeAction.rename:
                    final name = await _promptForName(
                      context,
                      title: l10n.actionRename,
                      initialValue: archetype.name,
                    );
                    if (name != null) {
                      await repository.rename(archetype.id, name);
                    }
                  case _ArchetypeAction.delete:
                    final result = await repository.delete(archetype.id);
                    if (result == ArchetypeDeletionResult.inUse) {
                      messenger.showSnackBar(
                        SnackBar(content: Text(l10n.archetypeDeleteInUse)),
                      );
                    }
                }
              },
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _ArchetypeAction.rename,
                  child: Text(l10n.actionRename),
                ),
                PopupMenuItem(
                  value: _ArchetypeAction.delete,
                  child: Text(l10n.actionDelete),
                ),
              ],
            ),
          );
        },
      ),
      AsyncError() => Center(child: Text(l10n.errorGeneric)),
      _ => const SizedBox.shrink(),
    };
  }
}

enum _ArchetypeAction { rename, delete }

/// Single-field dialog shared by "add" and "rename".
Future<String?> _promptForName(
  BuildContext context, {
  required String title,
  String initialValue = '',
}) {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: initialValue);

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
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
          onPressed: () {
            final value = controller.text.trim();
            Navigator.of(context).pop(value.isEmpty ? null : value);
          },
          child: Text(l10n.actionSave),
        ),
      ],
    ),
  );
}
