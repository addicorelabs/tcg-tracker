import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../data/sync/sync_controller.dart';
import '../../../data/sync/sync_status.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/layout/floating_bar_inset.dart';
import '../../../shared/widgets/section_label.dart';

/// Account, sync state and the two buttons that resolve a disagreement.
///
/// One screen rather than a row buried in settings: on a PWA the cloud copy is
/// the only copy the browser cannot throw away, so whether it is up to date is
/// something the user has to be able to check at a glance.
class AccountScreen extends ConsumerWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(syncControllerProvider);

    return Scaffold(
      appBar: AppBar(title: Text(l10n.settingsAccount)),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32).clearingFloatingBar,
        children: [
          if (!status.configured)
            const _NotConfiguredCard()
          else if (!status.signedIn)
            const _SignedOutSection()
          else
            _SignedInSection(status: status),
        ],
      ),
    );
  }
}

/// A build with no Supabase credentials. Says so, instead of offering a form
/// that could only ever fail.
class _NotConfiguredCard extends StatelessWidget {
  const _NotConfiguredCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    l10n.syncNotConfigured,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              l10n.syncNotConfiguredHint,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SignedOutSection extends ConsumerStatefulWidget {
  const _SignedOutSection();

  @override
  ConsumerState<_SignedOutSection> createState() => _SignedOutSectionState();
}

class _SignedOutSectionState extends ConsumerState<_SignedOutSection> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _creating = false;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final status = ref.watch(syncControllerProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(l10n.syncSignedOutTitle),
        const SizedBox(height: 10),
        Text(
          l10n.syncSignedOutHint,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 18),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                autocorrect: false,
                autofillHints: const [AutofillHints.email],
                decoration: InputDecoration(labelText: l10n.syncEmail),
                validator: (value) =>
                    _looksLikeEmail(value) ? null : l10n.syncEmailInvalid,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _password,
                obscureText: true,
                autofillHints: const [AutofillHints.password],
                decoration: InputDecoration(labelText: l10n.syncPassword),
                validator: (value) => (value ?? '').length >= 6
                    ? null
                    : l10n.syncPasswordTooShort,
              ),
            ],
          ),
        ),
        if (status.error != null) ...[
          const SizedBox(height: 14),
          _ErrorCard(message: status.error!),
        ],
        const SizedBox(height: 18),
        FilledButton(
          onPressed: status.busy ? null : _submit,
          child: Text(
            _creating ? l10n.syncActionSignUp : l10n.syncActionSignIn,
          ),
        ),
        const SizedBox(height: 4),
        TextButton(
          onPressed: status.busy
              ? null
              : () => setState(() => _creating = !_creating),
          child: Text(
            _creating ? l10n.syncSwitchToSignIn : l10n.syncSwitchToSignUp,
          ),
        ),
        if (!_creating)
          TextButton(
            onPressed: status.busy ? null : _resetPassword,
            child: Text(l10n.syncActionForgotPassword),
          ),
        const SizedBox(height: 20),
        const _HowItWorks(),
      ],
    );
  }

  /// Deliberately loose. The address is verified by whether the mail arrives,
  /// and a stricter pattern here would only reject valid addresses.
  bool _looksLikeEmail(String? value) {
    final text = (value ?? '').trim();
    final at = text.indexOf('@');
    return at > 0 && text.indexOf('.', at) > at + 1 && !text.endsWith('.');
  }

  Future<void> _submit() async {
    if (_formKey.currentState?.validate() != true) return;

    final controller = ref.read(syncControllerProvider.notifier);
    final email = _email.text.trim();
    final password = _password.text;

    if (_creating) {
      await controller.signUp(email: email, password: password);
    } else {
      await controller.signIn(email: email, password: password);
    }
  }

  Future<void> _resetPassword() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (!_looksLikeEmail(_email.text)) {
      _formKey.currentState?.validate();
      return;
    }

    final email = _email.text.trim();
    await ref.read(syncControllerProvider.notifier).sendPasswordReset(email);

    if (!mounted) return;
    if (ref.read(syncControllerProvider).error == null) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.syncResetSent(email))),
      );
    }
  }
}

