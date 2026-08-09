import '../../data/models/enums.dart';

/// One entry of a parsed decklist.
class ParsedCard {
  const ParsedCard({
    required this.section,
    required this.name,
    required this.quantity,
  });

  final DeckSection section;
  final String name;
  final int quantity;

  @override
  String toString() => '$quantity $name (${section.name})';
}

/// The result of reading a decklist file.
class ParsedDecklist {
  const ParsedDecklist(this.cards);

  final List<ParsedCard> cards;

  bool get isEmpty => cards.isEmpty;

  List<ParsedCard> section(DeckSection section) => [
    for (final card in cards)
      if (card.section == section) card,
  ];

  /// Total number of physical cards in a section, not number of entries.
  int countIn(DeckSection section) => [
    for (final card in cards)
      if (card.section == section) card.quantity,
  ].fold(0, (sum, quantity) => sum + quantity);

  int get totalCards => cards.fold(0, (sum, card) => sum + card.quantity);
}

/// Reads the plain-text decklists that every deckbuilding site exports.
///
/// It deliberately validates nothing about the cards themselves: the app has no
/// card database, and a list that fails to import because of a misspelling
/// would be worse than one that imports exactly what the file said.
abstract final class DecklistParser {
  /// Lines that name a section instead of a card.
  static const _sectionHeaders = <String, DeckSection>{
    'deck': DeckSection.main,
    'main': DeckSection.main,
    'main deck': DeckSection.main,
    'maindeck': DeckSection.main,
    'mazzo': DeckSection.main,
    'sideboard': DeckSection.side,
    'side': DeckSection.side,
    'side deck': DeckSection.side,
    'sidedeck': DeckSection.side,
    'extra': DeckSection.extra,
    'extra deck': DeckSection.extra,
    'extradeck': DeckSection.extra,
    'commander': DeckSection.commander,
    'comandante': DeckSection.commander,
  };

  /// Preamble emitted by deckbuilding sites that carries no cards.
  ///
  /// Arena exports open with an "About" block whose `Name <deck name>` line
  /// would otherwise be read as a single copy of a card called "Name ...".
  static const _ignoredHeaders = {'about', 'companion'};
  static const _ignoredPrefixes = {'name ', 'companion '};

  /// "4 Lightning Bolt", "4x Lightning Bolt", or just "Lightning Bolt".
  static final _cardLine = RegExp(r'^(\d+)\s*[xX]?\s+(.+)$');

  /// Trailing set and collector number, as in "Lightning Bolt (M11) 149".
  static final _setSuffix = RegExp(r'\s*\([A-Za-z0-9]{2,6}\)(\s+[\w-]+)?\s*$');

  static ParsedDecklist parse(String text) {
    final cards = <ParsedCard>[];
    var section = DeckSection.main;

    // MTGO and several exporters separate main deck from sideboard with a
    // blank line and no header at all, so the first blank line after some
    // cards switches section — but only while no header has been seen, since
    // an explicit header always wins.
    var sawHeader = false;
    var blankLineSwitchesSection = false;

    for (final rawLine in text.split(RegExp(r'\r?\n'))) {
      final line = rawLine.trim();

      if (line.isEmpty) {
        if (!sawHeader && cards.isNotEmpty && blankLineSwitchesSection) {
          section = DeckSection.side;
          blankLineSwitchesSection = false;
        }
        continue;
      }

      if (line.startsWith('#') || line.startsWith('//')) continue;

      final header = _headerOf(line);
      if (header != null) {
        section = header;
        sawHeader = true;
        continue;
      }

      if (_isPreamble(line)) continue;

      final card = _cardOf(line, section);
      if (card == null) continue;

      cards.add(card);
      blankLineSwitchesSection = true;
    }

    return ParsedDecklist(cards);
  }

  static bool _isPreamble(String line) {
    final lower = line.toLowerCase();
    return _ignoredHeaders.contains(lower) ||
        _ignoredPrefixes.any(lower.startsWith);
  }

  static DeckSection? _headerOf(String line) {
    // Headers sometimes carry a count, as in "Sideboard (15)" or "Deck: 60".
    final normalised = line
        .toLowerCase()
        .replaceAll(RegExp(r'[:\-]+$'), '')
        .replaceAll(RegExp(r'\s*\(\d+\)\s*$'), '')
        .replaceAll(RegExp(r'\s*\d+\s*$'), '')
        .trim();

    return _sectionHeaders[normalised];
  }

  static ParsedCard? _cardOf(String line, DeckSection section) {
    final match = _cardLine.firstMatch(line);

    final quantity = match == null ? 1 : int.parse(match.group(1)!);
    final rawName = match == null ? line : match.group(2)!;
    final name = rawName.replaceFirst(_setSuffix, '').trim();

    if (name.isEmpty || quantity <= 0) return null;

    return ParsedCard(section: section, name: name, quantity: quantity);
  }
}
