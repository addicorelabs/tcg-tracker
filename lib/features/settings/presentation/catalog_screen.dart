import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/theme.dart';
import '../../../core/utils/catalog_names.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/layout/floating_bar_inset.dart';

/// Adds, renames, hides and deletes games and the formats under them.
///
/// Hiding is the ordinary operation and deleting is the exception, which is
/// why every row offers the first and only some can do the second. A game or a
/// format that has been played in is history: taking it out of the menus is a
/// change of plans, removing it from the database would be a rewrite.
class CatalogScreen extends ConsumerWidget {
  const CatalogScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    // Hidden games included: this is the one screen that has to show them,
    // since it is the only place they can be brought back from.
    final games = ref.watch(allGamesProvider).valueOrNull ?? const <Game>[];

    return Scaffold(
      appBar: AppBar(title: Text(l10n.catalogTitle)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 32).clearingFloatingBar,
        children: [
          Text(
            l10n.catalogHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          for (final game in games) ...[
            _GameCard(game: game, siblings: games),
            const SizedBox(height: 16),
          ],
          OutlinedButton.icon(
            onPressed: () => _addGame(context, ref, games),
            icon: const Icon(Icons.add),
            label: Text(l10n.gameNew),
          ),
        ],
      ),
    );
  }

  Future<void> _addGame(
    BuildContext context,
    WidgetRef ref,
    List<Game> siblings,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = await promptForName(
      context,
      title: l10n.gameNew,
      label: l10n.gameNameLabel,
    );
    if (name == null || !context.mounted) return;

    if (nameIsTaken(siblings.map((g) => g.name), name)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.gameNameTaken)));
      return;
    }

    await ref.read(catalogRepositoryProvider).addGame(name: name);
  }
}

/// One game and the formats under it.
class _GameCard extends ConsumerWidget {
  const _GameCard({required this.game, required this.siblings});

  final Game game;
  final List<Game> siblings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final formats =
        ref.watch(allFormatsProvider(game.id)).valueOrNull ?? const <Format>[];
    final usage = ref.watch(gameUsageProvider(game.id)).valueOrNull;

    final muted = theme.colorScheme.onSurfaceVariant;
    final accent = theme.gameAccent(game.id);

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: game.isActive ? accent : muted,
                shape: BoxShape.circle,
              ),
            ),
            title: Row(
              children: [
                Flexible(
                  child: Text(
                    l10n.gameName(game.id, game.name),
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: game.isActive ? null : muted,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                if (!game.isActive) _Tag(l10n.catalogHidden, tone: muted),
                if (game.isSystem)
                  _Tag(l10n.catalogSystem, tone: theme.colorScheme.primary),
              ],
            ),
            subtitle: Text(
              _usageLabel(l10n, usage),
              style: theme.textTheme.bodySmall?.copyWith(color: muted),
            ),
            trailing: PopupMenuButton<_Action>(
              onSelected: (action) => _run(context, ref, action),
              itemBuilder: (context) => [
                PopupMenuItem(
                  value: _Action.rename,
                  child: Text(l10n.actionRename),
                ),
                PopupMenuItem(
                  value: _Action.toggle,
                  child: Text(
                    game.isActive ? l10n.catalogHide : l10n.catalogShow,
                  ),
                ),
                PopupMenuItem(
                  value: _Action.delete,
                  child: Text(l10n.actionDelete),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          for (final format in formats)
            _FormatRow(format: format, siblings: formats),
          if (formats.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Text(
                l10n.catalogNoFormats,
                style: theme.textTheme.bodySmall?.copyWith(color: muted),
              ),
            ),
          ListTile(
            leading: const Icon(Icons.add, size: 20),
            title: Text(l10n.formatNew, style: theme.textTheme.bodyMedium),
            dense: true,
            onTap: () => _addFormat(context, ref, formats),
          ),
        ],
      ),
    );
  }

  Future<void> _addFormat(
    BuildContext context,
    WidgetRef ref,
    List<Format> formats,
  ) async {
    final l10n = AppLocalizations.of(context);
    final name = await promptForName(
      context,
      title: l10n.formatNew,
      label: l10n.formatNameLabel,
    );
    if (name == null || !context.mounted) return;

    if (nameIsTaken(formats.map((f) => f.name), name)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(l10n.formatNameTaken)));
      return;
    }

    await ref
        .read(catalogRepositoryProvider)
        .addFormat(gameId: game.id, name: name);
  }

  Future<void> _run(BuildContext context, WidgetRef ref, _Action action) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repository = ref.read(catalogRepositoryProvider);

    switch (action) {
      case _Action.rename:
        final name = await promptForName(
          context,
          title: l10n.actionRename,
          label: l10n.gameNameLabel,
          initialValue: game.name,
        );
        if (name == null) return;

        if (nameIsTaken(siblings.map((g) => g.name), name, except: game.name)) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.gameNameTaken)));
          return;
        }
        await repository.renameGame(game.id, name);

      case _Action.toggle:
        final result = await repository.setGameActive(
          game.id,
          isActive: !game.isActive,
        );
        if (result == CatalogDeletionResult.lastOne) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.gameLastOne)));
        }

      case _Action.delete:
        if (!context.mounted) return;
        final confirmed = await _confirmDelete(
          context,
          l10n.gameDeleteConfirm(game.name),
        );
        if (confirmed != true) return;

        _report(messenger, l10n, await repository.deleteGame(game.id));
    }
  }
}

