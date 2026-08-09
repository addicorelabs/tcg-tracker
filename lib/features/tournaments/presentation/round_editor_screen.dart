import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/stats/match_stats.dart';
import '../../../data/db/app_database.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/archetype_repository.dart';
import '../../../data/repositories/match_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/widgets/archetype_picker.dart';
import '../../../shared/widgets/game_counters.dart';
import '../../../shared/widgets/number_stepper.dart';
import '../../../shared/widgets/result_chip.dart';
import '../../../shared/widgets/section_label.dart';
import '../providers/tournament_providers.dart';

/// Records a round of a tournament, or edits one when [matchId] is given.
class RoundEditorScreen extends ConsumerWidget {
  const RoundEditorScreen({
    required this.tournamentId,
    this.matchId,
    super.key,
  });

  final String tournamentId;
  final String? matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final tournament = ref.watch(tournamentByIdProvider(tournamentId));

    final error = Scaffold(
      appBar: AppBar(),
      body: Center(child: Text(l10n.errorGeneric)),
    );

    return switch (tournament) {
      AsyncData(value: final tournament?) when matchId == null => _RoundForm(
        tournament: tournament,
      ),
      AsyncData(value: final tournament?) => switch (ref.watch(
        matchByIdProvider(matchId!),
      )) {
        AsyncData(value: final match?) => _RoundForm(
          key: ValueKey(match.id),
          tournament: tournament,
          match: match,
        ),
        AsyncData() || AsyncError() => error,
        _ => Scaffold(appBar: AppBar(), body: const SizedBox.shrink()),
      },
      AsyncData() || AsyncError() => error,
      _ => Scaffold(appBar: AppBar(), body: const SizedBox.shrink()),
    };
  }
}

class _RoundForm extends ConsumerStatefulWidget {
  const _RoundForm({required this.tournament, this.match, super.key});

  final Tournament tournament;
  final Match? match;

  @override
  ConsumerState<_RoundForm> createState() => _RoundFormState();
}

class _RoundFormState extends ConsumerState<_RoundForm> {
  late final TextEditingController _opponent;
  late final TextEditingController _notes;

  /// The opponent's archetype, always a name that exists in the controlled
  /// list rather than whatever was typed into the field.
  String? _archetype;

  /// Set once a save has been refused, so the field stays quiet until the user
  /// has actually had a chance to fill it in.
  bool _archetypeMissing = false;

  int? _roundNumber;
  late bool _isBye;
  bool? _onThePlay;
  late int _won;
  late int _lost;
  late int _drawn;
  bool _saving = false;

  bool get _isEditing => widget.match != null;

  @override
  void initState() {
    super.initState();
    final match = widget.match;

    _opponent = TextEditingController(text: match?.opponentName ?? '');
    _notes = TextEditingController(text: match?.notes ?? '');
    _roundNumber = match?.roundNumber;
    _isBye = match?.result == MatchResult.bye;
    _onThePlay = match?.onThePlay;
    _won = match?.gamesWon ?? 0;
    _lost = match?.gamesLost ?? 0;
    _drawn = match?.gamesDrawn ?? 0;

    if (!_isEditing) _loadNextRoundNumber();
    if (match?.opponentArchetypeId != null) _loadArchetypeName(match!);
  }

  Future<void> _loadNextRoundNumber() async {
    final next = await ref
        .read(matchRepositoryProvider)
        .nextRoundNumber(widget.tournament.id);

    if (mounted) setState(() => _roundNumber ??= next);
  }

  Future<void> _loadArchetypeName(Match match) async {
    final archetypes = await ref
        .read(archetypeRepositoryProvider)
        .watchArchetypes(match.gameId, match.formatId)
        .first;

    final archetype = archetypes
        .where((a) => a.id == match.opponentArchetypeId)
        .firstOrNull;

    if (mounted && archetype != null) {
      setState(() => _archetype = archetype.name);
    }
  }

  @override
  void dispose() {
    _opponent.dispose();
    _notes.dispose();
    super.dispose();
  }

  MatchResult get _result =>
      MatchStats.resultOf(isBye: _isBye, gamesWon: _won, gamesLost: _lost);

