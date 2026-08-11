import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/decklist/decklist_parser.dart';
import '../../../core/platform/browser_files.dart';
import '../../../core/utils/catalog_names.dart';
import '../../../data/db/app_database.dart';
import '../../../data/db/seed.dart';
import '../../../data/models/enums.dart';
import '../../../data/repositories/catalog_repository.dart';
import '../../../data/repositories/deck_repository.dart';
import '../../../l10n/app_localizations.dart';
import '../../../shared/layout/floating_bar_inset.dart';
import '../../../shared/widgets/archetype_picker.dart';
import '../../../shared/widgets/mana_pips.dart';
import '../../../shared/widgets/section_label.dart';
import '../providers/deck_filter_provider.dart';

/// Creates a deck, or edits an existing one when [deckId] is given.
class DeckEditorScreen extends ConsumerWidget {
  const DeckEditorScreen({this.deckId, this.initialArchetype, super.key});

  final String? deckId;

  /// Prefilled when the editor was opened from inside an archetype, where a new
  /// deck can only be another build of that archetype.
  final String? initialArchetype;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);

    if (deckId == null) {
      return _DeckForm(
        initialGameId: ref.watch(deckGameProvider),
        initialArchetype: initialArchetype,
      );
    }

    final deck = ref.watch(deckByIdProvider(deckId!));

    return switch (deck) {
      AsyncData(value: final deck?) => _DeckForm(
        // Keyed by id so the form state is rebuilt when a different deck is
        // opened rather than keeping the previous one's text.
        key: ValueKey(deck.id),
        deck: deck,
        initialGameId: deck.gameId,
      ),
      AsyncData() || AsyncError() => Scaffold(
        appBar: AppBar(),
        body: Center(child: Text(l10n.errorGeneric)),
      ),
      _ => Scaffold(appBar: AppBar(), body: const SizedBox.shrink()),
    };
  }
}

class _DeckForm extends ConsumerStatefulWidget {
  const _DeckForm({
    required this.initialGameId,
    this.deck,
    this.initialArchetype,
    super.key,
  });

  final Deck? deck;
  final String initialGameId;
  final String? initialArchetype;

  @override
  ConsumerState<_DeckForm> createState() => _DeckFormState();
}

