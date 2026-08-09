import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../app/routes.dart';
import '../../../core/tournaments/event_options.dart';
import '../../../core/utils/catalog_names.dart';
import '../../../data/db/app_database.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/deck_repository.dart';
import '../../../data/repositories/tournament_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/number_stepper.dart';
import '../../../shared/widgets/section_label.dart';
import '../../decks/providers/deck_filter_provider.dart';
import '../providers/tournament_providers.dart';

/// Records a tournament, or edits one when [tournamentId] is given.
///
/// One scrolling form rather than a step-by-step wizard: there are eight
/// fields, and being able to see and correct all of them before saving beats
/// paging through four screens.
class TournamentEditorScreen extends ConsumerWidget {
  const TournamentEditorScreen({this.tournamentId, super.key});

  final String? tournamentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (tournamentId == null) return const _TournamentForm();

    final tournament = ref.watch(tournamentByIdProvider(tournamentId!));

    return switch (tournament) {
      AsyncData(value: final tournament?) => _TournamentForm(
        key: ValueKey(tournament.id),
        tournament: tournament,
      ),
      AsyncData() || AsyncError() => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.errorGeneric)),
      ),
      _ => Scaffold(appBar: AppBar(), body: const SizedBox.shrink()),
    };
  }
}

class _TournamentForm extends ConsumerStatefulWidget {
  const _TournamentForm({this.tournament, super.key});

  final Tournament? tournament;

  @override
  ConsumerState<_TournamentForm> createState() => _TournamentFormState();
}