  /// Worked out rather than asked for: a round past the planned swiss rounds of
  /// a tournament that has a top cut is a top cut match, and there is nothing
  /// the user could tell us here that this does not already know.
  bool get _isTopCut {
    final tournament = widget.tournament;
    if (!tournament.hasTopCut) return false;
    return (_roundNumber ?? 0) > tournament.roundsPlanned;
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // A round with no opponent deck is a round the matchup matrix cannot use,
    // which is most of the reason the rounds are being recorded at all. A bye
    // is the one round that legitimately has no opponent.
    if (!_isBye && _archetype == null) {
      setState(() => _archetypeMissing = true);
      messenger.showSnackBar(SnackBar(content: Text(l10n.formIncomplete)));
      return;
    }

    setState(() => _saving = true);
    final tournament = widget.tournament;

    // The archetype list is controlled, so a name picked here either matches an
    // existing entry or becomes one. That is what keeps the matchup matrix
    // from splitting a deck across spellings.
    String? archetypeId;
    if (!_isBye && _archetype != null) {
      final archetype = await ref
          .read(archetypeRepositoryProvider)
          .findOrCreate(
            gameId: tournament.gameId,
            formatId: tournament.formatId,
            name: _archetype!,
          );
      archetypeId = archetype.id;
    }

    final input = MatchInput(
      tournamentId: tournament.id,
      gameId: tournament.gameId,
      formatId: tournament.formatId,
      deckId: tournament.deckId,
      roundNumber: _roundNumber,
      isTopCut: _isTopCut,
      opponentName: _isBye ? null : _opponent.text,
      opponentArchetypeId: archetypeId,
      onThePlay: _isBye ? null : _onThePlay,
      gamesWon: _isBye ? 0 : _won,
      gamesLost: _isBye ? 0 : _lost,
      gamesDrawn: _isBye ? 0 : _drawn,
      isBye: _isBye,
      playedAt: widget.match?.playedAt ?? DateTime.now(),
      notes: _notes.text,
    );

    final repository = ref.read(matchRepositoryProvider);
    if (_isEditing) {
      await repository.update(widget.match!.id, input);
    } else {
      await repository.add(input);
    }

    if (mounted) context.pop();
  }

  Future<void> _delete() async {
    await ref.read(matchRepositoryProvider).delete(widget.match!.id);
    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.roundEdit : l10n.roundNew),
        actions: [
          if (_isEditing)
            IconButton(
              tooltip: l10n.roundDelete,
              icon: const Icon(Icons.delete_outline),
              onPressed: _saving ? null : _delete,
            ),
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(l10n.actionSave),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(
                      _isTopCut
                          ? l10n.roundTopCut
                          : l10n.roundNumber(_roundNumber ?? 1),
                    ),
                    const SizedBox(height: 8),
                    NumberStepper(
                      value: _roundNumber ?? 1,
                      min: 1,
                      max: 30,
                      onChanged: (value) =>
                          setState(() => _roundNumber = value),
                    ),
                  ],
                ),
              ),
              ResultChip(_result),
            ],
          ),
          const SizedBox(height: 20),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: Text(l10n.matchIsBye),
            subtitle: Text(l10n.matchIsByeHint),
            value: _isBye,
            onChanged: (value) => setState(() => _isBye = value),
          ),

          // Everything below describes an opponent, which a bye does not have.
          if (!_isBye) ...[
            const SizedBox(height: 12),
            SectionLabel(l10n.matchOpponentDeck),
            const SizedBox(height: 8),
            ArchetypePicker(
              value: _archetype,
              errorText: _archetypeMissing && _archetype == null
                  ? l10n.fieldRequired
                  : null,
              onChanged: (value) => setState(() {
                _archetype = value;
                _archetypeMissing = false;
              }),
              gameId: widget.tournament.gameId,
              formatId: widget.tournament.formatId,
            ),
            const SizedBox(height: 20),
            SectionLabel(l10n.matchOpponentName),
            const SizedBox(height: 8),
            TextFormField(
              controller: _opponent,
              decoration: InputDecoration(helperText: l10n.fieldOptional),
            ),
            const SizedBox(height: 20),
            SectionLabel(l10n.matchOnThePlay),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: [
                ChoiceChip(
                  label: Text(l10n.matchPlayShort),
                  selected: _onThePlay == true,
                  onSelected: (selected) =>
                      setState(() => _onThePlay = selected ? true : null),
                ),
                ChoiceChip(
                  label: Text(l10n.matchDrawShort),
                  selected: _onThePlay == false,
                  onSelected: (selected) =>
                      setState(() => _onThePlay = selected ? false : null),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SectionLabel(l10n.matchGames),
            const SizedBox(height: 8),
            GameCounters(
              won: _won,
              lost: _lost,
              drawn: _drawn,
              onChanged: (won, lost, drawn) => setState(() {
                _won = won;
                _lost = lost;
                _drawn = drawn;
              }),
            ),
          ],
          const SizedBox(height: 20),
          SectionLabel(l10n.fieldNotes),
          const SizedBox(height: 8),
          TextFormField(controller: _notes, maxLines: 3),
        ],
      ),
    );
  }
}
