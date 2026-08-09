import 'package:flutter_test/flutter_test.dart';
import 'package:tcg_tracker/core/decklist/decklist_parser.dart';
import 'package:tcg_tracker/data/models/enums.dart';

void main() {
  ParsedDecklist parse(String text) => DecklistParser.parse(text);

  test('reads the Arena style list with explicit headers', () {
    final list = parse('''
Deck
4 Lightning Bolt
4 Monastery Swiftspear
12 Mountain

Sideboard
2 Blood Moon
''');

    expect(list.countIn(DeckSection.main), 20);
    expect(list.countIn(DeckSection.side), 2);
    expect(list.section(DeckSection.main).first.name, 'Lightning Bolt');
  });

  test('a blank line splits main from sideboard when there are no headers', () {
    final list = parse('''
4 Lightning Bolt
16 Mountain

3 Blood Moon
''');

    expect(list.countIn(DeckSection.main), 20);
    expect(list.countIn(DeckSection.side), 3);
  });

  test('an explicit header beats the blank-line rule', () {
    final list = parse('''
Main deck
4 Lightning Bolt

16 Mountain

Sideboard
3 Blood Moon
''');

    expect(
      list.countIn(DeckSection.main),
      20,
      reason: 'blank lines inside a declared section must not switch it',
    );
    expect(list.countIn(DeckSection.side), 3);
  });

  test('handles the Yu-Gi-Oh! extra and side deck', () {
    final list = parse('''
Main Deck
3 Snake-Eye Ash
1 Ash Blossom & Joyous Spring

Extra Deck
1 Salamangreat Raging Phoenix

Side Deck
2 Droll & Lock Bird
''');

    expect(list.countIn(DeckSection.main), 4);
    expect(list.countIn(DeckSection.extra), 1);
    expect(list.countIn(DeckSection.side), 2);
    expect(
      list.section(DeckSection.main).last.name,
      'Ash Blossom & Joyous Spring',
      reason: 'card names are kept exactly as written',
    );
  });

  test('accepts the 4x form and headers carrying a count', () {
    final list = parse('''
Deck (60)
4x Lightning Bolt
Sideboard (15)
2x Blood Moon
''');

    expect(list.countIn(DeckSection.main), 4);
    expect(list.countIn(DeckSection.side), 2);
  });

  test('strips the set and collector number', () {
    final list = parse('4 Lightning Bolt (M11) 149');

    expect(list.section(DeckSection.main).single.name, 'Lightning Bolt');
  });

  test('ignores comments and exporter preamble', () {
    final list = parse('''
// Modern burn
About
Name Izzet Prowess
# generated 2026-08-08
Deck
4 Lightning Bolt
''');

    expect(list.cards, hasLength(1));
    expect(list.totalCards, 4);
  });

  test('a line without a quantity counts as one copy', () {
    final list = parse('''
Commander
Atraxa, Praetors' Voice
''');

    final commander = list.section(DeckSection.commander).single;
    expect(commander.name, "Atraxa, Praetors' Voice");
    expect(commander.quantity, 1);
  });

  test('an empty or headers-only file yields nothing', () {
    expect(parse('').isEmpty, isTrue);
    expect(parse('Deck\n\nSideboard\n').isEmpty, isTrue);
  });

  test('the order of the source file is preserved within a section', () {
    final list = parse('''
2 Zealous Conscripts
4 Lightning Bolt
1 Anger
''');

    expect(list.section(DeckSection.main).map((c) => c.name), [
      'Zealous Conscripts',
      'Lightning Bolt',
      'Anger',
    ]);
  });
}
