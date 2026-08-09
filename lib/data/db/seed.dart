import 'package:drift/drift.dart';

import 'app_database.dart';
import 'archetype_seed.dart';

/// Games and formats the app ships with.
///
/// Slugs, not uuids: these rows are the same on every device, so a readable and
/// stable id keeps them easy to reference and safe to sync.
abstract final class Seed {
  static const yugiohId = 'ygo';
  static const magicId = 'mtg';

  static const games = [
    (id: yugiohId, name: 'Yu-Gi-Oh!', sortOrder: 0),
    (id: magicId, name: 'Magic: The Gathering', sortOrder: 1),
  ];

  /// The Yu-Gi-Oh! "Advanced" format is the one name shown translated, through
  /// a dedicated l10n key. Every other format name is used as written here.
  static const formats = [
    (id: 'ygo-advanced', gameId: yugiohId, name: 'Avanzato', sortOrder: 0),
    (id: 'ygo-edison', gameId: yugiohId, name: 'Edison', sortOrder: 1),
    (id: 'mtg-standard', gameId: magicId, name: 'Standard', sortOrder: 0),
    (id: 'mtg-modern', gameId: magicId, name: 'Modern', sortOrder: 1),
    (id: 'mtg-pauper', gameId: magicId, name: 'Pauper', sortOrder: 2),
    (id: 'mtg-legacy', gameId: magicId, name: 'Legacy', sortOrder: 3),
  ];

  /// Inserts the seed rows, leaving alone anything that is already there.
  ///
  /// Safe to run on every migration: it is how formats added in a future
  /// version reach devices that were installed before that version existed.
  ///
  /// It reads before it writes, and writes nothing when there is nothing to
  /// add. That is not an optimisation for its own sake: this runs on every
  /// open, and a write — even one every row of which is ignored — still tells
  /// drift the tables changed, which the sync would read as work to upload.
  static Future<void> apply(AppDatabase db) async {
    final knownGames = {
      for (final row in await db.select(db.games).get()) row.id,
    };
    final knownFormats = {
      for (final row in await db.select(db.formats).get()) row.id,
    };

    final missingGames = [
      for (final game in games)
        if (!knownGames.contains(game.id))
          GamesCompanion.insert(
            id: game.id,
            name: game.name,
            isSystem: const Value(true),
            sortOrder: Value(game.sortOrder),
          ),
    ];

    final missingFormats = [
      for (final format in formats)
        if (!knownFormats.contains(format.id))
          FormatsCompanion.insert(
            id: format.id,
            gameId: format.gameId,
            name: format.name,
            isSystem: const Value(true),
            sortOrder: Value(format.sortOrder),
          ),
    ];

    if (missingGames.isEmpty && missingFormats.isEmpty) return;

    await db.batch((batch) {
      batch.insertAll(db.games, missingGames, mode: InsertMode.insertOrIgnore);
      batch.insertAll(
        db.formats,
        missingFormats,
        mode: InsertMode.insertOrIgnore,
      );
    });
  }

  /// Flags the shipped games as system, which is what protects them from
  /// deletion.
  ///
  /// Separate from [apply] because it is a repair, not a seed: it exists for
  /// the rows that were inserted before the column did, and for a database
  /// whose `user_version` skipped the migration that added it.
  static Future<void> markSystemGames(AppDatabase db) async {
    await db.customUpdate(
      'UPDATE games SET is_system = 1 WHERE id IN (?, ?) AND is_system = 0',
      variables: [Variable<String>(yugiohId), Variable<String>(magicId)],
      updates: {db.games},
    );
  }

  /// Puts the shipped archetype list in place of whatever is there.
  ///
  /// Deliberately **not** part of [apply], which runs on every open: these rows
  /// are meant to be deletable, and a list that came back after being deleted
  /// would be worse than no list at all. This runs when the database is created
  /// and once on the upgrade that introduced it.
  ///
  /// "In place of" has one exception, and it is not negotiable: an archetype a
  /// match points at is never deleted. Doing so would break the foreign key
  /// and, more to the point, would rewrite history — that round really was
  /// played against that deck, whatever the current list says.
  static Future<void> applyArchetypes(AppDatabase db) async {
    await db.transaction(() async {
      await db.customUpdate(
        'DELETE FROM opponent_archetypes WHERE id NOT IN '
        '(SELECT opponent_archetype_id FROM matches '
        ' WHERE opponent_archetype_id IS NOT NULL)',
        updates: {db.opponentArchetypes},
      );

      // Whatever survived the delete is in use. Its name is already taken, so
      // the default of the same name is skipped rather than added beside it.
      final survivors = await db.select(db.opponentArchetypes).get();
      final taken = {
        for (final row in survivors)
          '${row.formatId}/${row.name.toLowerCase()}',
      };

      final rows = <OpponentArchetypesCompanion>[];

      for (final entry in ArchetypeSeed.byFormat.entries) {
        final formatId = entry.key;

        for (final name in entry.value) {
          if (taken.contains('$formatId/${name.toLowerCase()}')) continue;

          rows.add(
            OpponentArchetypesCompanion.insert(
              id: ArchetypeSeed.idFor(formatId, name),
              gameId: ArchetypeSeed.gameOf(formatId),
              formatId: formatId,
              name: name,
            ),
          );
        }
      }

      await db.batch(
        (batch) => batch.insertAll(
          db.opponentArchetypes,
          rows,
          mode: InsertMode.insertOrIgnore,
        ),
      );
    });
  }
}
