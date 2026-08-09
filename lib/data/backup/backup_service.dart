import 'dart:convert';
import 'dart:typed_data';

import 'package:drift/drift.dart' show DataClass, ValueSerializer;
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../db/app_database.dart';
import '../db/database_provider.dart';

Type _typeOf<T>() => T;

/// Encodes the two column types that plain JSON cannot carry.
///
/// Dates become ISO-8601 text rather than millisecond timestamps: drift's
/// default encoding would quietly shave the microseconds off every row on the
/// way through a backup, and text keeps the file readable besides. Deck photos
/// become base64, since a byte array has no JSON representation at all.
class BackupValueSerializer extends ValueSerializer {
  const BackupValueSerializer();

  static const _defaults = ValueSerializer.defaults();
  static final _dateTypes = {_typeOf<DateTime>(), _typeOf<DateTime?>()};
  static final _blobTypes = {_typeOf<Uint8List>(), _typeOf<Uint8List?>()};

  @override
  T fromJson<T>(dynamic json) {
    if (json is String) {
      if (_dateTypes.contains(T)) return DateTime.parse(json) as T;
      if (_blobTypes.contains(T)) return base64Decode(json) as T;
    }
    return _defaults.fromJson<T>(json);
  }

  @override
  dynamic toJson<T>(T value) {
    if (value is DateTime) return value.toIso8601String();
    if (value is Uint8List) return base64Encode(value);
    return _defaults.toJson<T>(value);
  }
}

/// Thrown when a file does not look like a backup this app can restore.
class BackupFormatException implements Exception {
  BackupFormatException(this.message);

  final String message;

  @override
  String toString() => 'BackupFormatException: $message';
}

/// Full export and restore of the local database as a single JSON document.
///
/// On iOS the browser may drop a site's local storage after a stretch of
/// inactivity, so this is not a convenience feature: it is what stands between
/// the user and losing their tournament history on a build with no cloud, or
/// on one whose account has never been signed into.
///
/// The same document is what the Supabase sync uploads, so the backup format
/// and the sync format are one thing with one version, not two that could
/// drift apart.
class BackupService {
  BackupService(this._db);

  final AppDatabase _db;

  /// Bumped only when the shape of the document changes in a way older
  /// versions of the app cannot read.
  /// 2: deck photos and imported decklists. Files written by version 1 still
  /// restore, they simply carry neither.
  static const formatVersion = 2;
  static const _appMarker = 'tcg-tracker';
  static const _serializer = BackupValueSerializer();

  Future<Map<String, dynamic>> exportToJson() async {
    Future<List<Map<String, dynamic>>> rowsOf<T extends DataClass>(
      Future<List<T>> Function() select,
    ) async {
      return [
        for (final row in await select()) row.toJson(serializer: _serializer),
      ];
    }

    return {
      'app': _appMarker,
      'formatVersion': formatVersion,
      'schemaVersion': _db.schemaVersion,
      'exportedAt': DateTime.now().toIso8601String(),
      'tables': {
        'games': await rowsOf(() => _db.select(_db.games).get()),
        'formats': await rowsOf(() => _db.select(_db.formats).get()),
        'decks': await rowsOf(() => _db.select(_db.decks).get()),
        'deck_cards': await rowsOf(() => _db.select(_db.deckCards).get()),
        'opponent_archetypes': await rowsOf(
          () => _db.select(_db.opponentArchetypes).get(),
        ),
        'tournaments': await rowsOf(() => _db.select(_db.tournaments).get()),
        'matches': await rowsOf(() => _db.select(_db.matches).get()),
      },
    };
  }

  Future<String> exportToString() async {
    return const JsonEncoder.withIndent('  ').convert(await exportToJson());
  }

  /// Suggested file name, dated so successive exports do not overwrite.
  String suggestedFileName([DateTime? now]) {
    final date = (now ?? DateTime.now()).toIso8601String().split('T').first;
    return 'tcg-tracker-$date.json';
  }

  /// Replaces the entire local database with the contents of [json].
  ///
  /// A restore is exact, not a merge: anything currently stored is discarded.
  /// The whole thing runs in one transaction, so a malformed file leaves the
  /// existing data untouched rather than half-overwritten.
  ///
  /// Tables are emptied children-first and refilled parents-first, so foreign
  /// keys hold at every step.
  Future<void> importFromJson(Map<String, dynamic> json) async {
    final tables = _validate(json);

    final games = _parse(tables, 'games', Game.fromJson);
    final formats = _parse(tables, 'formats', Format.fromJson);
    final decks = _parse(tables, 'decks', Deck.fromJson);
    final deckCards = _parse(tables, 'deck_cards', DeckCard.fromJson);
    final archetypes = _parse(
      tables,
      'opponent_archetypes',
      OpponentArchetype.fromJson,
    );
    final tournaments = _parse(tables, 'tournaments', Tournament.fromJson);
    final matches = _parse(tables, 'matches', Match.fromJson);

    await _db.transaction(() async {
      await _db.delete(_db.matches).go();
      await _db.delete(_db.tournaments).go();
      await _db.delete(_db.opponentArchetypes).go();
      await _db.delete(_db.deckCards).go();
      await _db.delete(_db.decks).go();
      await _db.delete(_db.formats).go();
      await _db.delete(_db.games).go();

      await _db.batch((batch) {
        batch.insertAll(_db.games, games);
        batch.insertAll(_db.formats, formats);
        batch.insertAll(_db.decks, decks);
        batch.insertAll(_db.deckCards, deckCards);
        batch.insertAll(_db.opponentArchetypes, archetypes);
        batch.insertAll(_db.tournaments, tournaments);
        batch.insertAll(_db.matches, matches);
      });
    });
  }

  Future<void> importFromString(String content) {
    final Object? decoded;
    try {
      decoded = jsonDecode(content);
    } on FormatException catch (error) {
      throw BackupFormatException(
        'The file is not valid JSON: ${error.message}',
      );
    }

    if (decoded is! Map<String, dynamic>) {
      throw BackupFormatException('The file does not contain a backup object');
    }

    return importFromJson(decoded);
  }

  Map<String, dynamic> _validate(Map<String, dynamic> json) {
    if (json['app'] != _appMarker) {
      throw BackupFormatException('This file was not exported by TCG Tracker');
    }

    final version = json['formatVersion'];
    if (version is! int || version > formatVersion) {
      throw BackupFormatException(
        'Backup format $version is newer than this app can read',
      );
    }

    final tables = json['tables'];
    if (tables is! Map<String, dynamic>) {
      throw BackupFormatException('The backup contains no tables');
    }

    return tables;
  }

  List<T> _parse<T>(
    Map<String, dynamic> tables,
    String name,
    T Function(Map<String, dynamic>, {ValueSerializer? serializer}) fromJson,
  ) {
    final rows = tables[name];
    if (rows == null) return const [];

    if (rows is! List) {
      throw BackupFormatException('"$name" is not a list of rows');
    }

    try {
      return [
        for (final row in rows)
          if (row is Map<String, dynamic>)
            fromJson(row, serializer: _serializer)
          else
            throw BackupFormatException('A row in "$name" is not an object'),
      ];
    } on BackupFormatException {
      rethrow;
    } catch (error) {
      throw BackupFormatException('Could not read "$name": $error');
    }
  }
}

final backupServiceProvider = Provider<BackupService>((ref) {
  return BackupService(ref.watch(appDatabaseProvider));
});
