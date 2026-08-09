import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:tcg_tracker/data/db/app_database.dart';

/// The schema exactly as version 1 shipped it: no deck photo, no deck_cards.
///
/// Hand-written on purpose. The developer's own browser already holds a
/// version 1 database, so this upgrade path runs for real the next time the app
/// is opened, and it is the one piece of the release that cannot be retried.
const _schemaV1 = [
  '''
CREATE TABLE games (
  id TEXT NOT NULL PRIMARY KEY,
  name TEXT NOT NULL,
  sort_order INTEGER NOT NULL DEFAULT 0
)''',
  '''
CREATE TABLE formats (
  id TEXT NOT NULL PRIMARY KEY,
  game_id TEXT NOT NULL REFERENCES games (id),
  name TEXT NOT NULL,
  is_system INTEGER NOT NULL DEFAULT 0,
  is_active INTEGER NOT NULL DEFAULT 1,
  sort_order INTEGER NOT NULL DEFAULT 0
)''',
  '''
CREATE TABLE decks (
  id TEXT NOT NULL PRIMARY KEY,
  game_id TEXT NOT NULL REFERENCES games (id),
  format_id TEXT NOT NULL REFERENCES formats (id),
  name TEXT NOT NULL,
  archetype TEXT NOT NULL,
  colors TEXT,
  notes TEXT,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)''',
  '''
CREATE TABLE opponent_archetypes (
  id TEXT NOT NULL PRIMARY KEY,
  game_id TEXT NOT NULL REFERENCES games (id),
  format_id TEXT NOT NULL REFERENCES formats (id),
  name TEXT NOT NULL,
  times_faced INTEGER NOT NULL DEFAULT 0
)''',
  '''
CREATE TABLE tournaments (
  id TEXT NOT NULL PRIMARY KEY,
  game_id TEXT NOT NULL REFERENCES games (id),
  format_id TEXT NOT NULL REFERENCES formats (id),
  deck_id TEXT NOT NULL REFERENCES decks (id),
  name TEXT NOT NULL,
  date TEXT NOT NULL,
  event_type TEXT NOT NULL,
  participant_count INTEGER,
  rounds_planned INTEGER NOT NULL,
  has_top_cut INTEGER NOT NULL DEFAULT 0,
  top_cut_size INTEGER,
  final_standing INTEGER,
  status TEXT NOT NULL,
  notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL
)''',
  '''
CREATE TABLE matches (
  id TEXT NOT NULL PRIMARY KEY,
  tournament_id TEXT REFERENCES tournaments (id),
  game_id TEXT NOT NULL REFERENCES games (id),
  format_id TEXT NOT NULL REFERENCES formats (id),
  deck_id TEXT NOT NULL REFERENCES decks (id),
  round_number INTEGER,
  is_top_cut INTEGER NOT NULL DEFAULT 0,
  opponent_name TEXT,
  opponent_archetype_id TEXT REFERENCES opponent_archetypes (id),
  on_the_play INTEGER,
  games_won INTEGER NOT NULL DEFAULT 0,
  games_lost INTEGER NOT NULL DEFAULT 0,
  games_drawn INTEGER NOT NULL DEFAULT 0,
  result TEXT NOT NULL,
  played_at TEXT NOT NULL,
  notes TEXT
)''',
];