class _FormatRow extends ConsumerWidget {
  const _FormatRow({required this.format, required this.siblings});

  final Format format;

  /// The other formats of the same game, used to refuse a duplicate name.
  final List<Format> siblings;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final usage = ref.watch(formatUsageProvider(format.id)).valueOrNull;

    final muted = theme.colorScheme.onSurfaceVariant;

    return ListTile(
      dense: true,
      contentPadding: const EdgeInsets.only(left: 28, right: 4),
      title: Row(
        children: [
          Flexible(
            child: Text(
              l10n.formatName(format.id, format.name),
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: format.isActive ? null : muted,
              ),
            ),
          ),
          const SizedBox(width: 8),
          if (!format.isActive) _Tag(l10n.catalogHidden, tone: muted),
          if (format.isSystem)
            _Tag(l10n.catalogSystem, tone: theme.colorScheme.primary),
        ],
      ),
      subtitle: Text(
        _usageLabel(l10n, usage),
        style: theme.textTheme.bodySmall?.copyWith(color: muted),
      ),
      trailing: PopupMenuButton<_Action>(
        onSelected: (action) => _run(context, ref, action),
        itemBuilder: (context) => [
          PopupMenuItem(value: _Action.rename, child: Text(l10n.actionRename)),
          PopupMenuItem(
            value: _Action.toggle,
            child: Text(format.isActive ? l10n.catalogHide : l10n.catalogShow),
          ),
          // Offered on every row rather than only where it can succeed: a menu
          // whose entries come and go teaches nothing, while a refusal that
          // names the reason does.
          PopupMenuItem(value: _Action.delete, child: Text(l10n.actionDelete)),
        ],
      ),
    );
  }

  Future<void> _run(BuildContext context, WidgetRef ref, _Action action) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final repository = ref.read(catalogRepositoryProvider);

    switch (action) {
      case _Action.rename:
        final name = await promptForName(
          context,
          title: l10n.actionRename,
          label: l10n.formatNameLabel,
          initialValue: format.name,
        );
        if (name == null) return;

        if (nameIsTaken(
          siblings.map((f) => f.name),
          name,
          except: format.name,
        )) {
          messenger.showSnackBar(SnackBar(content: Text(l10n.formatNameTaken)));
          return;
        }
        await repository.renameFormat(format.id, name);

      case _Action.toggle:
        await repository.setFormatActive(format.id, isActive: !format.isActive);

      case _Action.delete:
        if (!context.mounted) return;
        final confirmed = await _confirmDelete(
          context,
          l10n.formatDeleteConfirm(format.name),
        );
        if (confirmed != true) return;

        _report(messenger, l10n, await repository.deleteFormat(format.id));
    }
  }
}

enum _Action { rename, toggle, delete }

String _usageLabel(AppLocalizations l10n, CatalogUsage? usage) {
  return switch (usage) {
    null => '',
    (decks: 0, tournaments: 0, matches: _) => l10n.catalogUnused,
    final u => l10n.catalogUsage(u.decks, u.tournaments),
  };
}

Future<bool?> _confirmDelete(BuildContext context, String question) {
  final l10n = AppLocalizations.of(context);

  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(l10n.actionDelete),
      content: Text(question),
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
}

/// Says why a deletion did not happen, and stays quiet when it did.
void _report(
  ScaffoldMessengerState messenger,
  AppLocalizations l10n,
  CatalogDeletionResult result,
) {
  final message = switch (result) {
    CatalogDeletionResult.deleted => null,
    CatalogDeletionResult.system => l10n.catalogDeleteSystem,
    CatalogDeletionResult.inUse => l10n.catalogDeleteInUse,
    CatalogDeletionResult.lastOne => l10n.gameLastOne,
  };

  if (message != null) {
    messenger.showSnackBar(SnackBar(content: Text(message)));
  }
}

/// Whether [name] already belongs to one of [existing], ignoring case and
/// surrounding spaces, and ignoring the name being renamed.
bool nameIsTaken(Iterable<String> existing, String name, {String? except}) {
  final normalised = name.trim().toLowerCase();

  return existing.any(
    (other) => other != except && other.trim().toLowerCase() == normalised,
  );
}

class _Tag extends StatelessWidget {
  const _Tag(this.label, {required this.tone});

  final String label;
  final Color tone;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: tone.withValues(alpha: 0.14),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(color: tone),
      ),
    );
  }
}

/// Single-field dialog shared by every "new" and "rename" on this screen.
///
/// Returns null when the user cancels or leaves the field empty, so a blank
/// name can never reach the database.
Future<String?> promptForName(
  BuildContext context, {
  required String title,
  required String label,
  String initialValue = '',
}) {
  final l10n = AppLocalizations.of(context);
  final controller = TextEditingController(text: initialValue);

  String? clean(String value) => value.trim().isEmpty ? null : value.trim();

  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: InputDecoration(labelText: label),
        onSubmitted: (value) => Navigator.of(context).pop(clean(value)),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text(l10n.actionCancel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(clean(controller.text)),
          child: Text(l10n.actionSave),
        ),
      ],
    ),
  );
}
