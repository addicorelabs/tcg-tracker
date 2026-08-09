import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

// Imported for the generated part file, which resolves the enum columns
// against this library's imports rather than against tables.dart.
import '../models/enums.dart';
import 'seed.dart';
import 'tables.dart';

part 'app_database.g.dart';

@DriftDatabase(
  tables: [
    Games,
    Formats,
    Decks,
    DeckCards,
    OpponentArchetypes,
    Tournaments,
    Matches,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Used by tests to run against an in-memory database.
  AppDatabase.forTesting(super.executor);

  /// 2: deck photos and imported decklists.
  /// 3: the shipped list of opponent archetypes. No table changed — the
  ///    version moved so the one-shot data migration has somewhere to hang.
  /// 4: games the user creates, so `games` gained the same `is_system` and
  ///    `is_active` flags `formats` already had.
  @override
  int get schemaVersion => 4;

  /// Dates are stored as ISO-8601 text rather than as unix timestamps: it keeps
  /// them readable in an export and maps straight onto a Postgres `timestamp`
  /// in the cloud snapshot.
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onCreate: (migrator) async {
        await migrator.createAll();
        await Seed.apply(this);
        await Seed.applyArchetypes(this);
      },
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.addColumn(decks, decks.photo);
          await migrator.addColumn(decks, decks.photoMimeType);
          await migrator.createTable(deckCards);
        }

        if (from < 3) {
          // Data, not schema: the archetype list arrives once and is then the
          // user's to edit. It is not re-applied on later opens, so deleting a
          // default deletes it for good.
          await Seed.applyArchetypes(this);
        }

        if (from < 4) {
          await migrator.addColumn(games, games.isSystem);
          await migrator.addColumn(games, games.isActive);
          await Seed.markSystemGames(this);
        }

        // Re-applying the seed on every upgrade is how formats added in a later
        // version reach devices installed before that version existed. Existing
        // rows are left untouched.
        await Seed.apply(this);
      },
      beforeOpen: (details) async {
        // SQLite ignores foreign keys unless asked, and this schema leans on
        // them to stop matches pointing at decks that no longer exist.
        await customStatement('PRAGMA foreign_keys = ON');
        await _repairSchema();
      },
    );
  }

  /// Adds anything the schema declares and the open database does not have.
  ///
  /// Migrations key off `user_version`, so a database whose version says it is
  /// up to date is never touched again — even when it is not. That happened for
  /// real: a browser ended up on version 2 with a version 1 `decks` table, and
  /// every deck insert failed with "table decks has no column named photo",
  /// permanently, with no way out from inside the app.
  ///
  /// Checking the tables themselves costs one `PRAGMA` per table at startup and
  /// removes a whole class of unrecoverable state. It only ever adds: nothing
  /// here drops or rewrites what is already stored.
  Future<void> _repairSchema() async {
    final migrator = createMigrator();

    for (final table in allTables) {
      final columns = await customSelect(
        'PRAGMA table_info(${table.actualTableName})',
      ).get();

      if (columns.isEmpty) {
        await migrator.createTable(table);
        continue;
      }

      final present = {for (final row in columns) row.read<String>('name')};
      var added = false;

      for (final column in table.$columns) {
        if (!present.contains(column.name)) {
          await migrator.addColumn(table, column);
          added = true;
        }
      }

      // A column arrives with its declared default, and `is_system` defaults to
      // false. Getting here means the migration that should have set it never
      // ran, so without this the two shipped games would come back deletable.
      if (added && table.actualTableName == games.actualTableName) {
        await Seed.markSystemGames(this);
      }
    }

    // A table that was missing entirely takes its seed rows with it.
    await Seed.apply(this);
  }
}

QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'tcg_tracker',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
