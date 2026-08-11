import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../app/routes.dart';
import '../../../app/theme.dart';
import '../../../core/platform/browser_files.dart';
import '../../../core/utils/catalog_names.dart';
import '../../../data/backup/backup_service.dart';
import '../../../data/db/app_database.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/sync/sync_controller.dart';
import '../../../data/sync/sync_status.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/layout/bar_insets.dart';
import '../../../shared/widgets/glass_app_bar.dart';
import '../../../shared/widgets/section_label.dart';
import '../providers/app_settings_provider.dart';

/// Language, theme, account and sync, backup file, and the format catalogue.
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final settings = ref.watch(appSettingsProvider);
    final notifier = ref.read(appSettingsProvider.notifier);

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: GlassAppBar(title: Text(l10n.navSettings)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(
          16,
          8,
          16,
          32,
        ).clearingFloatingBar.clearingAppBar,
        children: [
          SectionLabel(l10n.navSettings),
          const SizedBox(height: 12),
          Card(
            child: Column(
              children: [
                _SettingRow(
                  icon: Icons.translate,
                  title: l10n.settingsLanguage,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String?>(
                      value: settings.locale?.languageCode,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(12),
                      onChanged: (code) => notifier.setLocale(
                        code == null ? null : Locale(code),
                      ),
                      items: [
                        DropdownMenuItem(
                          value: null,
                          child: Text(l10n.settingsLanguageSystem),
                        ),
                        const DropdownMenuItem(
                          value: 'it',
                          child: Text('Italiano'),
                        ),
                        const DropdownMenuItem(
                          value: 'en',
                          child: Text('English'),
                        ),
                      ],
                    ),
                  ),
                ),
                const Divider(),
                _SettingRow(
                  icon: Icons.brightness_6_outlined,
                  title: l10n.settingsTheme,
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<ThemeMode>(
                      value: settings.themeMode,
                      isExpanded: true,
                      borderRadius: BorderRadius.circular(12),
                      onChanged: (mode) {
                        if (mode != null) notifier.setThemeMode(mode);
                      },
                      items: [
                        DropdownMenuItem(
                          value: ThemeMode.dark,
                          child: Text(l10n.settingsThemeDark),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.light,
                          child: Text(l10n.settingsThemeLight),
                        ),
                        DropdownMenuItem(
                          value: ThemeMode.system,
                          child: Text(l10n.settingsThemeSystem),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 28),
          SectionLabel(l10n.settingsAccount),
          const SizedBox(height: 12),
          const _AccountCard(),
          const SizedBox(height: 28),
          SectionLabel(l10n.settingsBackup),
          const SizedBox(height: 12),
          const _BackupCard(),
          const SizedBox(height: 28),
          SectionLabel(l10n.settingsFormats),
          const SizedBox(height: 12),
          const _FormatCatalog(),
          const SizedBox(height: 8),
          Text(
            l10n.settingsFormatsHint,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

/// One row into the account screen, carrying the sync state with it.
///
/// The state belongs here and not only one tap further in: whether the cloud
/// copy is current is the kind of thing that has to be visible without being
/// looked for.
class _AccountCard extends ConsumerWidget {
  const _AccountCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(syncControllerProvider);

    final (icon, subtitle) = switch (status) {
      SyncStatus(configured: false) => (
        Icons.cloud_off_outlined,
        l10n.syncNotConfigured,
      ),
      SyncStatus(busy: true) => (
        Icons.cloud_sync_outlined,
        l10n.syncStateWorking,
      ),
      SyncStatus(conflict: != null) => (
        Icons.call_split,
        l10n.syncConflictTitle,
      ),
      SyncStatus(account: null) => (
        Icons.cloud_off_outlined,
        l10n.syncSignedOutTitle,
      ),
      SyncStatus(dirty: true) => (
        Icons.cloud_upload_outlined,
        l10n.syncStatePending,
      ),
      _ => (Icons.cloud_done_outlined, l10n.syncStateSynced),
    };

    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(
          status.account?.email ?? l10n.settingsAccount,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.chevron_right),
        onTap: () => context.push(AppRoute.account.path),
      ),
    );
  }
}

/// Export and restore of the whole local database.
///
/// Kept prominent even now that the cloud sync exists: a file on disk is the
/// one copy that survives a forgotten password, and it is all a build without
/// Supabase credentials has.
class _BackupCard extends ConsumerWidget {
  const _BackupCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: Text(l10n.backupExport),
            onTap: () => _export(context, ref),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.upload_outlined),
            title: Text(l10n.backupImport),
            onTap: () => _import(context, ref),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 16),
            child: Text(
              l10n.backupExportHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _export(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(backupServiceProvider);

    await downloadTextFile(
      service.suggestedFileName(),
      await service.exportToString(),
    );

    messenger.showSnackBar(SnackBar(content: Text(l10n.backupExportDone)));
  }

  Future<void> _import(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);
    final service = ref.read(backupServiceProvider);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.backupImport),
        content: Text(l10n.backupImportConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.backupImportAction),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    final content = await pickTextFile();
    if (content == null) return;

    try {
      await service.importFromString(content);
      messenger.showSnackBar(SnackBar(content: Text(l10n.backupImportDone)));
    } on BackupFormatException catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.backupImportFailed(error.message))),
      );
    }
  }
}

/// A glance at the catalogue, and the way into editing it.
///
/// The formats stay visible here rather than living only one tap in: which
/// formats exist is the thing the user is checking nine times out of ten, and
/// the row that opens the editor is at the bottom for the tenth.
class _FormatCatalog extends ConsumerWidget {
  const _FormatCatalog();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final games = ref.watch(gamesProvider);

    return switch (games) {
      AsyncData(:final value) => Card(
        child: Column(
          children: [
            for (final (index, game) in value.indexed) ...[
              if (index > 0) const Divider(),
              _GameFormats(game: game),
            ],
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.tune),
              title: Text(l10n.settingsFormatsManage),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(AppRoute.catalog.path),
            ),
          ],
        ),
      ),
      AsyncError() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(l10n.errorGeneric),
        ),
      ),
      // A quiet placeholder rather than a spinner: reading the local database
      // takes milliseconds, so an animation would only ever flash.
      _ => const Card(child: SizedBox(height: 96)),
    };
  }
}

class _GameFormats extends ConsumerWidget {
  const _GameFormats({required this.game});

  final Game game;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final formats = ref.watch(formatsProvider(game.id));

    final accent = theme.gameAccent(game.id);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: accent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  l10n.gameName(game.id, game.name),
                  style: theme.textTheme.titleMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final format in formats.valueOrNull ?? const <Format>[])
                Chip(
                  label: Text(l10n.formatName(format.id, format.name)),
                  visualDensity: VisualDensity.compact,
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SettingRow extends StatelessWidget {
  const _SettingRow({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(icon, size: 20, color: theme.colorScheme.onSurfaceVariant),
          const SizedBox(width: 14),
          Expanded(child: Text(title, style: theme.textTheme.bodyLarge)),
          const SizedBox(width: 8),
          // Capped, because the widest option ("System language") is longer
          // than the room left on a narrow phone.
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 170),
            child: child,
          ),
        ],
      ),
    );
  }
}