class _TournamentFormState extends ConsumerState<_TournamentForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _participants;
  late final TextEditingController _notes;

  late String _gameId;
  String? _formatId;
  String? _deckId;
  late DateTime _date;

  /// No default: which kind of event this was is the one thing about a
  /// tournament that cannot be guessed from anything else, and a wrong default
  /// would quietly file every local event as whatever this enum lists first.
  EventType? _eventType;
  late int _rounds;
  late bool _hasTopCut;
  late int _topCutSize;
  bool _saving = false;

  bool get _isEditing => widget.tournament != null;

  @override
  void initState() {
    super.initState();
    final tournament = widget.tournament;

    _name = TextEditingController(text: tournament?.name ?? '');
    _participants = TextEditingController(
      text: tournament?.participantCount?.toString() ?? '',
    );
    _notes = TextEditingController(text: tournament?.notes ?? '');
    _gameId = tournament?.gameId ?? ref.read(deckGameProvider);
    _formatId = tournament?.formatId;
    _deckId = tournament?.deckId;
    _date = tournament?.date ?? DateTime.now();
    _eventType = tournament?.eventType;
    _rounds = tournament?.roundsPlanned ?? 4;
    _hasTopCut = tournament?.hasTopCut ?? false;
    _topCutSize = tournament?.topCutSize ?? 8;
  }

  @override
  void dispose() {
    _name.dispose();
    _participants.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );

    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    if (!_formKey.currentState!.validate() ||
        _formatId == null ||
        _deckId == null ||
        _eventType == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.formIncomplete)));
      return;
    }

    setState(() => _saving = true);
    final repository = ref.read(tournamentRepositoryProvider);
    final participants = int.tryParse(_participants.text.trim());
    final notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();

    try {
      if (_isEditing) {
        await repository.update(
          id: widget.tournament!.id,
          name: _name.text,
          date: _date,
          eventType: _eventType!,
          roundsPlanned: _rounds,
          deckId: _deckId!,
          participantCount: participants,
          hasTopCut: _hasTopCut,
          topCutSize: _hasTopCut ? _topCutSize : null,
          notes: notes,
        );
        if (mounted) context.pop();
        return;
      }

      final created = await repository.create(
        gameId: _gameId,
        formatId: _formatId!,
        deckId: _deckId!,
        name: _name.text,
        date: _date,
        eventType: _eventType!,
        roundsPlanned: _rounds,
        participantCount: participants,
        hasTopCut: _hasTopCut,
        topCutSize: _hasTopCut ? _topCutSize : null,
        notes: notes,
      );

      // Straight into the tournament, which is where the user wants to be: the
      // next thing they do is record round one.
      if (mounted) {
        context.pushReplacementNamed(
          AppRoute.tournamentDetail.routeName,
          pathParameters: {'id': created.id},
        );
      }
    } catch (error) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.saveFailed('$error'))),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final games = ref.watch(gamesProvider).valueOrNull ?? const <Game>[];
    final formats = ref.watch(
      editableFormatsProvider((gameId: _gameId, keepId: _formatId)),
    );

    if (_formatId == null && formats.isNotEmpty) _formatId = formats.first.id;

    final decks =
        ref
            .watch(
              decksForTournamentProvider((
                gameId: _gameId,
                formatId: _formatId ?? '',
              )),
            )
            .valueOrNull ??
        const <Deck>[];

    if (!decks.any((d) => d.id == _deckId)) {
      _deckId = decks.isEmpty ? null : decks.first.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? l10n.tournamentEdit : l10n.actionNewTournament,
        ),
        actions: [
          TextButton(
            onPressed: _saving || decks.isEmpty ? null : _save,
            child: Text(l10n.actionSave),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
          children: [
            // The game list arrives from the database a frame later, and a
            // SegmentedButton with no segments asserts.
            if (!_isEditing && games.isNotEmpty) ...[
              SectionLabel(l10n.deckGame, optional: true),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: [
                  for (final game in games)
                    ButtonSegment(
                      value: game.id,
                      label: Text(
                        l10n.gameName(game.id, game.name),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                ],
                selected: {_gameId},
                showSelectedIcon: false,
                onSelectionChanged: (selection) => setState(() {
                  _gameId = selection.first;
                  _formatId = null;
                  _deckId = null;

                  // The two games run different circuits, so an event type or
                  // a cut size chosen for the other one may not exist here.
                  if (!EventOptions.typesFor(_gameId).contains(_eventType)) {
                    _eventType = null;
                  }
                  final cuts = EventOptions.topCutSizesFor(_gameId);
                  if (!cuts.contains(_topCutSize)) _topCutSize = cuts.first;
                }),
              ),
              const SizedBox(height: 20),
              SectionLabel(l10n.deckFormat),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                initialValue: formats.any((f) => f.id == _formatId)
                    ? _formatId
                    : null,
                items: [
                  for (final format in formats)
                    DropdownMenuItem(
                      value: format.id,
                      child: Text(l10n.formatName(format.id, format.name)),
                    ),
                ],
                onChanged: (value) => setState(() {
                  _formatId = value;
                  _deckId = null;
                }),
                validator: (value) => value == null ? l10n.fieldRequired : null,
              ),
              const SizedBox(height: 20),
            ],
            SectionLabel(l10n.tournamentDeck),
            const SizedBox(height: 8),
            if (decks.isEmpty)
              EmptyState(
                icon: Icons.style_outlined,
                title: l10n.tournamentNeedsDeck,
                message: l10n.tournamentNeedsDeckHint,
              )
            else
              DropdownButtonFormField<String>(
                initialValue: _deckId,
                items: [
                  for (final deck in decks)
                    DropdownMenuItem(
                      value: deck.id,
                      child: Text(deck.name, overflow: TextOverflow.ellipsis),
                    ),
                ],
                onChanged: (value) => setState(() => _deckId = value),
                validator: (value) => value == null ? l10n.fieldRequired : null,
              ),
            const SizedBox(height: 20),
            SectionLabel(l10n.tournamentName),
            const SizedBox(height: 8),
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 20),
            SectionLabel(l10n.tournamentDate, optional: true),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: _pickDate,
              icon: const Icon(Icons.calendar_today_outlined),
              label: Text(
                DateFormat.yMMMMd(
                  Localizations.localeOf(context).toString(),
                ).format(_date),
              ),
            ),
            const SizedBox(height: 20),
            SectionLabel(l10n.tournamentEventType),
            const SizedBox(height: 8),
            // A FormField rather than a bare Wrap, so an unanswered choice is
            // reported where the user is looking instead of only in a snackbar.
            FormField<EventType>(
              initialValue: _eventType,
              validator: (_) => _eventType == null ? l10n.fieldRequired : null,
              builder: (field) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final type in EventOptions.typesForEditing(
                        _gameId,
                        _eventType,
                      ))
                        ChoiceChip(
                          label: Text(l10n.eventTypeName(type)),
                          selected: _eventType == type,
                          onSelected: (_) {
                            setState(() => _eventType = type);
                            field.didChange(type);
                          },
                        ),
                    ],
                  ),
                  if (field.hasError) ...[
                    const SizedBox(height: 8),
                    Text(
                      field.errorText!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),
            SectionLabel(l10n.tournamentRounds, optional: true),
            const SizedBox(height: 8),
            NumberStepper(
              value: _rounds,
              min: 1,
              max: 20,
              onChanged: (value) => setState(() => _rounds = value),
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(l10n.tournamentTopCut),
              value: _hasTopCut,
              onChanged: (value) => setState(() => _hasTopCut = value),
            ),
            if (_hasTopCut) ...[
              const SizedBox(height: 8),
              SectionLabel(l10n.tournamentTopCutSize, optional: true),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final size in EventOptions.topCutSizesForEditing(
                    _gameId,
                    _topCutSize,
                  ))
                    ChoiceChip(
                      label: Text('Top $size'),
                      selected: _topCutSize == size,
                      onSelected: (_) => setState(() => _topCutSize = size),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            SectionLabel(l10n.tournamentParticipants, optional: true),
            const SizedBox(height: 8),
            TextFormField(
              controller: _participants,
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            SectionLabel(l10n.fieldNotes, optional: true),
            const SizedBox(height: 8),
            TextFormField(controller: _notes, maxLines: 3),
          ],
        ),
      ),
    );
  }
}

/// The decks that can be picked for a tournament: the active ones of that game
/// and format, since a deck is only legal in the format it was built for.
final decksForTournamentProvider =
    StreamProvider.family<List<Deck>, ({String gameId, String formatId})>((
      ref,
      scope,
    ) {
      return ref
          .watch(deckRepositoryProvider)
          .watchDecks(gameId: scope.gameId, formatId: scope.formatId);
    });