class _DeckFormState extends ConsumerState<_DeckForm> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _notes;

  /// Null until an archetype is chosen, which the form refuses to save without.
  String? _archetype;

  late String _gameId;
  String? _formatId;
  late Set<ManaColor> _colors;
  bool _saving = false;

  Uint8List? _photo;
  String? _photoMimeType;

  /// Null until the user touches the photo or the list, so an edit that leaves
  /// them alone does not rewrite what is already stored.
  bool _photoChanged = false;
  List<ParsedCard>? _pendingCards;

  bool get _isEditing => widget.deck != null;
  bool get _isMagic => _gameId == Seed.magicId;

  @override
  void initState() {
    super.initState();
    final deck = widget.deck;

    _name = TextEditingController(text: deck?.name ?? '');
    _archetype = deck?.archetype ?? widget.initialArchetype;
    _notes = TextEditingController(text: deck?.notes ?? '');
    _gameId = deck?.gameId ?? widget.initialGameId;
    // A new deck starts in whatever format the library is filtered to, which
    // is nearly always the one the user is about to add a deck for.
    _formatId = deck?.formatId ?? ref.read(deckFilterProvider).formatId;
    _colors = ManaColor.parse(deck?.colors).toSet();
    _photo = deck?.photo;
    _photoMimeType = deck?.photoMimeType;
  }

  @override
  void dispose() {
    _name.dispose();
    _notes.dispose();
    super.dispose();
  }

  /// What the decklist section shows: the freshly imported list if there is
  /// one, otherwise whatever is stored against this deck.
  List<ParsedCard> get _cards {
    if (_pendingCards != null) return _pendingCards!;
    if (!_isEditing) return const [];

    final stored =
        ref.watch(deckCardsProvider(widget.deck!.id)).valueOrNull ??
        const <DeckCard>[];

    return [
      for (final card in stored)
        ParsedCard(
          section: card.section,
          name: card.name,
          quantity: card.quantity,
        ),
    ];
  }

  Future<void> _pickPhoto() async {
    final image = await pickImage();
    if (image == null || !mounted) return;

    setState(() {
      _photo = image.bytes;
      _photoMimeType = image.mimeType;
      _photoChanged = true;
    });
  }

  void _removePhoto() {
    setState(() {
      _photo = null;
      _photoMimeType = null;
      _photoChanged = true;
    });
  }

  Future<void> _importList() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    final content = await pickTextFile(accept: '.txt,.dek,text/plain');
    if (content == null || !mounted) return;

    final parsed = DecklistParser.parse(content);
    if (parsed.isEmpty) {
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.deckListImportFailed)),
      );
      return;
    }

    setState(() => _pendingCards = parsed.cards);
  }

  Future<void> _save() async {
    final l10n = AppLocalizations.of(context);
    final messenger = ScaffoldMessenger.of(context);

    // Silence is the worst possible answer to a save: a refused one has to say
    // why, otherwise it is indistinguishable from the button not working.
    if (!_formKey.currentState!.validate() ||
        _formatId == null ||
        _archetype == null) {
      messenger.showSnackBar(SnackBar(content: Text(l10n.formIncomplete)));
      return;
    }

    setState(() => _saving = true);
    final repository = ref.read(deckRepositoryProvider);
    final colors = _isMagic && _colors.isNotEmpty
        ? ManaColor.encode(_colors)
        : null;
    final notes = _notes.text.trim().isEmpty ? null : _notes.text.trim();

    try {
      final String deckId;
      if (_isEditing) {
        deckId = widget.deck!.id;
        await repository.updateDeck(
          id: deckId,
          formatId: _formatId!,
          name: _name.text,
          archetype: _archetype!,
          colors: colors,
          notes: notes,
        );
        if (_photoChanged) {
          await repository.setPhoto(
            deckId,
            image: _photo,
            mimeType: _photoMimeType,
          );
        }
      } else {
        final created = await repository.createDeck(
          gameId: _gameId,
          formatId: _formatId!,
          name: _name.text,
          archetype: _archetype!,
          colors: colors,
          notes: notes,
          photo: _photo,
          photoMimeType: _photoMimeType,
        );
        deckId = created.id;
      }

      if (_pendingCards != null) {
        await repository.replaceCards(deckId, _pendingCards!);
      }

      // Point the library at the deck that was just saved, so it is on screen
      // when the editor closes instead of hidden behind a filter.
      ref
          .read(deckFilterProvider.notifier)
          .reveal(gameId: _gameId, formatId: _formatId!);

      if (mounted) Navigator.of(context).pop();
    } catch (error) {
      // The database is the one thing here that can fail for reasons the user
      // cannot see: a browser that refused storage, a migration that did not
      // run. Showing the reason is what makes that reportable instead of
      // looking like a dead button.
      messenger.showSnackBar(
        SnackBar(content: Text(l10n.saveFailed('$error'))),
      );
    } finally {
      // Without this the button stays disabled after a failure and the screen
      // can never be saved again.
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

    // The format list arrives asynchronously, so a new deck picks the first
    // one only once it is actually known.
    if (_formatId == null && formats.isNotEmpty) {
      _formatId = formats.first.id;
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.deckEdit : l10n.deckNew),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: Text(l10n.actionSave),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            16,
            16,
            16,
            32,
          ).clearingFloatingBar,
          children: [
            // The game list arrives from the database a frame later, and a
            // SegmentedButton with no segments asserts.
            if (!_isEditing && games.isNotEmpty) ...[
              // Never blocking: a game is always selected, starting from the
              // one the library is showing.
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
                  // The old format belongs to the other game, and so does the
                  // archetype that was picked from that format's list.
                  _formatId = null;
                  _archetype = null;
                }),
              ),
              const SizedBox(height: 20),
            ],
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
                // Archetype lists are per format, so a choice made in the old
                // one has to be made again rather than saved silently against
                // a format it was never on the list for.
                _archetype = null;
              }),
              // Validated against the field's own state rather than the
              // dropdown's: the dropdown is first built while the format list
              // is still loading, so its internal value can stay null after
              // _formatId has been filled in, which would refuse every save.
              validator: (_) => _formatId == null ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 20),
            SectionLabel(l10n.deckName),
            const SizedBox(height: 8),
            TextFormField(
              controller: _name,
              textInputAction: TextInputAction.next,
              validator: (value) =>
                  (value ?? '').trim().isEmpty ? l10n.fieldRequired : null,
            ),
            const SizedBox(height: 20),
            SectionLabel(l10n.deckArchetype),
            const SizedBox(height: 8),
            _ArchetypeField(
              value: _archetype,
              onChanged: (value) => setState(() => _archetype = value),
              gameId: _gameId,
              formatId: _formatId,
              helperText: l10n.deckArchetypeHint,
            ),
            if (_isMagic) ...[
              const SizedBox(height: 20),
              SectionLabel(l10n.deckColors, optional: true),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final color in ManaColor.values)
                    FilterChip(
                      label: Text(color.code),
                      avatar: CircleAvatar(
                        backgroundColor: color.color,
                        radius: 8,
                      ),
                      selected: _colors.contains(color),
                      onSelected: (selected) => setState(() {
                        if (selected) {
                          _colors.add(color);
                        } else {
                          _colors.remove(color);
                        }
                      }),
                    ),
                ],
              ),
            ],
            const SizedBox(height: 20),
            SectionLabel(l10n.deckPhoto, optional: true),
            const SizedBox(height: 8),
            _PhotoField(
              photo: _photo,
              onPick: _pickPhoto,
              onRemove: _removePhoto,
            ),
            const SizedBox(height: 20),
            SectionLabel(l10n.deckList, optional: true),
            const SizedBox(height: 8),
            _DecklistField(
              cards: _cards,
              onImport: _importList,
              onClear: () => setState(() => _pendingCards = const []),
            ),
            const SizedBox(height: 20),
            SectionLabel(l10n.deckNotes, optional: true),
            const SizedBox(height: 8),
            TextFormField(controller: _notes, maxLines: 4),
          ],
        ),
      ),
    );
  }
}