class _SignedInSection extends ConsumerWidget {
  const _SignedInSection({required this.status});

  final SyncStatus status;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(syncControllerProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionLabel(l10n.settingsAccount),
        const SizedBox(height: 10),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.person_outline),
                title: Text(status.account?.email ?? ''),
                subtitle: Text(_stateLine(context, status)),
              ),
              if (status.lastSyncAt != null)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      l10n.syncLastSync(
                        _formatMoment(context, status.lastSyncAt!),
                      ),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
        if (status.conflict != null) ...[
          const SizedBox(height: 16),
          _ConflictCard(conflict: status.conflict!, busy: status.busy),
        ],
        if (status.error != null) ...[
          const SizedBox(height: 16),
          _ErrorCard(message: status.error!),
        ],
        const SizedBox(height: 16),
        Card(
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.sync),
                title: Text(l10n.syncActionSyncNow),
                enabled: !status.busy,
                onTap: controller.syncNow,
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.cloud_download_outlined),
                title: Text(l10n.syncActionDownload),
                enabled: !status.busy,
                onTap: () => _confirmDownload(context, ref),
              ),
              const Divider(height: 1),
              SwitchListTile(
                secondary: const Icon(Icons.autorenew),
                title: Text(l10n.syncAuto),
                subtitle: Text(l10n.syncAutoHint),
                value: status.autoSync,
                onChanged: controller.setAutoSync,
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        OutlinedButton.icon(
          onPressed: status.busy ? null : controller.signOut,
          icon: const Icon(Icons.logout),
          label: Text(l10n.syncActionSignOut),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.syncSignOutHint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 20),
        const _HowItWorks(),
      ],
    );
  }

  String _stateLine(BuildContext context, SyncStatus status) {
    final l10n = AppLocalizations.of(context);
    if (status.busy) return l10n.syncStateWorking;
    if (status.dirty) return l10n.syncStatePending;
    if (status.lastSyncAt == null) return l10n.syncStateNever;
    return l10n.syncStateSynced;
  }

  Future<void> _confirmDownload(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context);

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.syncActionDownload),
        content: Text(l10n.syncActionDownloadConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.syncActionDownload),
          ),
        ],
      ),
    );

    if (confirmed != true) return;
    await ref.read(syncControllerProvider.notifier).resolveKeepCloud();
  }
}

/// The one moment sync asks the user something.
///
/// Both buttons discard data, so neither is the safe default and neither is
/// pre-selected: the card says what the cloud copy is and when it was made,
/// and stops there.
class _ConflictCard extends ConsumerWidget {
  const _ConflictCard({required this.conflict, required this.busy});

  final SyncConflict conflict;
  final bool busy;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final controller = ref.read(syncControllerProvider.notifier);

    return Card(
      color: theme.colorScheme.errorContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.call_split,
                  color: theme.colorScheme.onErrorContainer,
                ),
                const SizedBox(width: 12),
                Text(
                  l10n.syncConflictTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: theme.colorScheme.onErrorContainer,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              l10n.syncConflictBody(
                conflict.remoteDevice ?? l10n.syncConflictUnknownDevice,
                _formatMoment(context, conflict.remoteUpdatedAt),
              ),
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onErrorContainer,
              ),
            ),
            const SizedBox(height: 14),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                FilledButton(
                  onPressed: busy ? null : controller.resolveKeepLocal,
                  child: Text(l10n.syncActionKeepLocal),
                ),
                OutlinedButton(
                  onPressed: busy ? null : controller.resolveKeepCloud,
                  child: Text(l10n.syncActionKeepCloud),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorCard extends StatelessWidget {
  const _ErrorCard({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    return Card(
      color: theme.colorScheme.surfaceContainerHighest,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              l10n.syncErrorTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 6),
            Text(message, style: theme.textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}

class _HowItWorks extends StatelessWidget {
  const _HowItWorks();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Text(
      AppLocalizations.of(context).syncHowItWorks,
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

String _formatMoment(BuildContext context, DateTime moment) {
  final locale = Localizations.localeOf(context).toLanguageTag();
  return DateFormat.yMMMd(locale).add_Hm().format(moment);
}