void main() {
  /// Opens a database that already holds version 1 data, so opening it with the
  /// current app runs the real upgrade.
  AppDatabase openUpgradedFromV1() {
    return AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (Database raw) {
          for (final statement in _schemaV1) {
            raw.execute(statement);
          }

          raw.execute(
            "INSERT INTO games (id, name, sort_order) VALUES ('mtg', 'Magic: The Gathering', 1)",
          );
          raw.execute(
            "INSERT INTO formats (id, game_id, name, is_system, is_active, sort_order) "
            "VALUES ('mtg-modern', 'mtg', 'Modern', 1, 1, 1)",
          );
          raw.execute(
            "INSERT INTO decks (id, game_id, format_id, name, archetype, colors, is_active, created_at, updated_at) "
            "VALUES ('deck-1', 'mtg', 'mtg-modern', 'Izzet Prowess', 'Izzet Prowess', 'UR', 1, "
            "'2026-01-01T00:00:00.000', '2026-01-01T00:00:00.000')",
          );

          raw.userVersion = 1;
        },
      ),
    );
  }

  test(
    'upgrading from version 1 keeps the decks that were already there',
    () async {
      final db = openUpgradedFromV1();
      addTearDown(db.close);

      final deck = await db.select(db.decks).getSingle();

      expect(deck.name, 'Izzet Prowess');
      expect(deck.colors, 'UR');
      expect(deck.photo, isNull, reason: 'the new column starts empty');
    },
  );

  test('upgrading from version 1 adds the decklist table', () async {
    final db = openUpgradedFromV1();
    addTearDown(db.close);

    expect(await db.select(db.deckCards).get(), isEmpty);
  });

  test('a database that lies about its version is repaired anyway', () async {
    // The state a real browser ended up in: version 1 tables, stamped as
    // version 2, so no migration would ever run on it again.
    final db = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (Database raw) {
          for (final statement in _schemaV1) {
            raw.execute(statement);
          }
          raw.userVersion = 2;
        },
      ),
    );
    addTearDown(db.close);

    await db
        .into(db.decks)
        .insert(
          DecksCompanion.insert(
            id: 'deck-1',
            gameId: 'ygo',
            formatId: 'ygo-advanced',
            name: 'Snake-Eye',
            archetype: 'Snake-Eye',
            photo: Value(Uint8List.fromList([1, 2, 3])),
            createdAt: DateTime(2026),
            updatedAt: DateTime(2026),
          ),
        );

    expect(
      (await db.select(db.decks).getSingle()).photo,
      isNotNull,
      reason: 'the missing column was added at open, so the insert works',
    );
    expect(
      await db.select(db.deckCards).get(),
      isEmpty,
      reason: 'the missing table was created too',
    );
  });

  /// A version 2 database: version 1 plus the deck photo and the decklist
  /// table, stamped as 2, with whatever [extra] statements the test needs.
  AppDatabase openUpgradedFromV2(List<String> extra) {
    return AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (Database raw) {
          for (final statement in _schemaV1) {
            raw.execute(statement);
          }

          raw.execute('ALTER TABLE decks ADD COLUMN photo BLOB');
          raw.execute('ALTER TABLE decks ADD COLUMN photo_mime_type TEXT');
          raw.execute('''
CREATE TABLE deck_cards (
  id TEXT NOT NULL PRIMARY KEY,
  deck_id TEXT NOT NULL REFERENCES decks (id) ON DELETE CASCADE,
  section TEXT NOT NULL,
  name TEXT NOT NULL,
  quantity INTEGER NOT NULL DEFAULT 1,
  sort_order INTEGER NOT NULL DEFAULT 0
)''');

          raw.execute(
            "INSERT INTO games (id, name, sort_order) VALUES ('ygo', 'Yu-Gi-Oh!', 0)",
          );
          raw.execute(
            "INSERT INTO formats (id, game_id, name, is_system, is_active, sort_order) "
            "VALUES ('ygo-advanced', 'ygo', 'Avanzato', 1, 1, 0)",
          );

          for (final statement in extra) {
            raw.execute(statement);
          }

          raw.userVersion = 2;
        },
      ),
    );
  }

  test('upgrading from version 2 brings the archetype list with it', () async {
    final db = openUpgradedFromV2(const []);
    addTearDown(db.close);

    final names = (await db.select(db.opponentArchetypes).get()).map(
      (row) => row.name,
    );

    expect(names, contains('Snake-Eye Fire King'));
    expect(names, contains('Izzet Prowess'));
  });

  test('the upgrade drops an unused archetype but keeps a played one', () async {
    final db = openUpgradedFromV2(const [
      "INSERT INTO opponent_archetypes (id, game_id, format_id, name, times_faced) "
          "VALUES ('unused', 'ygo', 'ygo-advanced', 'Typed once and forgotten', 0)",
      "INSERT INTO opponent_archetypes (id, game_id, format_id, name, times_faced) "
          "VALUES ('played', 'ygo', 'ygo-advanced', 'Deck I actually faced', 1)",
      "INSERT INTO decks (id, game_id, format_id, name, archetype, is_active, created_at, updated_at) "
          "VALUES ('deck-1', 'ygo', 'ygo-advanced', 'Snake-Eye', 'Snake-Eye', 1, "
          "'2026-01-01T00:00:00.000', '2026-01-01T00:00:00.000')",
      "INSERT INTO matches (id, game_id, format_id, deck_id, is_top_cut, opponent_archetype_id, "
          "games_won, games_lost, games_drawn, result, played_at) "
          "VALUES ('match-1', 'ygo', 'ygo-advanced', 'deck-1', 0, 'played', 2, 0, 0, 'win', "
          "'2026-01-01T00:00:00.000')",
    ]);
    addTearDown(db.close);

    final ids = (await db.select(db.opponentArchetypes).get()).map((r) => r.id);

    expect(ids, isNot(contains('unused')));
    expect(
      ids,
      contains('played'),
      reason:
          'a recorded round names the deck it was played against, and no '
          'list update gets to rewrite that',
    );
  });

  test('upgrading from version 1 tops the catalogue back up', () async {
    final db = openUpgradedFromV1();
    addTearDown(db.close);

    final games = await db.select(db.games).get();
    final formats = await db.select(db.formats).get();

    expect(
      games.map((g) => g.id),
      containsAll(['mtg', 'ygo']),
      reason: 'the seed runs on upgrade, so a missing game is filled in',
    );
    expect(formats, hasLength(6));
  });

  test('upgrading to version 4 protects the games that were already '
      'there', () async {
    // Magic was inserted by the version 1 setup, before the column existed:
    // it has to come out of the upgrade flagged, not merely re-seeded.
    final db = openUpgradedFromV1();
    addTearDown(db.close);

    final games = await db.select(db.games).get();

    expect(
      games.every((game) => game.isSystem),
      isTrue,
      reason: 'a shipped game arriving deletable is a game the user can lose',
    );
    expect(games.every((game) => game.isActive), isTrue);
  });

  test('a database that lies about its version still protects its '
      'games', () async {
    // Version 1 tables stamped as version 3: the migration that adds
    // is_system never runs, so only the repair at open can set it.
    final db = AppDatabase.forTesting(
      NativeDatabase.memory(
        setup: (Database raw) {
          for (final statement in _schemaV1) {
            raw.execute(statement);
          }
          raw.execute(
            "INSERT INTO games (id, name, sort_order) "
            "VALUES ('ygo', 'Yu-Gi-Oh!', 0)",
          );
          raw.userVersion = 3;
        },
      ),
    );
    addTearDown(db.close);

    final games = await db.select(db.games).get();

    expect(games.every((game) => game.isSystem), isTrue);
  });
}