class _PhotoField extends StatelessWidget {
  const _PhotoField({
    required this.photo,
    required this.onPick,
    required this.onRemove,
  });

  final Uint8List? photo;
  final VoidCallback onPick;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final photo = this.photo;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (photo != null) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              photo,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onPick,
                icon: const Icon(Icons.image_outlined),
                label: Text(l10n.deckPhotoReplace),
              ),
              const SizedBox(width: 10),
              TextButton(
                onPressed: onRemove,
                child: Text(l10n.deckPhotoRemove),
              ),
            ],
          ),
        ] else
          OutlinedButton.icon(
            onPressed: onPick,
            icon: const Icon(Icons.add_a_photo_outlined),
            label: Text(l10n.deckPhotoAdd),
          ),
        const SizedBox(height: 8),
        Text(
          l10n.deckPhotoHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

class _DecklistField extends StatelessWidget {
  const _DecklistField({
    required this.cards,
    required this.onImport,
    required this.onClear,
  });

  final List<ParsedCard> cards;
  final VoidCallback onImport;
  final VoidCallback onClear;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final decklist = ParsedDecklist(cards);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (cards.isEmpty)
          Text(
            l10n.deckListEmpty,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          )
        else
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (final section in DeckSection.values)
                    if (decklist.section(section).isNotEmpty) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            l10n.sectionName(section).toUpperCase(),
                            style: theme.textTheme.labelSmall,
                          ),
                          Text(
                            l10n.deckListCards(decklist.countIn(section)),
                            style: theme.textTheme.labelSmall,
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      for (final card in decklist.section(section))
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Text(
                            '${card.quantity}  ${card.name}',
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                      const SizedBox(height: 14),
                    ],
                ],
              ),
            ),
          ),
        const SizedBox(height: 10),
        Row(
          children: [
            OutlinedButton.icon(
              onPressed: onImport,
              icon: const Icon(Icons.upload_file_outlined),
              label: Text(l10n.deckListImport),
            ),
            if (cards.isNotEmpty) ...[
              const SizedBox(width: 10),
              TextButton(onPressed: onClear, child: Text(l10n.deckListClear)),
            ],
          ],
        ),
        const SizedBox(height: 8),
        Text(
          l10n.deckListHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

/// The deck's archetype, chosen from the same controlled list as the
/// opponent's.
///
/// It used to be free text with suggestions. It is a menu now for the reason
/// the opponent's field always was one: the archetype is what the analytics
/// group by, so "Snake-Eye" typed here and "Snake-Eye Fire King" typed there
/// become two rows of a matchup matrix that should have had one. The + button
/// still takes anything the list does not have.
class _ArchetypeField extends StatelessWidget {
  const _ArchetypeField({
    required this.value,
    required this.onChanged,
    required this.gameId,
    required this.formatId,
    required this.helperText,
  });

  final String? value;
  final ValueChanged<String?> onChanged;
  final String gameId;
  final String? formatId;
  final String helperText;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final formatId = this.formatId;

    // Only while the format list is still loading, since a format is picked
    // for the user as soon as one is known. A quiet gap rather than a spinner
    // that would flash for one frame.
    if (formatId == null) return const SizedBox(height: 72);

    return FormField<String>(
      initialValue: value,
      validator: (_) =>
          (value ?? '').trim().isEmpty ? l10n.fieldRequired : null,
      builder: (field) => ArchetypePicker(
        value: value,
        gameId: gameId,
        formatId: formatId,
        helperText: helperText,
        errorText: field.errorText,
        onChanged: (selected) {
          onChanged(selected);
          field.didChange(selected);
        },
      ),
    );
  }
}
