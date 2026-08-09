// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $GamesTable extends Games with TableInfo<$GamesTable, Game> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GamesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    isSystem,
    isActive,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'games';
  @override
  VerificationContext validateIntegrity(
    Insertable<Game> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Game map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Game(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $GamesTable createAlias(String alias) {
    return $GamesTable(attachedDatabase, alias);
  }
}

class Game extends DataClass implements Insertable<Game> {
  final String id;
  final String name;

  /// Ships with the app, and therefore cannot be deleted.
  final bool isSystem;
  final bool isActive;
  final int sortOrder;
  const Game({
    required this.id,
    required this.name,
    required this.isSystem,
    required this.isActive,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_system'] = Variable<bool>(isSystem);
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  GamesCompanion toCompanion(bool nullToAbsent) {
    return GamesCompanion(
      id: Value(id),
      name: Value(name),
      isSystem: Value(isSystem),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory Game.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Game(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isSystem': serializer.toJson<bool>(isSystem),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Game copyWith({
    String? id,
    String? name,
    bool? isSystem,
    bool? isActive,
    int? sortOrder,
  }) => Game(
    id: id ?? this.id,
    name: name ?? this.name,
    isSystem: isSystem ?? this.isSystem,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Game copyWithCompanion(GamesCompanion data) {
    return Game(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Game(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isSystem: $isSystem, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, isSystem, isActive, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Game &&
          other.id == this.id &&
          other.name == this.name &&
          other.isSystem == this.isSystem &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class GamesCompanion extends UpdateCompanion<Game> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isSystem;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const GamesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GamesCompanion.insert({
    required String id,
    required String name,
    this.isSystem = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       name = Value(name);
  static Insertable<Game> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isSystem,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isSystem != null) 'is_system': isSystem,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GamesCompanion copyWith({
    Value<String>? id,
    Value<String>? name,
    Value<bool>? isSystem,
    Value<bool>? isActive,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return GamesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isSystem: isSystem ?? this.isSystem,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GamesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isSystem: $isSystem, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FormatsTable extends Formats with TableInfo<$FormatsTable, Format> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FormatsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _isSystemMeta = const VerificationMeta(
    'isSystem',
  );
  @override
  late final GeneratedColumn<bool> isSystem = GeneratedColumn<bool>(
    'is_system',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_system" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    name,
    isSystem,
    isActive,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'formats';
  @override
  VerificationContext validateIntegrity(
    Insertable<Format> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_system')) {
      context.handle(
        _isSystemMeta,
        isSystem.isAcceptableOrUnknown(data['is_system']!, _isSystemMeta),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Format map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Format(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      isSystem: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_system'],
      )!,
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $FormatsTable createAlias(String alias) {
    return $FormatsTable(attachedDatabase, alias);
  }
}

class Format extends DataClass implements Insertable<Format> {
  final String id;
  final String gameId;
  final String name;
  final bool isSystem;
  final bool isActive;
  final int sortOrder;
  const Format({
    required this.id,
    required this.gameId,
    required this.name,
    required this.isSystem,
    required this.isActive,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['game_id'] = Variable<String>(gameId);
    map['name'] = Variable<String>(name);
    map['is_system'] = Variable<bool>(isSystem);
    map['is_active'] = Variable<bool>(isActive);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  FormatsCompanion toCompanion(bool nullToAbsent) {
    return FormatsCompanion(
      id: Value(id),
      gameId: Value(gameId),
      name: Value(name),
      isSystem: Value(isSystem),
      isActive: Value(isActive),
      sortOrder: Value(sortOrder),
    );
  }

  factory Format.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Format(
      id: serializer.fromJson<String>(json['id']),
      gameId: serializer.fromJson<String>(json['gameId']),
      name: serializer.fromJson<String>(json['name']),
      isSystem: serializer.fromJson<bool>(json['isSystem']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gameId': serializer.toJson<String>(gameId),
      'name': serializer.toJson<String>(name),
      'isSystem': serializer.toJson<bool>(isSystem),
      'isActive': serializer.toJson<bool>(isActive),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  Format copyWith({
    String? id,
    String? gameId,
    String? name,
    bool? isSystem,
    bool? isActive,
    int? sortOrder,
  }) => Format(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    name: name ?? this.name,
    isSystem: isSystem ?? this.isSystem,
    isActive: isActive ?? this.isActive,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  Format copyWithCompanion(FormatsCompanion data) {
    return Format(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      name: data.name.present ? data.name.value : this.name,
      isSystem: data.isSystem.present ? data.isSystem.value : this.isSystem,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Format(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('name: $name, ')
          ..write('isSystem: $isSystem, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, gameId, name, isSystem, isActive, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Format &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.name == this.name &&
          other.isSystem == this.isSystem &&
          other.isActive == this.isActive &&
          other.sortOrder == this.sortOrder);
}

class FormatsCompanion extends UpdateCompanion<Format> {
  final Value<String> id;
  final Value<String> gameId;
  final Value<String> name;
  final Value<bool> isSystem;
  final Value<bool> isActive;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const FormatsCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.name = const Value.absent(),
    this.isSystem = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FormatsCompanion.insert({
    required String id,
    required String gameId,
    required String name,
    this.isSystem = const Value.absent(),
    this.isActive = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gameId = Value(gameId),
       name = Value(name);
  static Insertable<Format> custom({
    Expression<String>? id,
    Expression<String>? gameId,
    Expression<String>? name,
    Expression<bool>? isSystem,
    Expression<bool>? isActive,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (name != null) 'name': name,
      if (isSystem != null) 'is_system': isSystem,
      if (isActive != null) 'is_active': isActive,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FormatsCompanion copyWith({
    Value<String>? id,
    Value<String>? gameId,
    Value<String>? name,
    Value<bool>? isSystem,
    Value<bool>? isActive,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return FormatsCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      name: name ?? this.name,
      isSystem: isSystem ?? this.isSystem,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isSystem.present) {
      map['is_system'] = Variable<bool>(isSystem.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FormatsCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('name: $name, ')
          ..write('isSystem: $isSystem, ')
          ..write('isActive: $isActive, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DecksTable extends Decks with TableInfo<$DecksTable, Deck> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DecksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id)',
    ),
  );
  static const VerificationMeta _formatIdMeta = const VerificationMeta(
    'formatId',
  );
  @override
  late final GeneratedColumn<String> formatId = GeneratedColumn<String>(
    'format_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES formats (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _archetypeMeta = const VerificationMeta(
    'archetype',
  );
  @override
  late final GeneratedColumn<String> archetype = GeneratedColumn<String>(
    'archetype',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _colorsMeta = const VerificationMeta('colors');
  @override
  late final GeneratedColumn<String> colors = GeneratedColumn<String>(
    'colors',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoMeta = const VerificationMeta('photo');
  @override
  late final GeneratedColumn<Uint8List> photo = GeneratedColumn<Uint8List>(
    'photo',
    aliasedName,
    true,
    type: DriftSqlType.blob,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _photoMimeTypeMeta = const VerificationMeta(
    'photoMimeType',
  );
  @override
  late final GeneratedColumn<String> photoMimeType = GeneratedColumn<String>(
    'photo_mime_type',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isActiveMeta = const VerificationMeta(
    'isActive',
  );
  @override
  late final GeneratedColumn<bool> isActive = GeneratedColumn<bool>(
    'is_active',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_active" IN (0, 1))',
    ),
    defaultValue: const Constant(true),
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    formatId,
    name,
    archetype,
    colors,
    notes,
    photo,
    photoMimeType,
    isActive,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'decks';
  @override
  VerificationContext validateIntegrity(
    Insertable<Deck> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('format_id')) {
      context.handle(
        _formatIdMeta,
        formatId.isAcceptableOrUnknown(data['format_id']!, _formatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_formatIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('archetype')) {
      context.handle(
        _archetypeMeta,
        archetype.isAcceptableOrUnknown(data['archetype']!, _archetypeMeta),
      );
    } else if (isInserting) {
      context.missing(_archetypeMeta);
    }
    if (data.containsKey('colors')) {
      context.handle(
        _colorsMeta,
        colors.isAcceptableOrUnknown(data['colors']!, _colorsMeta),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('photo')) {
      context.handle(
        _photoMeta,
        photo.isAcceptableOrUnknown(data['photo']!, _photoMeta),
      );
    }
    if (data.containsKey('photo_mime_type')) {
      context.handle(
        _photoMimeTypeMeta,
        photoMimeType.isAcceptableOrUnknown(
          data['photo_mime_type']!,
          _photoMimeTypeMeta,
        ),
      );
    }
    if (data.containsKey('is_active')) {
      context.handle(
        _isActiveMeta,
        isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Deck map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Deck(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      formatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      archetype: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}archetype'],
      )!,
      colors: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}colors'],
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      photo: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}photo'],
      ),
      photoMimeType: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}photo_mime_type'],
      ),
      isActive: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_active'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $DecksTable createAlias(String alias) {
    return $DecksTable(attachedDatabase, alias);
  }
}

class Deck extends DataClass implements Insertable<Deck> {
  final String id;
  final String gameId;
  final String formatId;
  final String name;
  final String archetype;

  /// Magic only, e.g. "UR". Null for Yu-Gi-Oh!.
  final String? colors;
  final String? notes;

  /// Photo of the physical deck, already downscaled by the picker.
  ///
  /// Stored inline rather than in a separate blob store so it travels with the
  /// backup: a restore that lost every deck photo would be a poor restore.
  final Uint8List? photo;
  final String? photoMimeType;

  /// Decks are archived rather than deleted, so past tournaments stay readable.
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Deck({
    required this.id,
    required this.gameId,
    required this.formatId,
    required this.name,
    required this.archetype,
    this.colors,
    this.notes,
    this.photo,
    this.photoMimeType,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['game_id'] = Variable<String>(gameId);
    map['format_id'] = Variable<String>(formatId);
    map['name'] = Variable<String>(name);
    map['archetype'] = Variable<String>(archetype);
    if (!nullToAbsent || colors != null) {
      map['colors'] = Variable<String>(colors);
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    if (!nullToAbsent || photo != null) {
      map['photo'] = Variable<Uint8List>(photo);
    }
    if (!nullToAbsent || photoMimeType != null) {
      map['photo_mime_type'] = Variable<String>(photoMimeType);
    }
    map['is_active'] = Variable<bool>(isActive);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  DecksCompanion toCompanion(bool nullToAbsent) {
    return DecksCompanion(
      id: Value(id),
      gameId: Value(gameId),
      formatId: Value(formatId),
      name: Value(name),
      archetype: Value(archetype),
      colors: colors == null && nullToAbsent
          ? const Value.absent()
          : Value(colors),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      photo: photo == null && nullToAbsent
          ? const Value.absent()
          : Value(photo),
      photoMimeType: photoMimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(photoMimeType),
      isActive: Value(isActive),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Deck.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Deck(
      id: serializer.fromJson<String>(json['id']),
      gameId: serializer.fromJson<String>(json['gameId']),
      formatId: serializer.fromJson<String>(json['formatId']),
      name: serializer.fromJson<String>(json['name']),
      archetype: serializer.fromJson<String>(json['archetype']),
      colors: serializer.fromJson<String?>(json['colors']),
      notes: serializer.fromJson<String?>(json['notes']),
      photo: serializer.fromJson<Uint8List?>(json['photo']),
      photoMimeType: serializer.fromJson<String?>(json['photoMimeType']),
      isActive: serializer.fromJson<bool>(json['isActive']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gameId': serializer.toJson<String>(gameId),
      'formatId': serializer.toJson<String>(formatId),
      'name': serializer.toJson<String>(name),
      'archetype': serializer.toJson<String>(archetype),
      'colors': serializer.toJson<String?>(colors),
      'notes': serializer.toJson<String?>(notes),
      'photo': serializer.toJson<Uint8List?>(photo),
      'photoMimeType': serializer.toJson<String?>(photoMimeType),
      'isActive': serializer.toJson<bool>(isActive),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Deck copyWith({
    String? id,
    String? gameId,
    String? formatId,
    String? name,
    String? archetype,
    Value<String?> colors = const Value.absent(),
    Value<String?> notes = const Value.absent(),
    Value<Uint8List?> photo = const Value.absent(),
    Value<String?> photoMimeType = const Value.absent(),
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Deck(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    formatId: formatId ?? this.formatId,
    name: name ?? this.name,
    archetype: archetype ?? this.archetype,
    colors: colors.present ? colors.value : this.colors,
    notes: notes.present ? notes.value : this.notes,
    photo: photo.present ? photo.value : this.photo,
    photoMimeType: photoMimeType.present
        ? photoMimeType.value
        : this.photoMimeType,
    isActive: isActive ?? this.isActive,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Deck copyWithCompanion(DecksCompanion data) {
    return Deck(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      formatId: data.formatId.present ? data.formatId.value : this.formatId,
      name: data.name.present ? data.name.value : this.name,
      archetype: data.archetype.present ? data.archetype.value : this.archetype,
      colors: data.colors.present ? data.colors.value : this.colors,
      notes: data.notes.present ? data.notes.value : this.notes,
      photo: data.photo.present ? data.photo.value : this.photo,
      photoMimeType: data.photoMimeType.present
          ? data.photoMimeType.value
          : this.photoMimeType,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Deck(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('formatId: $formatId, ')
          ..write('name: $name, ')
          ..write('archetype: $archetype, ')
          ..write('colors: $colors, ')
          ..write('notes: $notes, ')
          ..write('photo: $photo, ')
          ..write('photoMimeType: $photoMimeType, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gameId,
    formatId,
    name,
    archetype,
    colors,
    notes,
    $driftBlobEquality.hash(photo),
    photoMimeType,
    isActive,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Deck &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.formatId == this.formatId &&
          other.name == this.name &&
          other.archetype == this.archetype &&
          other.colors == this.colors &&
          other.notes == this.notes &&
          $driftBlobEquality.equals(other.photo, this.photo) &&
          other.photoMimeType == this.photoMimeType &&
          other.isActive == this.isActive &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class DecksCompanion extends UpdateCompanion<Deck> {
  final Value<String> id;
  final Value<String> gameId;
  final Value<String> formatId;
  final Value<String> name;
  final Value<String> archetype;
  final Value<String?> colors;
  final Value<String?> notes;
  final Value<Uint8List?> photo;
  final Value<String?> photoMimeType;
  final Value<bool> isActive;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const DecksCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.formatId = const Value.absent(),
    this.name = const Value.absent(),
    this.archetype = const Value.absent(),
    this.colors = const Value.absent(),
    this.notes = const Value.absent(),
    this.photo = const Value.absent(),
    this.photoMimeType = const Value.absent(),
    this.isActive = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DecksCompanion.insert({
    required String id,
    required String gameId,
    required String formatId,
    required String name,
    required String archetype,
    this.colors = const Value.absent(),
    this.notes = const Value.absent(),
    this.photo = const Value.absent(),
    this.photoMimeType = const Value.absent(),
    this.isActive = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gameId = Value(gameId),
       formatId = Value(formatId),
       name = Value(name),
       archetype = Value(archetype),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Deck> custom({
    Expression<String>? id,
    Expression<String>? gameId,
    Expression<String>? formatId,
    Expression<String>? name,
    Expression<String>? archetype,
    Expression<String>? colors,
    Expression<String>? notes,
    Expression<Uint8List>? photo,
    Expression<String>? photoMimeType,
    Expression<bool>? isActive,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (formatId != null) 'format_id': formatId,
      if (name != null) 'name': name,
      if (archetype != null) 'archetype': archetype,
      if (colors != null) 'colors': colors,
      if (notes != null) 'notes': notes,
      if (photo != null) 'photo': photo,
      if (photoMimeType != null) 'photo_mime_type': photoMimeType,
      if (isActive != null) 'is_active': isActive,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DecksCompanion copyWith({
    Value<String>? id,
    Value<String>? gameId,
    Value<String>? formatId,
    Value<String>? name,
    Value<String>? archetype,
    Value<String?>? colors,
    Value<String?>? notes,
    Value<Uint8List?>? photo,
    Value<String?>? photoMimeType,
    Value<bool>? isActive,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return DecksCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      formatId: formatId ?? this.formatId,
      name: name ?? this.name,
      archetype: archetype ?? this.archetype,
      colors: colors ?? this.colors,
      notes: notes ?? this.notes,
      photo: photo ?? this.photo,
      photoMimeType: photoMimeType ?? this.photoMimeType,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (formatId.present) {
      map['format_id'] = Variable<String>(formatId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (archetype.present) {
      map['archetype'] = Variable<String>(archetype.value);
    }
    if (colors.present) {
      map['colors'] = Variable<String>(colors.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (photo.present) {
      map['photo'] = Variable<Uint8List>(photo.value);
    }
    if (photoMimeType.present) {
      map['photo_mime_type'] = Variable<String>(photoMimeType.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<bool>(isActive.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DecksCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('formatId: $formatId, ')
          ..write('name: $name, ')
          ..write('archetype: $archetype, ')
          ..write('colors: $colors, ')
          ..write('notes: $notes, ')
          ..write('photo: $photo, ')
          ..write('photoMimeType: $photoMimeType, ')
          ..write('isActive: $isActive, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DeckCardsTable extends DeckCards
    with TableInfo<$DeckCardsTable, DeckCard> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DeckCardsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES decks (id) ON DELETE CASCADE',
    ),
  );
  @override
  late final GeneratedColumnWithTypeConverter<DeckSection, String> section =
      GeneratedColumn<String>(
        'section',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<DeckSection>($DeckCardsTable.$convertersection);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _quantityMeta = const VerificationMeta(
    'quantity',
  );
  @override
  late final GeneratedColumn<int> quantity = GeneratedColumn<int>(
    'quantity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _sortOrderMeta = const VerificationMeta(
    'sortOrder',
  );
  @override
  late final GeneratedColumn<int> sortOrder = GeneratedColumn<int>(
    'sort_order',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    deckId,
    section,
    name,
    quantity,
    sortOrder,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'deck_cards';
  @override
  VerificationContext validateIntegrity(
    Insertable<DeckCard> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('quantity')) {
      context.handle(
        _quantityMeta,
        quantity.isAcceptableOrUnknown(data['quantity']!, _quantityMeta),
      );
    }
    if (data.containsKey('sort_order')) {
      context.handle(
        _sortOrderMeta,
        sortOrder.isAcceptableOrUnknown(data['sort_order']!, _sortOrderMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DeckCard map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DeckCard(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_id'],
      )!,
      section: $DeckCardsTable.$convertersection.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}section'],
        )!,
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      quantity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}quantity'],
      )!,
      sortOrder: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}sort_order'],
      )!,
    );
  }

  @override
  $DeckCardsTable createAlias(String alias) {
    return $DeckCardsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<DeckSection, String, String> $convertersection =
      const EnumNameConverter<DeckSection>(DeckSection.values);
}

class DeckCard extends DataClass implements Insertable<DeckCard> {
  final String id;
  final String deckId;
  final DeckSection section;
  final String name;
  final int quantity;

  /// Position within its section, preserving the order of the source file.
  final int sortOrder;
  const DeckCard({
    required this.id,
    required this.deckId,
    required this.section,
    required this.name,
    required this.quantity,
    required this.sortOrder,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['deck_id'] = Variable<String>(deckId);
    {
      map['section'] = Variable<String>(
        $DeckCardsTable.$convertersection.toSql(section),
      );
    }
    map['name'] = Variable<String>(name);
    map['quantity'] = Variable<int>(quantity);
    map['sort_order'] = Variable<int>(sortOrder);
    return map;
  }

  DeckCardsCompanion toCompanion(bool nullToAbsent) {
    return DeckCardsCompanion(
      id: Value(id),
      deckId: Value(deckId),
      section: Value(section),
      name: Value(name),
      quantity: Value(quantity),
      sortOrder: Value(sortOrder),
    );
  }

  factory DeckCard.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DeckCard(
      id: serializer.fromJson<String>(json['id']),
      deckId: serializer.fromJson<String>(json['deckId']),
      section: $DeckCardsTable.$convertersection.fromJson(
        serializer.fromJson<String>(json['section']),
      ),
      name: serializer.fromJson<String>(json['name']),
      quantity: serializer.fromJson<int>(json['quantity']),
      sortOrder: serializer.fromJson<int>(json['sortOrder']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'deckId': serializer.toJson<String>(deckId),
      'section': serializer.toJson<String>(
        $DeckCardsTable.$convertersection.toJson(section),
      ),
      'name': serializer.toJson<String>(name),
      'quantity': serializer.toJson<int>(quantity),
      'sortOrder': serializer.toJson<int>(sortOrder),
    };
  }

  DeckCard copyWith({
    String? id,
    String? deckId,
    DeckSection? section,
    String? name,
    int? quantity,
    int? sortOrder,
  }) => DeckCard(
    id: id ?? this.id,
    deckId: deckId ?? this.deckId,
    section: section ?? this.section,
    name: name ?? this.name,
    quantity: quantity ?? this.quantity,
    sortOrder: sortOrder ?? this.sortOrder,
  );
  DeckCard copyWithCompanion(DeckCardsCompanion data) {
    return DeckCard(
      id: data.id.present ? data.id.value : this.id,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      section: data.section.present ? data.section.value : this.section,
      name: data.name.present ? data.name.value : this.name,
      quantity: data.quantity.present ? data.quantity.value : this.quantity,
      sortOrder: data.sortOrder.present ? data.sortOrder.value : this.sortOrder,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DeckCard(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('section: $section, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('sortOrder: $sortOrder')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, deckId, section, name, quantity, sortOrder);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeckCard &&
          other.id == this.id &&
          other.deckId == this.deckId &&
          other.section == this.section &&
          other.name == this.name &&
          other.quantity == this.quantity &&
          other.sortOrder == this.sortOrder);
}

class DeckCardsCompanion extends UpdateCompanion<DeckCard> {
  final Value<String> id;
  final Value<String> deckId;
  final Value<DeckSection> section;
  final Value<String> name;
  final Value<int> quantity;
  final Value<int> sortOrder;
  final Value<int> rowid;
  const DeckCardsCompanion({
    this.id = const Value.absent(),
    this.deckId = const Value.absent(),
    this.section = const Value.absent(),
    this.name = const Value.absent(),
    this.quantity = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DeckCardsCompanion.insert({
    required String id,
    required String deckId,
    required DeckSection section,
    required String name,
    this.quantity = const Value.absent(),
    this.sortOrder = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       deckId = Value(deckId),
       section = Value(section),
       name = Value(name);
  static Insertable<DeckCard> custom({
    Expression<String>? id,
    Expression<String>? deckId,
    Expression<String>? section,
    Expression<String>? name,
    Expression<int>? quantity,
    Expression<int>? sortOrder,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (deckId != null) 'deck_id': deckId,
      if (section != null) 'section': section,
      if (name != null) 'name': name,
      if (quantity != null) 'quantity': quantity,
      if (sortOrder != null) 'sort_order': sortOrder,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DeckCardsCompanion copyWith({
    Value<String>? id,
    Value<String>? deckId,
    Value<DeckSection>? section,
    Value<String>? name,
    Value<int>? quantity,
    Value<int>? sortOrder,
    Value<int>? rowid,
  }) {
    return DeckCardsCompanion(
      id: id ?? this.id,
      deckId: deckId ?? this.deckId,
      section: section ?? this.section,
      name: name ?? this.name,
      quantity: quantity ?? this.quantity,
      sortOrder: sortOrder ?? this.sortOrder,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (section.present) {
      map['section'] = Variable<String>(
        $DeckCardsTable.$convertersection.toSql(section.value),
      );
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (quantity.present) {
      map['quantity'] = Variable<int>(quantity.value);
    }
    if (sortOrder.present) {
      map['sort_order'] = Variable<int>(sortOrder.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DeckCardsCompanion(')
          ..write('id: $id, ')
          ..write('deckId: $deckId, ')
          ..write('section: $section, ')
          ..write('name: $name, ')
          ..write('quantity: $quantity, ')
          ..write('sortOrder: $sortOrder, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OpponentArchetypesTable extends OpponentArchetypes
    with TableInfo<$OpponentArchetypesTable, OpponentArchetype> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OpponentArchetypesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id)',
    ),
  );
  static const VerificationMeta _formatIdMeta = const VerificationMeta(
    'formatId',
  );
  @override
  late final GeneratedColumn<String> formatId = GeneratedColumn<String>(
    'format_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES formats (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _timesFacedMeta = const VerificationMeta(
    'timesFaced',
  );
  @override
  late final GeneratedColumn<int> timesFaced = GeneratedColumn<int>(
    'times_faced',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    formatId,
    name,
    timesFaced,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'opponent_archetypes';
  @override
  VerificationContext validateIntegrity(
    Insertable<OpponentArchetype> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('format_id')) {
      context.handle(
        _formatIdMeta,
        formatId.isAcceptableOrUnknown(data['format_id']!, _formatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_formatIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('times_faced')) {
      context.handle(
        _timesFacedMeta,
        timesFaced.isAcceptableOrUnknown(data['times_faced']!, _timesFacedMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  OpponentArchetype map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OpponentArchetype(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      formatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      timesFaced: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}times_faced'],
      )!,
    );
  }

  @override
  $OpponentArchetypesTable createAlias(String alias) {
    return $OpponentArchetypesTable(attachedDatabase, alias);
  }
}

class OpponentArchetype extends DataClass
    implements Insertable<OpponentArchetype> {
  final String id;
  final String gameId;
  final String formatId;
  final String name;

  /// Denormalised counter that orders the suggestions by how often the
  /// archetype actually shows up at the tables the user plays at.
  final int timesFaced;
  const OpponentArchetype({
    required this.id,
    required this.gameId,
    required this.formatId,
    required this.name,
    required this.timesFaced,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['game_id'] = Variable<String>(gameId);
    map['format_id'] = Variable<String>(formatId);
    map['name'] = Variable<String>(name);
    map['times_faced'] = Variable<int>(timesFaced);
    return map;
  }

  OpponentArchetypesCompanion toCompanion(bool nullToAbsent) {
    return OpponentArchetypesCompanion(
      id: Value(id),
      gameId: Value(gameId),
      formatId: Value(formatId),
      name: Value(name),
      timesFaced: Value(timesFaced),
    );
  }

  factory OpponentArchetype.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OpponentArchetype(
      id: serializer.fromJson<String>(json['id']),
      gameId: serializer.fromJson<String>(json['gameId']),
      formatId: serializer.fromJson<String>(json['formatId']),
      name: serializer.fromJson<String>(json['name']),
      timesFaced: serializer.fromJson<int>(json['timesFaced']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gameId': serializer.toJson<String>(gameId),
      'formatId': serializer.toJson<String>(formatId),
      'name': serializer.toJson<String>(name),
      'timesFaced': serializer.toJson<int>(timesFaced),
    };
  }

  OpponentArchetype copyWith({
    String? id,
    String? gameId,
    String? formatId,
    String? name,
    int? timesFaced,
  }) => OpponentArchetype(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    formatId: formatId ?? this.formatId,
    name: name ?? this.name,
    timesFaced: timesFaced ?? this.timesFaced,
  );
  OpponentArchetype copyWithCompanion(OpponentArchetypesCompanion data) {
    return OpponentArchetype(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      formatId: data.formatId.present ? data.formatId.value : this.formatId,
      name: data.name.present ? data.name.value : this.name,
      timesFaced: data.timesFaced.present
          ? data.timesFaced.value
          : this.timesFaced,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OpponentArchetype(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('formatId: $formatId, ')
          ..write('name: $name, ')
          ..write('timesFaced: $timesFaced')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, gameId, formatId, name, timesFaced);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OpponentArchetype &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.formatId == this.formatId &&
          other.name == this.name &&
          other.timesFaced == this.timesFaced);
}

class OpponentArchetypesCompanion extends UpdateCompanion<OpponentArchetype> {
  final Value<String> id;
  final Value<String> gameId;
  final Value<String> formatId;
  final Value<String> name;
  final Value<int> timesFaced;
  final Value<int> rowid;
  const OpponentArchetypesCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.formatId = const Value.absent(),
    this.name = const Value.absent(),
    this.timesFaced = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OpponentArchetypesCompanion.insert({
    required String id,
    required String gameId,
    required String formatId,
    required String name,
    this.timesFaced = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gameId = Value(gameId),
       formatId = Value(formatId),
       name = Value(name);
  static Insertable<OpponentArchetype> custom({
    Expression<String>? id,
    Expression<String>? gameId,
    Expression<String>? formatId,
    Expression<String>? name,
    Expression<int>? timesFaced,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (formatId != null) 'format_id': formatId,
      if (name != null) 'name': name,
      if (timesFaced != null) 'times_faced': timesFaced,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OpponentArchetypesCompanion copyWith({
    Value<String>? id,
    Value<String>? gameId,
    Value<String>? formatId,
    Value<String>? name,
    Value<int>? timesFaced,
    Value<int>? rowid,
  }) {
    return OpponentArchetypesCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      formatId: formatId ?? this.formatId,
      name: name ?? this.name,
      timesFaced: timesFaced ?? this.timesFaced,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (formatId.present) {
      map['format_id'] = Variable<String>(formatId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (timesFaced.present) {
      map['times_faced'] = Variable<int>(timesFaced.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OpponentArchetypesCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('formatId: $formatId, ')
          ..write('name: $name, ')
          ..write('timesFaced: $timesFaced, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TournamentsTable extends Tournaments
    with TableInfo<$TournamentsTable, Tournament> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TournamentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id)',
    ),
  );
  static const VerificationMeta _formatIdMeta = const VerificationMeta(
    'formatId',
  );
  @override
  late final GeneratedColumn<String> formatId = GeneratedColumn<String>(
    'format_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES formats (id)',
    ),
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES decks (id)',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
    'date',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  late final GeneratedColumnWithTypeConverter<EventType, String> eventType =
      GeneratedColumn<String>(
        'event_type',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<EventType>($TournamentsTable.$convertereventType);
  static const VerificationMeta _participantCountMeta = const VerificationMeta(
    'participantCount',
  );
  @override
  late final GeneratedColumn<int> participantCount = GeneratedColumn<int>(
    'participant_count',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _roundsPlannedMeta = const VerificationMeta(
    'roundsPlanned',
  );
  @override
  late final GeneratedColumn<int> roundsPlanned = GeneratedColumn<int>(
    'rounds_planned',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _hasTopCutMeta = const VerificationMeta(
    'hasTopCut',
  );
  @override
  late final GeneratedColumn<bool> hasTopCut = GeneratedColumn<bool>(
    'has_top_cut',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("has_top_cut" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _topCutSizeMeta = const VerificationMeta(
    'topCutSize',
  );
  @override
  late final GeneratedColumn<int> topCutSize = GeneratedColumn<int>(
    'top_cut_size',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _finalStandingMeta = const VerificationMeta(
    'finalStanding',
  );
  @override
  late final GeneratedColumn<int> finalStanding = GeneratedColumn<int>(
    'final_standing',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  @override
  late final GeneratedColumnWithTypeConverter<TournamentStatus, String> status =
      GeneratedColumn<String>(
        'status',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<TournamentStatus>($TournamentsTable.$converterstatus);
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    gameId,
    formatId,
    deckId,
    name,
    date,
    eventType,
    participantCount,
    roundsPlanned,
    hasTopCut,
    topCutSize,
    finalStanding,
    status,
    notes,
    createdAt,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'tournaments';
  @override
  VerificationContext validateIntegrity(
    Insertable<Tournament> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('format_id')) {
      context.handle(
        _formatIdMeta,
        formatId.isAcceptableOrUnknown(data['format_id']!, _formatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_formatIdMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
        _dateMeta,
        date.isAcceptableOrUnknown(data['date']!, _dateMeta),
      );
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('participant_count')) {
      context.handle(
        _participantCountMeta,
        participantCount.isAcceptableOrUnknown(
          data['participant_count']!,
          _participantCountMeta,
        ),
      );
    }
    if (data.containsKey('rounds_planned')) {
      context.handle(
        _roundsPlannedMeta,
        roundsPlanned.isAcceptableOrUnknown(
          data['rounds_planned']!,
          _roundsPlannedMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_roundsPlannedMeta);
    }
    if (data.containsKey('has_top_cut')) {
      context.handle(
        _hasTopCutMeta,
        hasTopCut.isAcceptableOrUnknown(data['has_top_cut']!, _hasTopCutMeta),
      );
    }
    if (data.containsKey('top_cut_size')) {
      context.handle(
        _topCutSizeMeta,
        topCutSize.isAcceptableOrUnknown(
          data['top_cut_size']!,
          _topCutSizeMeta,
        ),
      );
    }
    if (data.containsKey('final_standing')) {
      context.handle(
        _finalStandingMeta,
        finalStanding.isAcceptableOrUnknown(
          data['final_standing']!,
          _finalStandingMeta,
        ),
      );
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Tournament map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Tournament(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      formatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format_id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      date: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}date'],
      )!,
      eventType: $TournamentsTable.$convertereventType.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}event_type'],
        )!,
      ),
      participantCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}participant_count'],
      ),
      roundsPlanned: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}rounds_planned'],
      )!,
      hasTopCut: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}has_top_cut'],
      )!,
      topCutSize: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}top_cut_size'],
      ),
      finalStanding: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}final_standing'],
      ),
      status: $TournamentsTable.$converterstatus.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}status'],
        )!,
      ),
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $TournamentsTable createAlias(String alias) {
    return $TournamentsTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<EventType, String, String> $convertereventType =
      const EnumNameConverter<EventType>(EventType.values);
  static JsonTypeConverter2<TournamentStatus, String, String> $converterstatus =
      const EnumNameConverter<TournamentStatus>(TournamentStatus.values);
}

class Tournament extends DataClass implements Insertable<Tournament> {
  final String id;
  final String gameId;
  final String formatId;
  final String deckId;
  final String name;
  final DateTime date;
  final EventType eventType;
  final int? participantCount;
  final int roundsPlanned;
  final bool hasTopCut;
  final int? topCutSize;
  final int? finalStanding;
  final TournamentStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  const Tournament({
    required this.id,
    required this.gameId,
    required this.formatId,
    required this.deckId,
    required this.name,
    required this.date,
    required this.eventType,
    this.participantCount,
    required this.roundsPlanned,
    required this.hasTopCut,
    this.topCutSize,
    this.finalStanding,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['game_id'] = Variable<String>(gameId);
    map['format_id'] = Variable<String>(formatId);
    map['deck_id'] = Variable<String>(deckId);
    map['name'] = Variable<String>(name);
    map['date'] = Variable<DateTime>(date);
    {
      map['event_type'] = Variable<String>(
        $TournamentsTable.$convertereventType.toSql(eventType),
      );
    }
    if (!nullToAbsent || participantCount != null) {
      map['participant_count'] = Variable<int>(participantCount);
    }
    map['rounds_planned'] = Variable<int>(roundsPlanned);
    map['has_top_cut'] = Variable<bool>(hasTopCut);
    if (!nullToAbsent || topCutSize != null) {
      map['top_cut_size'] = Variable<int>(topCutSize);
    }
    if (!nullToAbsent || finalStanding != null) {
      map['final_standing'] = Variable<int>(finalStanding);
    }
    {
      map['status'] = Variable<String>(
        $TournamentsTable.$converterstatus.toSql(status),
      );
    }
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  TournamentsCompanion toCompanion(bool nullToAbsent) {
    return TournamentsCompanion(
      id: Value(id),
      gameId: Value(gameId),
      formatId: Value(formatId),
      deckId: Value(deckId),
      name: Value(name),
      date: Value(date),
      eventType: Value(eventType),
      participantCount: participantCount == null && nullToAbsent
          ? const Value.absent()
          : Value(participantCount),
      roundsPlanned: Value(roundsPlanned),
      hasTopCut: Value(hasTopCut),
      topCutSize: topCutSize == null && nullToAbsent
          ? const Value.absent()
          : Value(topCutSize),
      finalStanding: finalStanding == null && nullToAbsent
          ? const Value.absent()
          : Value(finalStanding),
      status: Value(status),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
    );
  }

  factory Tournament.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Tournament(
      id: serializer.fromJson<String>(json['id']),
      gameId: serializer.fromJson<String>(json['gameId']),
      formatId: serializer.fromJson<String>(json['formatId']),
      deckId: serializer.fromJson<String>(json['deckId']),
      name: serializer.fromJson<String>(json['name']),
      date: serializer.fromJson<DateTime>(json['date']),
      eventType: $TournamentsTable.$convertereventType.fromJson(
        serializer.fromJson<String>(json['eventType']),
      ),
      participantCount: serializer.fromJson<int?>(json['participantCount']),
      roundsPlanned: serializer.fromJson<int>(json['roundsPlanned']),
      hasTopCut: serializer.fromJson<bool>(json['hasTopCut']),
      topCutSize: serializer.fromJson<int?>(json['topCutSize']),
      finalStanding: serializer.fromJson<int?>(json['finalStanding']),
      status: $TournamentsTable.$converterstatus.fromJson(
        serializer.fromJson<String>(json['status']),
      ),
      notes: serializer.fromJson<String?>(json['notes']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'gameId': serializer.toJson<String>(gameId),
      'formatId': serializer.toJson<String>(formatId),
      'deckId': serializer.toJson<String>(deckId),
      'name': serializer.toJson<String>(name),
      'date': serializer.toJson<DateTime>(date),
      'eventType': serializer.toJson<String>(
        $TournamentsTable.$convertereventType.toJson(eventType),
      ),
      'participantCount': serializer.toJson<int?>(participantCount),
      'roundsPlanned': serializer.toJson<int>(roundsPlanned),
      'hasTopCut': serializer.toJson<bool>(hasTopCut),
      'topCutSize': serializer.toJson<int?>(topCutSize),
      'finalStanding': serializer.toJson<int?>(finalStanding),
      'status': serializer.toJson<String>(
        $TournamentsTable.$converterstatus.toJson(status),
      ),
      'notes': serializer.toJson<String?>(notes),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  Tournament copyWith({
    String? id,
    String? gameId,
    String? formatId,
    String? deckId,
    String? name,
    DateTime? date,
    EventType? eventType,
    Value<int?> participantCount = const Value.absent(),
    int? roundsPlanned,
    bool? hasTopCut,
    Value<int?> topCutSize = const Value.absent(),
    Value<int?> finalStanding = const Value.absent(),
    TournamentStatus? status,
    Value<String?> notes = const Value.absent(),
    DateTime? createdAt,
    DateTime? updatedAt,
  }) => Tournament(
    id: id ?? this.id,
    gameId: gameId ?? this.gameId,
    formatId: formatId ?? this.formatId,
    deckId: deckId ?? this.deckId,
    name: name ?? this.name,
    date: date ?? this.date,
    eventType: eventType ?? this.eventType,
    participantCount: participantCount.present
        ? participantCount.value
        : this.participantCount,
    roundsPlanned: roundsPlanned ?? this.roundsPlanned,
    hasTopCut: hasTopCut ?? this.hasTopCut,
    topCutSize: topCutSize.present ? topCutSize.value : this.topCutSize,
    finalStanding: finalStanding.present
        ? finalStanding.value
        : this.finalStanding,
    status: status ?? this.status,
    notes: notes.present ? notes.value : this.notes,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  Tournament copyWithCompanion(TournamentsCompanion data) {
    return Tournament(
      id: data.id.present ? data.id.value : this.id,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      formatId: data.formatId.present ? data.formatId.value : this.formatId,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      name: data.name.present ? data.name.value : this.name,
      date: data.date.present ? data.date.value : this.date,
      eventType: data.eventType.present ? data.eventType.value : this.eventType,
      participantCount: data.participantCount.present
          ? data.participantCount.value
          : this.participantCount,
      roundsPlanned: data.roundsPlanned.present
          ? data.roundsPlanned.value
          : this.roundsPlanned,
      hasTopCut: data.hasTopCut.present ? data.hasTopCut.value : this.hasTopCut,
      topCutSize: data.topCutSize.present
          ? data.topCutSize.value
          : this.topCutSize,
      finalStanding: data.finalStanding.present
          ? data.finalStanding.value
          : this.finalStanding,
      status: data.status.present ? data.status.value : this.status,
      notes: data.notes.present ? data.notes.value : this.notes,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Tournament(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('formatId: $formatId, ')
          ..write('deckId: $deckId, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('eventType: $eventType, ')
          ..write('participantCount: $participantCount, ')
          ..write('roundsPlanned: $roundsPlanned, ')
          ..write('hasTopCut: $hasTopCut, ')
          ..write('topCutSize: $topCutSize, ')
          ..write('finalStanding: $finalStanding, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    gameId,
    formatId,
    deckId,
    name,
    date,
    eventType,
    participantCount,
    roundsPlanned,
    hasTopCut,
    topCutSize,
    finalStanding,
    status,
    notes,
    createdAt,
    updatedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Tournament &&
          other.id == this.id &&
          other.gameId == this.gameId &&
          other.formatId == this.formatId &&
          other.deckId == this.deckId &&
          other.name == this.name &&
          other.date == this.date &&
          other.eventType == this.eventType &&
          other.participantCount == this.participantCount &&
          other.roundsPlanned == this.roundsPlanned &&
          other.hasTopCut == this.hasTopCut &&
          other.topCutSize == this.topCutSize &&
          other.finalStanding == this.finalStanding &&
          other.status == this.status &&
          other.notes == this.notes &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class TournamentsCompanion extends UpdateCompanion<Tournament> {
  final Value<String> id;
  final Value<String> gameId;
  final Value<String> formatId;
  final Value<String> deckId;
  final Value<String> name;
  final Value<DateTime> date;
  final Value<EventType> eventType;
  final Value<int?> participantCount;
  final Value<int> roundsPlanned;
  final Value<bool> hasTopCut;
  final Value<int?> topCutSize;
  final Value<int?> finalStanding;
  final Value<TournamentStatus> status;
  final Value<String?> notes;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const TournamentsCompanion({
    this.id = const Value.absent(),
    this.gameId = const Value.absent(),
    this.formatId = const Value.absent(),
    this.deckId = const Value.absent(),
    this.name = const Value.absent(),
    this.date = const Value.absent(),
    this.eventType = const Value.absent(),
    this.participantCount = const Value.absent(),
    this.roundsPlanned = const Value.absent(),
    this.hasTopCut = const Value.absent(),
    this.topCutSize = const Value.absent(),
    this.finalStanding = const Value.absent(),
    this.status = const Value.absent(),
    this.notes = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TournamentsCompanion.insert({
    required String id,
    required String gameId,
    required String formatId,
    required String deckId,
    required String name,
    required DateTime date,
    required EventType eventType,
    this.participantCount = const Value.absent(),
    required int roundsPlanned,
    this.hasTopCut = const Value.absent(),
    this.topCutSize = const Value.absent(),
    this.finalStanding = const Value.absent(),
    required TournamentStatus status,
    this.notes = const Value.absent(),
    required DateTime createdAt,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gameId = Value(gameId),
       formatId = Value(formatId),
       deckId = Value(deckId),
       name = Value(name),
       date = Value(date),
       eventType = Value(eventType),
       roundsPlanned = Value(roundsPlanned),
       status = Value(status),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt);
  static Insertable<Tournament> custom({
    Expression<String>? id,
    Expression<String>? gameId,
    Expression<String>? formatId,
    Expression<String>? deckId,
    Expression<String>? name,
    Expression<DateTime>? date,
    Expression<String>? eventType,
    Expression<int>? participantCount,
    Expression<int>? roundsPlanned,
    Expression<bool>? hasTopCut,
    Expression<int>? topCutSize,
    Expression<int>? finalStanding,
    Expression<String>? status,
    Expression<String>? notes,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (gameId != null) 'game_id': gameId,
      if (formatId != null) 'format_id': formatId,
      if (deckId != null) 'deck_id': deckId,
      if (name != null) 'name': name,
      if (date != null) 'date': date,
      if (eventType != null) 'event_type': eventType,
      if (participantCount != null) 'participant_count': participantCount,
      if (roundsPlanned != null) 'rounds_planned': roundsPlanned,
      if (hasTopCut != null) 'has_top_cut': hasTopCut,
      if (topCutSize != null) 'top_cut_size': topCutSize,
      if (finalStanding != null) 'final_standing': finalStanding,
      if (status != null) 'status': status,
      if (notes != null) 'notes': notes,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TournamentsCompanion copyWith({
    Value<String>? id,
    Value<String>? gameId,
    Value<String>? formatId,
    Value<String>? deckId,
    Value<String>? name,
    Value<DateTime>? date,
    Value<EventType>? eventType,
    Value<int?>? participantCount,
    Value<int>? roundsPlanned,
    Value<bool>? hasTopCut,
    Value<int?>? topCutSize,
    Value<int?>? finalStanding,
    Value<TournamentStatus>? status,
    Value<String?>? notes,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return TournamentsCompanion(
      id: id ?? this.id,
      gameId: gameId ?? this.gameId,
      formatId: formatId ?? this.formatId,
      deckId: deckId ?? this.deckId,
      name: name ?? this.name,
      date: date ?? this.date,
      eventType: eventType ?? this.eventType,
      participantCount: participantCount ?? this.participantCount,
      roundsPlanned: roundsPlanned ?? this.roundsPlanned,
      hasTopCut: hasTopCut ?? this.hasTopCut,
      topCutSize: topCutSize ?? this.topCutSize,
      finalStanding: finalStanding ?? this.finalStanding,
      status: status ?? this.status,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (formatId.present) {
      map['format_id'] = Variable<String>(formatId.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (eventType.present) {
      map['event_type'] = Variable<String>(
        $TournamentsTable.$convertereventType.toSql(eventType.value),
      );
    }
    if (participantCount.present) {
      map['participant_count'] = Variable<int>(participantCount.value);
    }
    if (roundsPlanned.present) {
      map['rounds_planned'] = Variable<int>(roundsPlanned.value);
    }
    if (hasTopCut.present) {
      map['has_top_cut'] = Variable<bool>(hasTopCut.value);
    }
    if (topCutSize.present) {
      map['top_cut_size'] = Variable<int>(topCutSize.value);
    }
    if (finalStanding.present) {
      map['final_standing'] = Variable<int>(finalStanding.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(
        $TournamentsTable.$converterstatus.toSql(status.value),
      );
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TournamentsCompanion(')
          ..write('id: $id, ')
          ..write('gameId: $gameId, ')
          ..write('formatId: $formatId, ')
          ..write('deckId: $deckId, ')
          ..write('name: $name, ')
          ..write('date: $date, ')
          ..write('eventType: $eventType, ')
          ..write('participantCount: $participantCount, ')
          ..write('roundsPlanned: $roundsPlanned, ')
          ..write('hasTopCut: $hasTopCut, ')
          ..write('topCutSize: $topCutSize, ')
          ..write('finalStanding: $finalStanding, ')
          ..write('status: $status, ')
          ..write('notes: $notes, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MatchesTable extends Matches with TableInfo<$MatchesTable, Match> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MatchesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tournamentIdMeta = const VerificationMeta(
    'tournamentId',
  );
  @override
  late final GeneratedColumn<String> tournamentId = GeneratedColumn<String>(
    'tournament_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES tournaments (id)',
    ),
  );
  static const VerificationMeta _gameIdMeta = const VerificationMeta('gameId');
  @override
  late final GeneratedColumn<String> gameId = GeneratedColumn<String>(
    'game_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES games (id)',
    ),
  );
  static const VerificationMeta _formatIdMeta = const VerificationMeta(
    'formatId',
  );
  @override
  late final GeneratedColumn<String> formatId = GeneratedColumn<String>(
    'format_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES formats (id)',
    ),
  );
  static const VerificationMeta _deckIdMeta = const VerificationMeta('deckId');
  @override
  late final GeneratedColumn<String> deckId = GeneratedColumn<String>(
    'deck_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES decks (id)',
    ),
  );
  static const VerificationMeta _roundNumberMeta = const VerificationMeta(
    'roundNumber',
  );
  @override
  late final GeneratedColumn<int> roundNumber = GeneratedColumn<int>(
    'round_number',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isTopCutMeta = const VerificationMeta(
    'isTopCut',
  );
  @override
  late final GeneratedColumn<bool> isTopCut = GeneratedColumn<bool>(
    'is_top_cut',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_top_cut" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  static const VerificationMeta _opponentNameMeta = const VerificationMeta(
    'opponentName',
  );
  @override
  late final GeneratedColumn<String> opponentName = GeneratedColumn<String>(
    'opponent_name',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _opponentArchetypeIdMeta =
      const VerificationMeta('opponentArchetypeId');
  @override
  late final GeneratedColumn<String> opponentArchetypeId =
      GeneratedColumn<String>(
        'opponent_archetype_id',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
        defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES opponent_archetypes (id)',
        ),
      );
  static const VerificationMeta _onThePlayMeta = const VerificationMeta(
    'onThePlay',
  );
  @override
  late final GeneratedColumn<bool> onThePlay = GeneratedColumn<bool>(
    'on_the_play',
    aliasedName,
    true,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("on_the_play" IN (0, 1))',
    ),
  );
  static const VerificationMeta _gamesWonMeta = const VerificationMeta(
    'gamesWon',
  );
  @override
  late final GeneratedColumn<int> gamesWon = GeneratedColumn<int>(
    'games_won',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gamesLostMeta = const VerificationMeta(
    'gamesLost',
  );
  @override
  late final GeneratedColumn<int> gamesLost = GeneratedColumn<int>(
    'games_lost',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _gamesDrawnMeta = const VerificationMeta(
    'gamesDrawn',
  );
  @override
  late final GeneratedColumn<int> gamesDrawn = GeneratedColumn<int>(
    'games_drawn',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  @override
  late final GeneratedColumnWithTypeConverter<MatchResult, String> result =
      GeneratedColumn<String>(
        'result',
        aliasedName,
        false,
        type: DriftSqlType.string,
        requiredDuringInsert: true,
      ).withConverter<MatchResult>($MatchesTable.$converterresult);
  static const VerificationMeta _playedAtMeta = const VerificationMeta(
    'playedAt',
  );
  @override
  late final GeneratedColumn<DateTime> playedAt = GeneratedColumn<DateTime>(
    'played_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _notesMeta = const VerificationMeta('notes');
  @override
  late final GeneratedColumn<String> notes = GeneratedColumn<String>(
    'notes',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    tournamentId,
    gameId,
    formatId,
    deckId,
    roundNumber,
    isTopCut,
    opponentName,
    opponentArchetypeId,
    onThePlay,
    gamesWon,
    gamesLost,
    gamesDrawn,
    result,
    playedAt,
    notes,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'matches';
  @override
  VerificationContext validateIntegrity(
    Insertable<Match> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('tournament_id')) {
      context.handle(
        _tournamentIdMeta,
        tournamentId.isAcceptableOrUnknown(
          data['tournament_id']!,
          _tournamentIdMeta,
        ),
      );
    }
    if (data.containsKey('game_id')) {
      context.handle(
        _gameIdMeta,
        gameId.isAcceptableOrUnknown(data['game_id']!, _gameIdMeta),
      );
    } else if (isInserting) {
      context.missing(_gameIdMeta);
    }
    if (data.containsKey('format_id')) {
      context.handle(
        _formatIdMeta,
        formatId.isAcceptableOrUnknown(data['format_id']!, _formatIdMeta),
      );
    } else if (isInserting) {
      context.missing(_formatIdMeta);
    }
    if (data.containsKey('deck_id')) {
      context.handle(
        _deckIdMeta,
        deckId.isAcceptableOrUnknown(data['deck_id']!, _deckIdMeta),
      );
    } else if (isInserting) {
      context.missing(_deckIdMeta);
    }
    if (data.containsKey('round_number')) {
      context.handle(
        _roundNumberMeta,
        roundNumber.isAcceptableOrUnknown(
          data['round_number']!,
          _roundNumberMeta,
        ),
      );
    }
    if (data.containsKey('is_top_cut')) {
      context.handle(
        _isTopCutMeta,
        isTopCut.isAcceptableOrUnknown(data['is_top_cut']!, _isTopCutMeta),
      );
    }
    if (data.containsKey('opponent_name')) {
      context.handle(
        _opponentNameMeta,
        opponentName.isAcceptableOrUnknown(
          data['opponent_name']!,
          _opponentNameMeta,
        ),
      );
    }
    if (data.containsKey('opponent_archetype_id')) {
      context.handle(
        _opponentArchetypeIdMeta,
        opponentArchetypeId.isAcceptableOrUnknown(
          data['opponent_archetype_id']!,
          _opponentArchetypeIdMeta,
        ),
      );
    }
    if (data.containsKey('on_the_play')) {
      context.handle(
        _onThePlayMeta,
        onThePlay.isAcceptableOrUnknown(data['on_the_play']!, _onThePlayMeta),
      );
    }
    if (data.containsKey('games_won')) {
      context.handle(
        _gamesWonMeta,
        gamesWon.isAcceptableOrUnknown(data['games_won']!, _gamesWonMeta),
      );
    }
    if (data.containsKey('games_lost')) {
      context.handle(
        _gamesLostMeta,
        gamesLost.isAcceptableOrUnknown(data['games_lost']!, _gamesLostMeta),
      );
    }
    if (data.containsKey('games_drawn')) {
      context.handle(
        _gamesDrawnMeta,
        gamesDrawn.isAcceptableOrUnknown(data['games_drawn']!, _gamesDrawnMeta),
      );
    }
    if (data.containsKey('played_at')) {
      context.handle(
        _playedAtMeta,
        playedAt.isAcceptableOrUnknown(data['played_at']!, _playedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_playedAtMeta);
    }
    if (data.containsKey('notes')) {
      context.handle(
        _notesMeta,
        notes.isAcceptableOrUnknown(data['notes']!, _notesMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Match map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Match(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      tournamentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}tournament_id'],
      ),
      gameId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}game_id'],
      )!,
      formatId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}format_id'],
      )!,
      deckId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck_id'],
      )!,
      roundNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}round_number'],
      ),
      isTopCut: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_top_cut'],
      )!,
      opponentName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opponent_name'],
      ),
      opponentArchetypeId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}opponent_archetype_id'],
      ),
      onThePlay: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}on_the_play'],
      ),
      gamesWon: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}games_won'],
      )!,
      gamesLost: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}games_lost'],
      )!,
      gamesDrawn: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}games_drawn'],
      )!,
      result: $MatchesTable.$converterresult.fromSql(
        attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}result'],
        )!,
      ),
      playedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}played_at'],
      )!,
      notes: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}notes'],
      ),
    );
  }

  @override
  $MatchesTable createAlias(String alias) {
    return $MatchesTable(attachedDatabase, alias);
  }

  static JsonTypeConverter2<MatchResult, String, String> $converterresult =
      const EnumNameConverter<MatchResult>(MatchResult.values);
}

class Match extends DataClass implements Insertable<Match> {
  final String id;

  /// Null for a casual match played outside any tournament.
  final String? tournamentId;
  final String gameId;
  final String formatId;
  final String deckId;

  /// Null for a casual match.
  final int? roundNumber;

  /// Kept even though top cut has no dedicated filter: it is what lets the
  /// tournament detail screen rebuild the bracket.
  final bool isTopCut;
  final String? opponentName;
  final String? opponentArchetypeId;

  /// Whether the user went first in game one. Null when not recorded.
  final bool? onThePlay;
  final int gamesWon;
  final int gamesLost;
  final int gamesDrawn;

  /// Derivable from the game counts, but stored so statistics can filter on it
  /// without recomputing, and so a bye can be recorded with no games at all.
  final MatchResult result;
  final DateTime playedAt;
  final String? notes;
  const Match({
    required this.id,
    this.tournamentId,
    required this.gameId,
    required this.formatId,
    required this.deckId,
    this.roundNumber,
    required this.isTopCut,
    this.opponentName,
    this.opponentArchetypeId,
    this.onThePlay,
    required this.gamesWon,
    required this.gamesLost,
    required this.gamesDrawn,
    required this.result,
    required this.playedAt,
    this.notes,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || tournamentId != null) {
      map['tournament_id'] = Variable<String>(tournamentId);
    }
    map['game_id'] = Variable<String>(gameId);
    map['format_id'] = Variable<String>(formatId);
    map['deck_id'] = Variable<String>(deckId);
    if (!nullToAbsent || roundNumber != null) {
      map['round_number'] = Variable<int>(roundNumber);
    }
    map['is_top_cut'] = Variable<bool>(isTopCut);
    if (!nullToAbsent || opponentName != null) {
      map['opponent_name'] = Variable<String>(opponentName);
    }
    if (!nullToAbsent || opponentArchetypeId != null) {
      map['opponent_archetype_id'] = Variable<String>(opponentArchetypeId);
    }
    if (!nullToAbsent || onThePlay != null) {
      map['on_the_play'] = Variable<bool>(onThePlay);
    }
    map['games_won'] = Variable<int>(gamesWon);
    map['games_lost'] = Variable<int>(gamesLost);
    map['games_drawn'] = Variable<int>(gamesDrawn);
    {
      map['result'] = Variable<String>(
        $MatchesTable.$converterresult.toSql(result),
      );
    }
    map['played_at'] = Variable<DateTime>(playedAt);
    if (!nullToAbsent || notes != null) {
      map['notes'] = Variable<String>(notes);
    }
    return map;
  }

  MatchesCompanion toCompanion(bool nullToAbsent) {
    return MatchesCompanion(
      id: Value(id),
      tournamentId: tournamentId == null && nullToAbsent
          ? const Value.absent()
          : Value(tournamentId),
      gameId: Value(gameId),
      formatId: Value(formatId),
      deckId: Value(deckId),
      roundNumber: roundNumber == null && nullToAbsent
          ? const Value.absent()
          : Value(roundNumber),
      isTopCut: Value(isTopCut),
      opponentName: opponentName == null && nullToAbsent
          ? const Value.absent()
          : Value(opponentName),
      opponentArchetypeId: opponentArchetypeId == null && nullToAbsent
          ? const Value.absent()
          : Value(opponentArchetypeId),
      onThePlay: onThePlay == null && nullToAbsent
          ? const Value.absent()
          : Value(onThePlay),
      gamesWon: Value(gamesWon),
      gamesLost: Value(gamesLost),
      gamesDrawn: Value(gamesDrawn),
      result: Value(result),
      playedAt: Value(playedAt),
      notes: notes == null && nullToAbsent
          ? const Value.absent()
          : Value(notes),
    );
  }

  factory Match.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Match(
      id: serializer.fromJson<String>(json['id']),
      tournamentId: serializer.fromJson<String?>(json['tournamentId']),
      gameId: serializer.fromJson<String>(json['gameId']),
      formatId: serializer.fromJson<String>(json['formatId']),
      deckId: serializer.fromJson<String>(json['deckId']),
      roundNumber: serializer.fromJson<int?>(json['roundNumber']),
      isTopCut: serializer.fromJson<bool>(json['isTopCut']),
      opponentName: serializer.fromJson<String?>(json['opponentName']),
      opponentArchetypeId: serializer.fromJson<String?>(
        json['opponentArchetypeId'],
      ),
      onThePlay: serializer.fromJson<bool?>(json['onThePlay']),
      gamesWon: serializer.fromJson<int>(json['gamesWon']),
      gamesLost: serializer.fromJson<int>(json['gamesLost']),
      gamesDrawn: serializer.fromJson<int>(json['gamesDrawn']),
      result: $MatchesTable.$converterresult.fromJson(
        serializer.fromJson<String>(json['result']),
      ),
      playedAt: serializer.fromJson<DateTime>(json['playedAt']),
      notes: serializer.fromJson<String?>(json['notes']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'tournamentId': serializer.toJson<String?>(tournamentId),
      'gameId': serializer.toJson<String>(gameId),
      'formatId': serializer.toJson<String>(formatId),
      'deckId': serializer.toJson<String>(deckId),
      'roundNumber': serializer.toJson<int?>(roundNumber),
      'isTopCut': serializer.toJson<bool>(isTopCut),
      'opponentName': serializer.toJson<String?>(opponentName),
      'opponentArchetypeId': serializer.toJson<String?>(opponentArchetypeId),
      'onThePlay': serializer.toJson<bool?>(onThePlay),
      'gamesWon': serializer.toJson<int>(gamesWon),
      'gamesLost': serializer.toJson<int>(gamesLost),
      'gamesDrawn': serializer.toJson<int>(gamesDrawn),
      'result': serializer.toJson<String>(
        $MatchesTable.$converterresult.toJson(result),
      ),
      'playedAt': serializer.toJson<DateTime>(playedAt),
      'notes': serializer.toJson<String?>(notes),
    };
  }

  Match copyWith({
    String? id,
    Value<String?> tournamentId = const Value.absent(),
    String? gameId,
    String? formatId,
    String? deckId,
    Value<int?> roundNumber = const Value.absent(),
    bool? isTopCut,
    Value<String?> opponentName = const Value.absent(),
    Value<String?> opponentArchetypeId = const Value.absent(),
    Value<bool?> onThePlay = const Value.absent(),
    int? gamesWon,
    int? gamesLost,
    int? gamesDrawn,
    MatchResult? result,
    DateTime? playedAt,
    Value<String?> notes = const Value.absent(),
  }) => Match(
    id: id ?? this.id,
    tournamentId: tournamentId.present ? tournamentId.value : this.tournamentId,
    gameId: gameId ?? this.gameId,
    formatId: formatId ?? this.formatId,
    deckId: deckId ?? this.deckId,
    roundNumber: roundNumber.present ? roundNumber.value : this.roundNumber,
    isTopCut: isTopCut ?? this.isTopCut,
    opponentName: opponentName.present ? opponentName.value : this.opponentName,
    opponentArchetypeId: opponentArchetypeId.present
        ? opponentArchetypeId.value
        : this.opponentArchetypeId,
    onThePlay: onThePlay.present ? onThePlay.value : this.onThePlay,
    gamesWon: gamesWon ?? this.gamesWon,
    gamesLost: gamesLost ?? this.gamesLost,
    gamesDrawn: gamesDrawn ?? this.gamesDrawn,
    result: result ?? this.result,
    playedAt: playedAt ?? this.playedAt,
    notes: notes.present ? notes.value : this.notes,
  );
  Match copyWithCompanion(MatchesCompanion data) {
    return Match(
      id: data.id.present ? data.id.value : this.id,
      tournamentId: data.tournamentId.present
          ? data.tournamentId.value
          : this.tournamentId,
      gameId: data.gameId.present ? data.gameId.value : this.gameId,
      formatId: data.formatId.present ? data.formatId.value : this.formatId,
      deckId: data.deckId.present ? data.deckId.value : this.deckId,
      roundNumber: data.roundNumber.present
          ? data.roundNumber.value
          : this.roundNumber,
      isTopCut: data.isTopCut.present ? data.isTopCut.value : this.isTopCut,
      opponentName: data.opponentName.present
          ? data.opponentName.value
          : this.opponentName,
      opponentArchetypeId: data.opponentArchetypeId.present
          ? data.opponentArchetypeId.value
          : this.opponentArchetypeId,
      onThePlay: data.onThePlay.present ? data.onThePlay.value : this.onThePlay,
      gamesWon: data.gamesWon.present ? data.gamesWon.value : this.gamesWon,
      gamesLost: data.gamesLost.present ? data.gamesLost.value : this.gamesLost,
      gamesDrawn: data.gamesDrawn.present
          ? data.gamesDrawn.value
          : this.gamesDrawn,
      result: data.result.present ? data.result.value : this.result,
      playedAt: data.playedAt.present ? data.playedAt.value : this.playedAt,
      notes: data.notes.present ? data.notes.value : this.notes,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Match(')
          ..write('id: $id, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('gameId: $gameId, ')
          ..write('formatId: $formatId, ')
          ..write('deckId: $deckId, ')
          ..write('roundNumber: $roundNumber, ')
          ..write('isTopCut: $isTopCut, ')
          ..write('opponentName: $opponentName, ')
          ..write('opponentArchetypeId: $opponentArchetypeId, ')
          ..write('onThePlay: $onThePlay, ')
          ..write('gamesWon: $gamesWon, ')
          ..write('gamesLost: $gamesLost, ')
          ..write('gamesDrawn: $gamesDrawn, ')
          ..write('result: $result, ')
          ..write('playedAt: $playedAt, ')
          ..write('notes: $notes')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    tournamentId,
    gameId,
    formatId,
    deckId,
    roundNumber,
    isTopCut,
    opponentName,
    opponentArchetypeId,
    onThePlay,
    gamesWon,
    gamesLost,
    gamesDrawn,
    result,
    playedAt,
    notes,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Match &&
          other.id == this.id &&
          other.tournamentId == this.tournamentId &&
          other.gameId == this.gameId &&
          other.formatId == this.formatId &&
          other.deckId == this.deckId &&
          other.roundNumber == this.roundNumber &&
          other.isTopCut == this.isTopCut &&
          other.opponentName == this.opponentName &&
          other.opponentArchetypeId == this.opponentArchetypeId &&
          other.onThePlay == this.onThePlay &&
          other.gamesWon == this.gamesWon &&
          other.gamesLost == this.gamesLost &&
          other.gamesDrawn == this.gamesDrawn &&
          other.result == this.result &&
          other.playedAt == this.playedAt &&
          other.notes == this.notes);
}

class MatchesCompanion extends UpdateCompanion<Match> {
  final Value<String> id;
  final Value<String?> tournamentId;
  final Value<String> gameId;
  final Value<String> formatId;
  final Value<String> deckId;
  final Value<int?> roundNumber;
  final Value<bool> isTopCut;
  final Value<String?> opponentName;
  final Value<String?> opponentArchetypeId;
  final Value<bool?> onThePlay;
  final Value<int> gamesWon;
  final Value<int> gamesLost;
  final Value<int> gamesDrawn;
  final Value<MatchResult> result;
  final Value<DateTime> playedAt;
  final Value<String?> notes;
  final Value<int> rowid;
  const MatchesCompanion({
    this.id = const Value.absent(),
    this.tournamentId = const Value.absent(),
    this.gameId = const Value.absent(),
    this.formatId = const Value.absent(),
    this.deckId = const Value.absent(),
    this.roundNumber = const Value.absent(),
    this.isTopCut = const Value.absent(),
    this.opponentName = const Value.absent(),
    this.opponentArchetypeId = const Value.absent(),
    this.onThePlay = const Value.absent(),
    this.gamesWon = const Value.absent(),
    this.gamesLost = const Value.absent(),
    this.gamesDrawn = const Value.absent(),
    this.result = const Value.absent(),
    this.playedAt = const Value.absent(),
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MatchesCompanion.insert({
    required String id,
    this.tournamentId = const Value.absent(),
    required String gameId,
    required String formatId,
    required String deckId,
    this.roundNumber = const Value.absent(),
    this.isTopCut = const Value.absent(),
    this.opponentName = const Value.absent(),
    this.opponentArchetypeId = const Value.absent(),
    this.onThePlay = const Value.absent(),
    this.gamesWon = const Value.absent(),
    this.gamesLost = const Value.absent(),
    this.gamesDrawn = const Value.absent(),
    required MatchResult result,
    required DateTime playedAt,
    this.notes = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       gameId = Value(gameId),
       formatId = Value(formatId),
       deckId = Value(deckId),
       result = Value(result),
       playedAt = Value(playedAt);
  static Insertable<Match> custom({
    Expression<String>? id,
    Expression<String>? tournamentId,
    Expression<String>? gameId,
    Expression<String>? formatId,
    Expression<String>? deckId,
    Expression<int>? roundNumber,
    Expression<bool>? isTopCut,
    Expression<String>? opponentName,
    Expression<String>? opponentArchetypeId,
    Expression<bool>? onThePlay,
    Expression<int>? gamesWon,
    Expression<int>? gamesLost,
    Expression<int>? gamesDrawn,
    Expression<String>? result,
    Expression<DateTime>? playedAt,
    Expression<String>? notes,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (tournamentId != null) 'tournament_id': tournamentId,
      if (gameId != null) 'game_id': gameId,
      if (formatId != null) 'format_id': formatId,
      if (deckId != null) 'deck_id': deckId,
      if (roundNumber != null) 'round_number': roundNumber,
      if (isTopCut != null) 'is_top_cut': isTopCut,
      if (opponentName != null) 'opponent_name': opponentName,
      if (opponentArchetypeId != null)
        'opponent_archetype_id': opponentArchetypeId,
      if (onThePlay != null) 'on_the_play': onThePlay,
      if (gamesWon != null) 'games_won': gamesWon,
      if (gamesLost != null) 'games_lost': gamesLost,
      if (gamesDrawn != null) 'games_drawn': gamesDrawn,
      if (result != null) 'result': result,
      if (playedAt != null) 'played_at': playedAt,
      if (notes != null) 'notes': notes,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MatchesCompanion copyWith({
    Value<String>? id,
    Value<String?>? tournamentId,
    Value<String>? gameId,
    Value<String>? formatId,
    Value<String>? deckId,
    Value<int?>? roundNumber,
    Value<bool>? isTopCut,
    Value<String?>? opponentName,
    Value<String?>? opponentArchetypeId,
    Value<bool?>? onThePlay,
    Value<int>? gamesWon,
    Value<int>? gamesLost,
    Value<int>? gamesDrawn,
    Value<MatchResult>? result,
    Value<DateTime>? playedAt,
    Value<String?>? notes,
    Value<int>? rowid,
  }) {
    return MatchesCompanion(
      id: id ?? this.id,
      tournamentId: tournamentId ?? this.tournamentId,
      gameId: gameId ?? this.gameId,
      formatId: formatId ?? this.formatId,
      deckId: deckId ?? this.deckId,
      roundNumber: roundNumber ?? this.roundNumber,
      isTopCut: isTopCut ?? this.isTopCut,
      opponentName: opponentName ?? this.opponentName,
      opponentArchetypeId: opponentArchetypeId ?? this.opponentArchetypeId,
      onThePlay: onThePlay ?? this.onThePlay,
      gamesWon: gamesWon ?? this.gamesWon,
      gamesLost: gamesLost ?? this.gamesLost,
      gamesDrawn: gamesDrawn ?? this.gamesDrawn,
      result: result ?? this.result,
      playedAt: playedAt ?? this.playedAt,
      notes: notes ?? this.notes,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (tournamentId.present) {
      map['tournament_id'] = Variable<String>(tournamentId.value);
    }
    if (gameId.present) {
      map['game_id'] = Variable<String>(gameId.value);
    }
    if (formatId.present) {
      map['format_id'] = Variable<String>(formatId.value);
    }
    if (deckId.present) {
      map['deck_id'] = Variable<String>(deckId.value);
    }
    if (roundNumber.present) {
      map['round_number'] = Variable<int>(roundNumber.value);
    }
    if (isTopCut.present) {
      map['is_top_cut'] = Variable<bool>(isTopCut.value);
    }
    if (opponentName.present) {
      map['opponent_name'] = Variable<String>(opponentName.value);
    }
    if (opponentArchetypeId.present) {
      map['opponent_archetype_id'] = Variable<String>(
        opponentArchetypeId.value,
      );
    }
    if (onThePlay.present) {
      map['on_the_play'] = Variable<bool>(onThePlay.value);
    }
    if (gamesWon.present) {
      map['games_won'] = Variable<int>(gamesWon.value);
    }
    if (gamesLost.present) {
      map['games_lost'] = Variable<int>(gamesLost.value);
    }
    if (gamesDrawn.present) {
      map['games_drawn'] = Variable<int>(gamesDrawn.value);
    }
    if (result.present) {
      map['result'] = Variable<String>(
        $MatchesTable.$converterresult.toSql(result.value),
      );
    }
    if (playedAt.present) {
      map['played_at'] = Variable<DateTime>(playedAt.value);
    }
    if (notes.present) {
      map['notes'] = Variable<String>(notes.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MatchesCompanion(')
          ..write('id: $id, ')
          ..write('tournamentId: $tournamentId, ')
          ..write('gameId: $gameId, ')
          ..write('formatId: $formatId, ')
          ..write('deckId: $deckId, ')
          ..write('roundNumber: $roundNumber, ')
          ..write('isTopCut: $isTopCut, ')
          ..write('opponentName: $opponentName, ')
          ..write('opponentArchetypeId: $opponentArchetypeId, ')
          ..write('onThePlay: $onThePlay, ')
          ..write('gamesWon: $gamesWon, ')
          ..write('gamesLost: $gamesLost, ')
          ..write('gamesDrawn: $gamesDrawn, ')
          ..write('result: $result, ')
          ..write('playedAt: $playedAt, ')
          ..write('notes: $notes, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $GamesTable games = $GamesTable(this);
  late final $FormatsTable formats = $FormatsTable(this);
  late final $DecksTable decks = $DecksTable(this);
  late final $DeckCardsTable deckCards = $DeckCardsTable(this);
  late final $OpponentArchetypesTable opponentArchetypes =
      $OpponentArchetypesTable(this);
  late final $TournamentsTable tournaments = $TournamentsTable(this);
  late final $MatchesTable matches = $MatchesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    games,
    formats,
    decks,
    deckCards,
    opponentArchetypes,
    tournaments,
    matches,
  ];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules([
    WritePropagation(
      on: TableUpdateQuery.onTableName(
        'decks',
        limitUpdateKind: UpdateKind.delete,
      ),
      result: [TableUpdate('deck_cards', kind: UpdateKind.delete)],
    ),
  ]);
}

typedef $$GamesTableCreateCompanionBuilder =
    GamesCompanion Function({
      required String id,
      required String name,
      Value<bool> isSystem,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$GamesTableUpdateCompanionBuilder =
    GamesCompanion Function({
      Value<String> id,
      Value<String> name,
      Value<bool> isSystem,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$GamesTableReferences
    extends BaseReferences<_$AppDatabase, $GamesTable, Game> {
  $$GamesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$FormatsTable, List<Format>> _formatsRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.formats,
    aliasName: 'games__id__formats__game_id',
  );

  $$FormatsTableProcessedTableManager get formatsRefs {
    final manager = $$FormatsTableTableManager(
      $_db,
      $_db.formats,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_formatsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$DecksTable, List<Deck>> _decksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.decks,
    aliasName: 'games__id__decks__game_id',
  );

  $$DecksTableProcessedTableManager get decksRefs {
    final manager = $$DecksTableTableManager(
      $_db,
      $_db.decks,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_decksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OpponentArchetypesTable, List<OpponentArchetype>>
  _opponentArchetypesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.opponentArchetypes,
        aliasName: 'games__id__opponent_archetypes__game_id',
      );

  $$OpponentArchetypesTableProcessedTableManager get opponentArchetypesRefs {
    final manager = $$OpponentArchetypesTableTableManager(
      $_db,
      $_db.opponentArchetypes,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _opponentArchetypesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TournamentsTable, List<Tournament>>
  _tournamentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tournaments,
    aliasName: 'games__id__tournaments__game_id',
  );

  $$TournamentsTableProcessedTableManager get tournamentsRefs {
    final manager = $$TournamentsTableTableManager(
      $_db,
      $_db.tournaments,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tournamentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MatchesTable, List<Match>> _matchesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.matches,
    aliasName: 'games__id__matches__game_id',
  );

  $$MatchesTableProcessedTableManager get matchesRefs {
    final manager = $$MatchesTableTableManager(
      $_db,
      $_db.matches,
    ).filter((f) => f.gameId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_matchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$GamesTableFilterComposer extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> formatsRefs(
    Expression<bool> Function($$FormatsTableFilterComposer f) f,
  ) {
    final $$FormatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.formats,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FormatsTableFilterComposer(
            $db: $db,
            $table: $db.formats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> decksRefs(
    Expression<bool> Function($$DecksTableFilterComposer f) f,
  ) {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableFilterComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> opponentArchetypesRefs(
    Expression<bool> Function($$OpponentArchetypesTableFilterComposer f) f,
  ) {
    final $$OpponentArchetypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.opponentArchetypes,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpponentArchetypesTableFilterComposer(
            $db: $db,
            $table: $db.opponentArchetypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tournamentsRefs(
    Expression<bool> Function($$TournamentsTableFilterComposer f) f,
  ) {
    final $$TournamentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentsTableFilterComposer(
            $db: $db,
            $table: $db.tournaments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> matchesRefs(
    Expression<bool> Function($$MatchesTableFilterComposer f) f,
  ) {
    final $$MatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableFilterComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableOrderingComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GamesTableAnnotationComposer
    extends Composer<_$AppDatabase, $GamesTable> {
  $$GamesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  Expression<T> formatsRefs<T extends Object>(
    Expression<T> Function($$FormatsTableAnnotationComposer a) f,
  ) {
    final $$FormatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.formats,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FormatsTableAnnotationComposer(
            $db: $db,
            $table: $db.formats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> decksRefs<T extends Object>(
    Expression<T> Function($$DecksTableAnnotationComposer a) f,
  ) {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableAnnotationComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> opponentArchetypesRefs<T extends Object>(
    Expression<T> Function($$OpponentArchetypesTableAnnotationComposer a) f,
  ) {
    final $$OpponentArchetypesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.opponentArchetypes,
          getReferencedColumn: (t) => t.gameId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OpponentArchetypesTableAnnotationComposer(
                $db: $db,
                $table: $db.opponentArchetypes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> tournamentsRefs<T extends Object>(
    Expression<T> Function($$TournamentsTableAnnotationComposer a) f,
  ) {
    final $$TournamentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentsTableAnnotationComposer(
            $db: $db,
            $table: $db.tournaments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> matchesRefs<T extends Object>(
    Expression<T> Function($$MatchesTableAnnotationComposer a) f,
  ) {
    final $$MatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.gameId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$GamesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $GamesTable,
          Game,
          $$GamesTableFilterComposer,
          $$GamesTableOrderingComposer,
          $$GamesTableAnnotationComposer,
          $$GamesTableCreateCompanionBuilder,
          $$GamesTableUpdateCompanionBuilder,
          (Game, $$GamesTableReferences),
          Game,
          PrefetchHooks Function({
            bool formatsRefs,
            bool decksRefs,
            bool opponentArchetypesRefs,
            bool tournamentsRefs,
            bool matchesRefs,
          })
        > {
  $$GamesTableTableManager(_$AppDatabase db, $GamesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GamesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GamesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GamesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GamesCompanion(
                id: id,
                name: name,
                isSystem: isSystem,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String name,
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GamesCompanion.insert(
                id: id,
                name: name,
                isSystem: isSystem,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$GamesTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                formatsRefs = false,
                decksRefs = false,
                opponentArchetypesRefs = false,
                tournamentsRefs = false,
                matchesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (formatsRefs) db.formats,
                    if (decksRefs) db.decks,
                    if (opponentArchetypesRefs) db.opponentArchetypes,
                    if (tournamentsRefs) db.tournaments,
                    if (matchesRefs) db.matches,
                  ],
                  addJoins: null,
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (formatsRefs)
                        await $_getPrefetchedData<Game, $GamesTable, Format>(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._formatsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(db, table, p0).formatsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (decksRefs)
                        await $_getPrefetchedData<Game, $GamesTable, Deck>(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._decksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(db, table, p0).decksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (opponentArchetypesRefs)
                        await $_getPrefetchedData<
                          Game,
                          $GamesTable,
                          OpponentArchetype
                        >(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._opponentArchetypesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).opponentArchetypesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tournamentsRefs)
                        await $_getPrefetchedData<
                          Game,
                          $GamesTable,
                          Tournament
                        >(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._tournamentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(
                                db,
                                table,
                                p0,
                              ).tournamentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (matchesRefs)
                        await $_getPrefetchedData<Game, $GamesTable, Match>(
                          currentTable: table,
                          referencedTable: $$GamesTableReferences
                              ._matchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$GamesTableReferences(db, table, p0).matchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.gameId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$GamesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $GamesTable,
      Game,
      $$GamesTableFilterComposer,
      $$GamesTableOrderingComposer,
      $$GamesTableAnnotationComposer,
      $$GamesTableCreateCompanionBuilder,
      $$GamesTableUpdateCompanionBuilder,
      (Game, $$GamesTableReferences),
      Game,
      PrefetchHooks Function({
        bool formatsRefs,
        bool decksRefs,
        bool opponentArchetypesRefs,
        bool tournamentsRefs,
        bool matchesRefs,
      })
    >;
typedef $$FormatsTableCreateCompanionBuilder =
    FormatsCompanion Function({
      required String id,
      required String gameId,
      required String name,
      Value<bool> isSystem,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$FormatsTableUpdateCompanionBuilder =
    FormatsCompanion Function({
      Value<String> id,
      Value<String> gameId,
      Value<String> name,
      Value<bool> isSystem,
      Value<bool> isActive,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$FormatsTableReferences
    extends BaseReferences<_$AppDatabase, $FormatsTable, Format> {
  $$FormatsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('formats__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DecksTable, List<Deck>> _decksRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.decks,
    aliasName: 'formats__id__decks__format_id',
  );

  $$DecksTableProcessedTableManager get decksRefs {
    final manager = $$DecksTableTableManager(
      $_db,
      $_db.decks,
    ).filter((f) => f.formatId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_decksRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$OpponentArchetypesTable, List<OpponentArchetype>>
  _opponentArchetypesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.opponentArchetypes,
        aliasName: 'formats__id__opponent_archetypes__format_id',
      );

  $$OpponentArchetypesTableProcessedTableManager get opponentArchetypesRefs {
    final manager = $$OpponentArchetypesTableTableManager(
      $_db,
      $_db.opponentArchetypes,
    ).filter((f) => f.formatId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _opponentArchetypesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TournamentsTable, List<Tournament>>
  _tournamentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tournaments,
    aliasName: 'formats__id__tournaments__format_id',
  );

  $$TournamentsTableProcessedTableManager get tournamentsRefs {
    final manager = $$TournamentsTableTableManager(
      $_db,
      $_db.tournaments,
    ).filter((f) => f.formatId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tournamentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MatchesTable, List<Match>> _matchesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.matches,
    aliasName: 'formats__id__matches__format_id',
  );

  $$MatchesTableProcessedTableManager get matchesRefs {
    final manager = $$MatchesTableTableManager(
      $_db,
      $_db.matches,
    ).filter((f) => f.formatId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_matchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$FormatsTableFilterComposer
    extends Composer<_$AppDatabase, $FormatsTable> {
  $$FormatsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> decksRefs(
    Expression<bool> Function($$DecksTableFilterComposer f) f,
  ) {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.formatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableFilterComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> opponentArchetypesRefs(
    Expression<bool> Function($$OpponentArchetypesTableFilterComposer f) f,
  ) {
    final $$OpponentArchetypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.opponentArchetypes,
      getReferencedColumn: (t) => t.formatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpponentArchetypesTableFilterComposer(
            $db: $db,
            $table: $db.opponentArchetypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tournamentsRefs(
    Expression<bool> Function($$TournamentsTableFilterComposer f) f,
  ) {
    final $$TournamentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.formatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentsTableFilterComposer(
            $db: $db,
            $table: $db.tournaments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> matchesRefs(
    Expression<bool> Function($$MatchesTableFilterComposer f) f,
  ) {
    final $$MatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.formatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableFilterComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FormatsTableOrderingComposer
    extends Composer<_$AppDatabase, $FormatsTable> {
  $$FormatsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isSystem => $composableBuilder(
    column: $table.isSystem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$FormatsTableAnnotationComposer
    extends Composer<_$AppDatabase, $FormatsTable> {
  $$FormatsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<bool> get isSystem =>
      $composableBuilder(column: $table.isSystem, builder: (column) => column);

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> decksRefs<T extends Object>(
    Expression<T> Function($$DecksTableAnnotationComposer a) f,
  ) {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.formatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableAnnotationComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> opponentArchetypesRefs<T extends Object>(
    Expression<T> Function($$OpponentArchetypesTableAnnotationComposer a) f,
  ) {
    final $$OpponentArchetypesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.opponentArchetypes,
          getReferencedColumn: (t) => t.formatId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OpponentArchetypesTableAnnotationComposer(
                $db: $db,
                $table: $db.opponentArchetypes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }

  Expression<T> tournamentsRefs<T extends Object>(
    Expression<T> Function($$TournamentsTableAnnotationComposer a) f,
  ) {
    final $$TournamentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.formatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentsTableAnnotationComposer(
            $db: $db,
            $table: $db.tournaments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> matchesRefs<T extends Object>(
    Expression<T> Function($$MatchesTableAnnotationComposer a) f,
  ) {
    final $$MatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.formatId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$FormatsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $FormatsTable,
          Format,
          $$FormatsTableFilterComposer,
          $$FormatsTableOrderingComposer,
          $$FormatsTableAnnotationComposer,
          $$FormatsTableCreateCompanionBuilder,
          $$FormatsTableUpdateCompanionBuilder,
          (Format, $$FormatsTableReferences),
          Format,
          PrefetchHooks Function({
            bool gameId,
            bool decksRefs,
            bool opponentArchetypesRefs,
            bool tournamentsRefs,
            bool matchesRefs,
          })
        > {
  $$FormatsTableTableManager(_$AppDatabase db, $FormatsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FormatsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FormatsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FormatsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FormatsCompanion(
                id: id,
                gameId: gameId,
                name: name,
                isSystem: isSystem,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gameId,
                required String name,
                Value<bool> isSystem = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FormatsCompanion.insert(
                id: id,
                gameId: gameId,
                name: name,
                isSystem: isSystem,
                isActive: isActive,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$FormatsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gameId = false,
                decksRefs = false,
                opponentArchetypesRefs = false,
                tournamentsRefs = false,
                matchesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (decksRefs) db.decks,
                    if (opponentArchetypesRefs) db.opponentArchetypes,
                    if (tournamentsRefs) db.tournaments,
                    if (matchesRefs) db.matches,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (gameId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gameId,
                                    referencedTable: $$FormatsTableReferences
                                        ._gameIdTable(db),
                                    referencedColumn: $$FormatsTableReferences
                                        ._gameIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (decksRefs)
                        await $_getPrefetchedData<Format, $FormatsTable, Deck>(
                          currentTable: table,
                          referencedTable: $$FormatsTableReferences
                              ._decksRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FormatsTableReferences(db, table, p0).decksRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.formatId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (opponentArchetypesRefs)
                        await $_getPrefetchedData<
                          Format,
                          $FormatsTable,
                          OpponentArchetype
                        >(
                          currentTable: table,
                          referencedTable: $$FormatsTableReferences
                              ._opponentArchetypesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FormatsTableReferences(
                                db,
                                table,
                                p0,
                              ).opponentArchetypesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.formatId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tournamentsRefs)
                        await $_getPrefetchedData<
                          Format,
                          $FormatsTable,
                          Tournament
                        >(
                          currentTable: table,
                          referencedTable: $$FormatsTableReferences
                              ._tournamentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FormatsTableReferences(
                                db,
                                table,
                                p0,
                              ).tournamentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.formatId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (matchesRefs)
                        await $_getPrefetchedData<Format, $FormatsTable, Match>(
                          currentTable: table,
                          referencedTable: $$FormatsTableReferences
                              ._matchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$FormatsTableReferences(
                                db,
                                table,
                                p0,
                              ).matchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.formatId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$FormatsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $FormatsTable,
      Format,
      $$FormatsTableFilterComposer,
      $$FormatsTableOrderingComposer,
      $$FormatsTableAnnotationComposer,
      $$FormatsTableCreateCompanionBuilder,
      $$FormatsTableUpdateCompanionBuilder,
      (Format, $$FormatsTableReferences),
      Format,
      PrefetchHooks Function({
        bool gameId,
        bool decksRefs,
        bool opponentArchetypesRefs,
        bool tournamentsRefs,
        bool matchesRefs,
      })
    >;
typedef $$DecksTableCreateCompanionBuilder =
    DecksCompanion Function({
      required String id,
      required String gameId,
      required String formatId,
      required String name,
      required String archetype,
      Value<String?> colors,
      Value<String?> notes,
      Value<Uint8List?> photo,
      Value<String?> photoMimeType,
      Value<bool> isActive,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$DecksTableUpdateCompanionBuilder =
    DecksCompanion Function({
      Value<String> id,
      Value<String> gameId,
      Value<String> formatId,
      Value<String> name,
      Value<String> archetype,
      Value<String?> colors,
      Value<String?> notes,
      Value<Uint8List?> photo,
      Value<String?> photoMimeType,
      Value<bool> isActive,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$DecksTableReferences
    extends BaseReferences<_$AppDatabase, $DecksTable, Deck> {
  $$DecksTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('decks__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FormatsTable _formatIdTable(_$AppDatabase db) =>
      db.formats.createAlias('decks__format_id__formats__id');

  $$FormatsTableProcessedTableManager get formatId {
    final $_column = $_itemColumn<String>('format_id')!;

    final manager = $$FormatsTableTableManager(
      $_db,
      $_db.formats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_formatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$DeckCardsTable, List<DeckCard>>
  _deckCardsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.deckCards,
    aliasName: 'decks__id__deck_cards__deck_id',
  );

  $$DeckCardsTableProcessedTableManager get deckCardsRefs {
    final manager = $$DeckCardsTableTableManager(
      $_db,
      $_db.deckCards,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_deckCardsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$TournamentsTable, List<Tournament>>
  _tournamentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.tournaments,
    aliasName: 'decks__id__tournaments__deck_id',
  );

  $$TournamentsTableProcessedTableManager get tournamentsRefs {
    final manager = $$TournamentsTableTableManager(
      $_db,
      $_db.tournaments,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_tournamentsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$MatchesTable, List<Match>> _matchesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.matches,
    aliasName: 'decks__id__matches__deck_id',
  );

  $$MatchesTableProcessedTableManager get matchesRefs {
    final manager = $$MatchesTableTableManager(
      $_db,
      $_db.matches,
    ).filter((f) => f.deckId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_matchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$DecksTableFilterComposer extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get archetype => $composableBuilder(
    column: $table.archetype,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get colors => $composableBuilder(
    column: $table.colors,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get photoMimeType => $composableBuilder(
    column: $table.photoMimeType,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FormatsTableFilterComposer get formatId {
    final $$FormatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.formatId,
      referencedTable: $db.formats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FormatsTableFilterComposer(
            $db: $db,
            $table: $db.formats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> deckCardsRefs(
    Expression<bool> Function($$DeckCardsTableFilterComposer f) f,
  ) {
    final $$DeckCardsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deckCards,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeckCardsTableFilterComposer(
            $db: $db,
            $table: $db.deckCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> tournamentsRefs(
    Expression<bool> Function($$TournamentsTableFilterComposer f) f,
  ) {
    final $$TournamentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentsTableFilterComposer(
            $db: $db,
            $table: $db.tournaments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> matchesRefs(
    Expression<bool> Function($$MatchesTableFilterComposer f) f,
  ) {
    final $$MatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableFilterComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecksTableOrderingComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get archetype => $composableBuilder(
    column: $table.archetype,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get colors => $composableBuilder(
    column: $table.colors,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get photo => $composableBuilder(
    column: $table.photo,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get photoMimeType => $composableBuilder(
    column: $table.photoMimeType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isActive => $composableBuilder(
    column: $table.isActive,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FormatsTableOrderingComposer get formatId {
    final $$FormatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.formatId,
      referencedTable: $db.formats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FormatsTableOrderingComposer(
            $db: $db,
            $table: $db.formats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DecksTableAnnotationComposer
    extends Composer<_$AppDatabase, $DecksTable> {
  $$DecksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get archetype =>
      $composableBuilder(column: $table.archetype, builder: (column) => column);

  GeneratedColumn<String> get colors =>
      $composableBuilder(column: $table.colors, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<Uint8List> get photo =>
      $composableBuilder(column: $table.photo, builder: (column) => column);

  GeneratedColumn<String> get photoMimeType => $composableBuilder(
    column: $table.photoMimeType,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isActive =>
      $composableBuilder(column: $table.isActive, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FormatsTableAnnotationComposer get formatId {
    final $$FormatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.formatId,
      referencedTable: $db.formats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FormatsTableAnnotationComposer(
            $db: $db,
            $table: $db.formats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> deckCardsRefs<T extends Object>(
    Expression<T> Function($$DeckCardsTableAnnotationComposer a) f,
  ) {
    final $$DeckCardsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.deckCards,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DeckCardsTableAnnotationComposer(
            $db: $db,
            $table: $db.deckCards,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> tournamentsRefs<T extends Object>(
    Expression<T> Function($$TournamentsTableAnnotationComposer a) f,
  ) {
    final $$TournamentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentsTableAnnotationComposer(
            $db: $db,
            $table: $db.tournaments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> matchesRefs<T extends Object>(
    Expression<T> Function($$MatchesTableAnnotationComposer a) f,
  ) {
    final $$MatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.deckId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$DecksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DecksTable,
          Deck,
          $$DecksTableFilterComposer,
          $$DecksTableOrderingComposer,
          $$DecksTableAnnotationComposer,
          $$DecksTableCreateCompanionBuilder,
          $$DecksTableUpdateCompanionBuilder,
          (Deck, $$DecksTableReferences),
          Deck,
          PrefetchHooks Function({
            bool gameId,
            bool formatId,
            bool deckCardsRefs,
            bool tournamentsRefs,
            bool matchesRefs,
          })
        > {
  $$DecksTableTableManager(_$AppDatabase db, $DecksTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DecksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DecksTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DecksTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String> formatId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> archetype = const Value.absent(),
                Value<String?> colors = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<Uint8List?> photo = const Value.absent(),
                Value<String?> photoMimeType = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion(
                id: id,
                gameId: gameId,
                formatId: formatId,
                name: name,
                archetype: archetype,
                colors: colors,
                notes: notes,
                photo: photo,
                photoMimeType: photoMimeType,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gameId,
                required String formatId,
                required String name,
                required String archetype,
                Value<String?> colors = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<Uint8List?> photo = const Value.absent(),
                Value<String?> photoMimeType = const Value.absent(),
                Value<bool> isActive = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => DecksCompanion.insert(
                id: id,
                gameId: gameId,
                formatId: formatId,
                name: name,
                archetype: archetype,
                colors: colors,
                notes: notes,
                photo: photo,
                photoMimeType: photoMimeType,
                isActive: isActive,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) =>
                    (e.readTable(table), $$DecksTableReferences(db, table, e)),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gameId = false,
                formatId = false,
                deckCardsRefs = false,
                tournamentsRefs = false,
                matchesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (deckCardsRefs) db.deckCards,
                    if (tournamentsRefs) db.tournaments,
                    if (matchesRefs) db.matches,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (gameId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gameId,
                                    referencedTable: $$DecksTableReferences
                                        ._gameIdTable(db),
                                    referencedColumn: $$DecksTableReferences
                                        ._gameIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (formatId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.formatId,
                                    referencedTable: $$DecksTableReferences
                                        ._formatIdTable(db),
                                    referencedColumn: $$DecksTableReferences
                                        ._formatIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (deckCardsRefs)
                        await $_getPrefetchedData<Deck, $DecksTable, DeckCard>(
                          currentTable: table,
                          referencedTable: $$DecksTableReferences
                              ._deckCardsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DecksTableReferences(
                                db,
                                table,
                                p0,
                              ).deckCardsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deckId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (tournamentsRefs)
                        await $_getPrefetchedData<
                          Deck,
                          $DecksTable,
                          Tournament
                        >(
                          currentTable: table,
                          referencedTable: $$DecksTableReferences
                              ._tournamentsRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DecksTableReferences(
                                db,
                                table,
                                p0,
                              ).tournamentsRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deckId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (matchesRefs)
                        await $_getPrefetchedData<Deck, $DecksTable, Match>(
                          currentTable: table,
                          referencedTable: $$DecksTableReferences
                              ._matchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$DecksTableReferences(db, table, p0).matchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.deckId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$DecksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DecksTable,
      Deck,
      $$DecksTableFilterComposer,
      $$DecksTableOrderingComposer,
      $$DecksTableAnnotationComposer,
      $$DecksTableCreateCompanionBuilder,
      $$DecksTableUpdateCompanionBuilder,
      (Deck, $$DecksTableReferences),
      Deck,
      PrefetchHooks Function({
        bool gameId,
        bool formatId,
        bool deckCardsRefs,
        bool tournamentsRefs,
        bool matchesRefs,
      })
    >;
typedef $$DeckCardsTableCreateCompanionBuilder =
    DeckCardsCompanion Function({
      required String id,
      required String deckId,
      required DeckSection section,
      required String name,
      Value<int> quantity,
      Value<int> sortOrder,
      Value<int> rowid,
    });
typedef $$DeckCardsTableUpdateCompanionBuilder =
    DeckCardsCompanion Function({
      Value<String> id,
      Value<String> deckId,
      Value<DeckSection> section,
      Value<String> name,
      Value<int> quantity,
      Value<int> sortOrder,
      Value<int> rowid,
    });

final class $$DeckCardsTableReferences
    extends BaseReferences<_$AppDatabase, $DeckCardsTable, DeckCard> {
  $$DeckCardsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $DecksTable _deckIdTable(_$AppDatabase db) =>
      db.decks.createAlias('deck_cards__deck_id__decks__id');

  $$DecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<String>('deck_id')!;

    final manager = $$DecksTableTableManager(
      $_db,
      $_db.decks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$DeckCardsTableFilterComposer
    extends Composer<_$AppDatabase, $DeckCardsTable> {
  $$DeckCardsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<DeckSection, DeckSection, String>
  get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnFilters(column),
  );

  $$DecksTableFilterComposer get deckId {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableFilterComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeckCardsTableOrderingComposer
    extends Composer<_$AppDatabase, $DeckCardsTable> {
  $$DeckCardsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get section => $composableBuilder(
    column: $table.section,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get quantity => $composableBuilder(
    column: $table.quantity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get sortOrder => $composableBuilder(
    column: $table.sortOrder,
    builder: (column) => ColumnOrderings(column),
  );

  $$DecksTableOrderingComposer get deckId {
    final $$DecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableOrderingComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeckCardsTableAnnotationComposer
    extends Composer<_$AppDatabase, $DeckCardsTable> {
  $$DeckCardsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumnWithTypeConverter<DeckSection, String> get section =>
      $composableBuilder(column: $table.section, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get quantity =>
      $composableBuilder(column: $table.quantity, builder: (column) => column);

  GeneratedColumn<int> get sortOrder =>
      $composableBuilder(column: $table.sortOrder, builder: (column) => column);

  $$DecksTableAnnotationComposer get deckId {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableAnnotationComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$DeckCardsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $DeckCardsTable,
          DeckCard,
          $$DeckCardsTableFilterComposer,
          $$DeckCardsTableOrderingComposer,
          $$DeckCardsTableAnnotationComposer,
          $$DeckCardsTableCreateCompanionBuilder,
          $$DeckCardsTableUpdateCompanionBuilder,
          (DeckCard, $$DeckCardsTableReferences),
          DeckCard,
          PrefetchHooks Function({bool deckId})
        > {
  $$DeckCardsTableTableManager(_$AppDatabase db, $DeckCardsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DeckCardsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DeckCardsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DeckCardsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> deckId = const Value.absent(),
                Value<DeckSection> section = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> quantity = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeckCardsCompanion(
                id: id,
                deckId: deckId,
                section: section,
                name: name,
                quantity: quantity,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String deckId,
                required DeckSection section,
                required String name,
                Value<int> quantity = const Value.absent(),
                Value<int> sortOrder = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => DeckCardsCompanion.insert(
                id: id,
                deckId: deckId,
                section: section,
                name: name,
                quantity: quantity,
                sortOrder: sortOrder,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$DeckCardsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({deckId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (deckId) {
                      state =
                          state.withJoin(
                                currentTable: table,
                                currentColumn: table.deckId,
                                referencedTable: $$DeckCardsTableReferences
                                    ._deckIdTable(db),
                                referencedColumn: $$DeckCardsTableReferences
                                    ._deckIdTable(db)
                                    .id,
                              )
                              as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$DeckCardsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $DeckCardsTable,
      DeckCard,
      $$DeckCardsTableFilterComposer,
      $$DeckCardsTableOrderingComposer,
      $$DeckCardsTableAnnotationComposer,
      $$DeckCardsTableCreateCompanionBuilder,
      $$DeckCardsTableUpdateCompanionBuilder,
      (DeckCard, $$DeckCardsTableReferences),
      DeckCard,
      PrefetchHooks Function({bool deckId})
    >;
typedef $$OpponentArchetypesTableCreateCompanionBuilder =
    OpponentArchetypesCompanion Function({
      required String id,
      required String gameId,
      required String formatId,
      required String name,
      Value<int> timesFaced,
      Value<int> rowid,
    });
typedef $$OpponentArchetypesTableUpdateCompanionBuilder =
    OpponentArchetypesCompanion Function({
      Value<String> id,
      Value<String> gameId,
      Value<String> formatId,
      Value<String> name,
      Value<int> timesFaced,
      Value<int> rowid,
    });

final class $$OpponentArchetypesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $OpponentArchetypesTable,
          OpponentArchetype
        > {
  $$OpponentArchetypesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('opponent_archetypes__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FormatsTable _formatIdTable(_$AppDatabase db) =>
      db.formats.createAlias('opponent_archetypes__format_id__formats__id');

  $$FormatsTableProcessedTableManager get formatId {
    final $_column = $_itemColumn<String>('format_id')!;

    final manager = $$FormatsTableTableManager(
      $_db,
      $_db.formats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_formatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MatchesTable, List<Match>> _matchesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.matches,
    aliasName: 'opponent_archetypes__id__matches__opponent_archetype_id',
  );

  $$MatchesTableProcessedTableManager get matchesRefs {
    final manager = $$MatchesTableTableManager($_db, $_db.matches).filter(
      (f) => f.opponentArchetypeId.id.sqlEquals($_itemColumn<String>('id')!),
    );

    final cache = $_typedResult.readTableOrNull(_matchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$OpponentArchetypesTableFilterComposer
    extends Composer<_$AppDatabase, $OpponentArchetypesTable> {
  $$OpponentArchetypesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get timesFaced => $composableBuilder(
    column: $table.timesFaced,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FormatsTableFilterComposer get formatId {
    final $$FormatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.formatId,
      referencedTable: $db.formats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FormatsTableFilterComposer(
            $db: $db,
            $table: $db.formats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> matchesRefs(
    Expression<bool> Function($$MatchesTableFilterComposer f) f,
  ) {
    final $$MatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.opponentArchetypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableFilterComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OpponentArchetypesTableOrderingComposer
    extends Composer<_$AppDatabase, $OpponentArchetypesTable> {
  $$OpponentArchetypesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get timesFaced => $composableBuilder(
    column: $table.timesFaced,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FormatsTableOrderingComposer get formatId {
    final $$FormatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.formatId,
      referencedTable: $db.formats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FormatsTableOrderingComposer(
            $db: $db,
            $table: $db.formats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$OpponentArchetypesTableAnnotationComposer
    extends Composer<_$AppDatabase, $OpponentArchetypesTable> {
  $$OpponentArchetypesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get timesFaced => $composableBuilder(
    column: $table.timesFaced,
    builder: (column) => column,
  );

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FormatsTableAnnotationComposer get formatId {
    final $$FormatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.formatId,
      referencedTable: $db.formats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FormatsTableAnnotationComposer(
            $db: $db,
            $table: $db.formats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> matchesRefs<T extends Object>(
    Expression<T> Function($$MatchesTableAnnotationComposer a) f,
  ) {
    final $$MatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.opponentArchetypeId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$OpponentArchetypesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OpponentArchetypesTable,
          OpponentArchetype,
          $$OpponentArchetypesTableFilterComposer,
          $$OpponentArchetypesTableOrderingComposer,
          $$OpponentArchetypesTableAnnotationComposer,
          $$OpponentArchetypesTableCreateCompanionBuilder,
          $$OpponentArchetypesTableUpdateCompanionBuilder,
          (OpponentArchetype, $$OpponentArchetypesTableReferences),
          OpponentArchetype,
          PrefetchHooks Function({bool gameId, bool formatId, bool matchesRefs})
        > {
  $$OpponentArchetypesTableTableManager(
    _$AppDatabase db,
    $OpponentArchetypesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OpponentArchetypesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OpponentArchetypesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OpponentArchetypesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String> formatId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> timesFaced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OpponentArchetypesCompanion(
                id: id,
                gameId: gameId,
                formatId: formatId,
                name: name,
                timesFaced: timesFaced,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gameId,
                required String formatId,
                required String name,
                Value<int> timesFaced = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OpponentArchetypesCompanion.insert(
                id: id,
                gameId: gameId,
                formatId: formatId,
                name: name,
                timesFaced: timesFaced,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$OpponentArchetypesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({gameId = false, formatId = false, matchesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (matchesRefs) db.matches],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (gameId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gameId,
                                    referencedTable:
                                        $$OpponentArchetypesTableReferences
                                            ._gameIdTable(db),
                                    referencedColumn:
                                        $$OpponentArchetypesTableReferences
                                            ._gameIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (formatId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.formatId,
                                    referencedTable:
                                        $$OpponentArchetypesTableReferences
                                            ._formatIdTable(db),
                                    referencedColumn:
                                        $$OpponentArchetypesTableReferences
                                            ._formatIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (matchesRefs)
                        await $_getPrefetchedData<
                          OpponentArchetype,
                          $OpponentArchetypesTable,
                          Match
                        >(
                          currentTable: table,
                          referencedTable: $$OpponentArchetypesTableReferences
                              ._matchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$OpponentArchetypesTableReferences(
                                db,
                                table,
                                p0,
                              ).matchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.opponentArchetypeId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$OpponentArchetypesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OpponentArchetypesTable,
      OpponentArchetype,
      $$OpponentArchetypesTableFilterComposer,
      $$OpponentArchetypesTableOrderingComposer,
      $$OpponentArchetypesTableAnnotationComposer,
      $$OpponentArchetypesTableCreateCompanionBuilder,
      $$OpponentArchetypesTableUpdateCompanionBuilder,
      (OpponentArchetype, $$OpponentArchetypesTableReferences),
      OpponentArchetype,
      PrefetchHooks Function({bool gameId, bool formatId, bool matchesRefs})
    >;
typedef $$TournamentsTableCreateCompanionBuilder =
    TournamentsCompanion Function({
      required String id,
      required String gameId,
      required String formatId,
      required String deckId,
      required String name,
      required DateTime date,
      required EventType eventType,
      Value<int?> participantCount,
      required int roundsPlanned,
      Value<bool> hasTopCut,
      Value<int?> topCutSize,
      Value<int?> finalStanding,
      required TournamentStatus status,
      Value<String?> notes,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$TournamentsTableUpdateCompanionBuilder =
    TournamentsCompanion Function({
      Value<String> id,
      Value<String> gameId,
      Value<String> formatId,
      Value<String> deckId,
      Value<String> name,
      Value<DateTime> date,
      Value<EventType> eventType,
      Value<int?> participantCount,
      Value<int> roundsPlanned,
      Value<bool> hasTopCut,
      Value<int?> topCutSize,
      Value<int?> finalStanding,
      Value<TournamentStatus> status,
      Value<String?> notes,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

final class $$TournamentsTableReferences
    extends BaseReferences<_$AppDatabase, $TournamentsTable, Tournament> {
  $$TournamentsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('tournaments__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FormatsTable _formatIdTable(_$AppDatabase db) =>
      db.formats.createAlias('tournaments__format_id__formats__id');

  $$FormatsTableProcessedTableManager get formatId {
    final $_column = $_itemColumn<String>('format_id')!;

    final manager = $$FormatsTableTableManager(
      $_db,
      $_db.formats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_formatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DecksTable _deckIdTable(_$AppDatabase db) =>
      db.decks.createAlias('tournaments__deck_id__decks__id');

  $$DecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<String>('deck_id')!;

    final manager = $$DecksTableTableManager(
      $_db,
      $_db.decks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$MatchesTable, List<Match>> _matchesRefsTable(
    _$AppDatabase db,
  ) => MultiTypedResultKey.fromTable(
    db.matches,
    aliasName: 'tournaments__id__matches__tournament_id',
  );

  $$MatchesTableProcessedTableManager get matchesRefs {
    final manager = $$MatchesTableTableManager(
      $_db,
      $_db.matches,
    ).filter((f) => f.tournamentId.id.sqlEquals($_itemColumn<String>('id')!));

    final cache = $_typedResult.readTableOrNull(_matchesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$TournamentsTableFilterComposer
    extends Composer<_$AppDatabase, $TournamentsTable> {
  $$TournamentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<EventType, EventType, String> get eventType =>
      $composableBuilder(
        column: $table.eventType,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<int> get participantCount => $composableBuilder(
    column: $table.participantCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roundsPlanned => $composableBuilder(
    column: $table.roundsPlanned,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get hasTopCut => $composableBuilder(
    column: $table.hasTopCut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get topCutSize => $composableBuilder(
    column: $table.topCutSize,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get finalStanding => $composableBuilder(
    column: $table.finalStanding,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<TournamentStatus, TournamentStatus, String>
  get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnWithTypeConverterFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FormatsTableFilterComposer get formatId {
    final $$FormatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.formatId,
      referencedTable: $db.formats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FormatsTableFilterComposer(
            $db: $db,
            $table: $db.formats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DecksTableFilterComposer get deckId {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableFilterComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> matchesRefs(
    Expression<bool> Function($$MatchesTableFilterComposer f) f,
  ) {
    final $$MatchesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.tournamentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableFilterComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TournamentsTableOrderingComposer
    extends Composer<_$AppDatabase, $TournamentsTable> {
  $$TournamentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get date => $composableBuilder(
    column: $table.date,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get eventType => $composableBuilder(
    column: $table.eventType,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get participantCount => $composableBuilder(
    column: $table.participantCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roundsPlanned => $composableBuilder(
    column: $table.roundsPlanned,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get hasTopCut => $composableBuilder(
    column: $table.hasTopCut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get topCutSize => $composableBuilder(
    column: $table.topCutSize,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get finalStanding => $composableBuilder(
    column: $table.finalStanding,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FormatsTableOrderingComposer get formatId {
    final $$FormatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.formatId,
      referencedTable: $db.formats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FormatsTableOrderingComposer(
            $db: $db,
            $table: $db.formats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DecksTableOrderingComposer get deckId {
    final $$DecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableOrderingComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$TournamentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $TournamentsTable> {
  $$TournamentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumnWithTypeConverter<EventType, String> get eventType =>
      $composableBuilder(column: $table.eventType, builder: (column) => column);

  GeneratedColumn<int> get participantCount => $composableBuilder(
    column: $table.participantCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get roundsPlanned => $composableBuilder(
    column: $table.roundsPlanned,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get hasTopCut =>
      $composableBuilder(column: $table.hasTopCut, builder: (column) => column);

  GeneratedColumn<int> get topCutSize => $composableBuilder(
    column: $table.topCutSize,
    builder: (column) => column,
  );

  GeneratedColumn<int> get finalStanding => $composableBuilder(
    column: $table.finalStanding,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<TournamentStatus, String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FormatsTableAnnotationComposer get formatId {
    final $$FormatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.formatId,
      referencedTable: $db.formats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FormatsTableAnnotationComposer(
            $db: $db,
            $table: $db.formats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DecksTableAnnotationComposer get deckId {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableAnnotationComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> matchesRefs<T extends Object>(
    Expression<T> Function($$MatchesTableAnnotationComposer a) f,
  ) {
    final $$MatchesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.matches,
      getReferencedColumn: (t) => t.tournamentId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MatchesTableAnnotationComposer(
            $db: $db,
            $table: $db.matches,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$TournamentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $TournamentsTable,
          Tournament,
          $$TournamentsTableFilterComposer,
          $$TournamentsTableOrderingComposer,
          $$TournamentsTableAnnotationComposer,
          $$TournamentsTableCreateCompanionBuilder,
          $$TournamentsTableUpdateCompanionBuilder,
          (Tournament, $$TournamentsTableReferences),
          Tournament,
          PrefetchHooks Function({
            bool gameId,
            bool formatId,
            bool deckId,
            bool matchesRefs,
          })
        > {
  $$TournamentsTableTableManager(_$AppDatabase db, $TournamentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TournamentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TournamentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TournamentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String> formatId = const Value.absent(),
                Value<String> deckId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> date = const Value.absent(),
                Value<EventType> eventType = const Value.absent(),
                Value<int?> participantCount = const Value.absent(),
                Value<int> roundsPlanned = const Value.absent(),
                Value<bool> hasTopCut = const Value.absent(),
                Value<int?> topCutSize = const Value.absent(),
                Value<int?> finalStanding = const Value.absent(),
                Value<TournamentStatus> status = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TournamentsCompanion(
                id: id,
                gameId: gameId,
                formatId: formatId,
                deckId: deckId,
                name: name,
                date: date,
                eventType: eventType,
                participantCount: participantCount,
                roundsPlanned: roundsPlanned,
                hasTopCut: hasTopCut,
                topCutSize: topCutSize,
                finalStanding: finalStanding,
                status: status,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String gameId,
                required String formatId,
                required String deckId,
                required String name,
                required DateTime date,
                required EventType eventType,
                Value<int?> participantCount = const Value.absent(),
                required int roundsPlanned,
                Value<bool> hasTopCut = const Value.absent(),
                Value<int?> topCutSize = const Value.absent(),
                Value<int?> finalStanding = const Value.absent(),
                required TournamentStatus status,
                Value<String?> notes = const Value.absent(),
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => TournamentsCompanion.insert(
                id: id,
                gameId: gameId,
                formatId: formatId,
                deckId: deckId,
                name: name,
                date: date,
                eventType: eventType,
                participantCount: participantCount,
                roundsPlanned: roundsPlanned,
                hasTopCut: hasTopCut,
                topCutSize: topCutSize,
                finalStanding: finalStanding,
                status: status,
                notes: notes,
                createdAt: createdAt,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$TournamentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                gameId = false,
                formatId = false,
                deckId = false,
                matchesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [if (matchesRefs) db.matches],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (gameId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gameId,
                                    referencedTable:
                                        $$TournamentsTableReferences
                                            ._gameIdTable(db),
                                    referencedColumn:
                                        $$TournamentsTableReferences
                                            ._gameIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (formatId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.formatId,
                                    referencedTable:
                                        $$TournamentsTableReferences
                                            ._formatIdTable(db),
                                    referencedColumn:
                                        $$TournamentsTableReferences
                                            ._formatIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }
                        if (deckId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.deckId,
                                    referencedTable:
                                        $$TournamentsTableReferences
                                            ._deckIdTable(db),
                                    referencedColumn:
                                        $$TournamentsTableReferences
                                            ._deckIdTable(db)
                                            .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (matchesRefs)
                        await $_getPrefetchedData<
                          Tournament,
                          $TournamentsTable,
                          Match
                        >(
                          currentTable: table,
                          referencedTable: $$TournamentsTableReferences
                              ._matchesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$TournamentsTableReferences(
                                db,
                                table,
                                p0,
                              ).matchesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.tournamentId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$TournamentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $TournamentsTable,
      Tournament,
      $$TournamentsTableFilterComposer,
      $$TournamentsTableOrderingComposer,
      $$TournamentsTableAnnotationComposer,
      $$TournamentsTableCreateCompanionBuilder,
      $$TournamentsTableUpdateCompanionBuilder,
      (Tournament, $$TournamentsTableReferences),
      Tournament,
      PrefetchHooks Function({
        bool gameId,
        bool formatId,
        bool deckId,
        bool matchesRefs,
      })
    >;
typedef $$MatchesTableCreateCompanionBuilder =
    MatchesCompanion Function({
      required String id,
      Value<String?> tournamentId,
      required String gameId,
      required String formatId,
      required String deckId,
      Value<int?> roundNumber,
      Value<bool> isTopCut,
      Value<String?> opponentName,
      Value<String?> opponentArchetypeId,
      Value<bool?> onThePlay,
      Value<int> gamesWon,
      Value<int> gamesLost,
      Value<int> gamesDrawn,
      required MatchResult result,
      required DateTime playedAt,
      Value<String?> notes,
      Value<int> rowid,
    });
typedef $$MatchesTableUpdateCompanionBuilder =
    MatchesCompanion Function({
      Value<String> id,
      Value<String?> tournamentId,
      Value<String> gameId,
      Value<String> formatId,
      Value<String> deckId,
      Value<int?> roundNumber,
      Value<bool> isTopCut,
      Value<String?> opponentName,
      Value<String?> opponentArchetypeId,
      Value<bool?> onThePlay,
      Value<int> gamesWon,
      Value<int> gamesLost,
      Value<int> gamesDrawn,
      Value<MatchResult> result,
      Value<DateTime> playedAt,
      Value<String?> notes,
      Value<int> rowid,
    });

final class $$MatchesTableReferences
    extends BaseReferences<_$AppDatabase, $MatchesTable, Match> {
  $$MatchesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $TournamentsTable _tournamentIdTable(_$AppDatabase db) =>
      db.tournaments.createAlias('matches__tournament_id__tournaments__id');

  $$TournamentsTableProcessedTableManager? get tournamentId {
    final $_column = $_itemColumn<String>('tournament_id');
    if ($_column == null) return null;
    final manager = $$TournamentsTableTableManager(
      $_db,
      $_db.tournaments,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tournamentIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $GamesTable _gameIdTable(_$AppDatabase db) =>
      db.games.createAlias('matches__game_id__games__id');

  $$GamesTableProcessedTableManager get gameId {
    final $_column = $_itemColumn<String>('game_id')!;

    final manager = $$GamesTableTableManager(
      $_db,
      $_db.games,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_gameIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $FormatsTable _formatIdTable(_$AppDatabase db) =>
      db.formats.createAlias('matches__format_id__formats__id');

  $$FormatsTableProcessedTableManager get formatId {
    final $_column = $_itemColumn<String>('format_id')!;

    final manager = $$FormatsTableTableManager(
      $_db,
      $_db.formats,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_formatIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $DecksTable _deckIdTable(_$AppDatabase db) =>
      db.decks.createAlias('matches__deck_id__decks__id');

  $$DecksTableProcessedTableManager get deckId {
    final $_column = $_itemColumn<String>('deck_id')!;

    final manager = $$DecksTableTableManager(
      $_db,
      $_db.decks,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_deckIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static $OpponentArchetypesTable _opponentArchetypeIdTable(_$AppDatabase db) =>
      db.opponentArchetypes.createAlias(
        'matches__opponent_archetype_id__opponent_archetypes__id',
      );

  $$OpponentArchetypesTableProcessedTableManager? get opponentArchetypeId {
    final $_column = $_itemColumn<String>('opponent_archetype_id');
    if ($_column == null) return null;
    final manager = $$OpponentArchetypesTableTableManager(
      $_db,
      $_db.opponentArchetypes,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_opponentArchetypeIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MatchesTableFilterComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isTopCut => $composableBuilder(
    column: $table.isTopCut,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get opponentName => $composableBuilder(
    column: $table.opponentName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get onThePlay => $composableBuilder(
    column: $table.onThePlay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gamesWon => $composableBuilder(
    column: $table.gamesWon,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gamesLost => $composableBuilder(
    column: $table.gamesLost,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get gamesDrawn => $composableBuilder(
    column: $table.gamesDrawn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnWithTypeConverterFilters<MatchResult, MatchResult, String> get result =>
      $composableBuilder(
        column: $table.result,
        builder: (column) => ColumnWithTypeConverterFilters(column),
      );

  ColumnFilters<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnFilters(column),
  );

  $$TournamentsTableFilterComposer get tournamentId {
    final $$TournamentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tournamentId,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentsTableFilterComposer(
            $db: $db,
            $table: $db.tournaments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GamesTableFilterComposer get gameId {
    final $$GamesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableFilterComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FormatsTableFilterComposer get formatId {
    final $$FormatsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.formatId,
      referencedTable: $db.formats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FormatsTableFilterComposer(
            $db: $db,
            $table: $db.formats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DecksTableFilterComposer get deckId {
    final $$DecksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableFilterComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OpponentArchetypesTableFilterComposer get opponentArchetypeId {
    final $$OpponentArchetypesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.opponentArchetypeId,
      referencedTable: $db.opponentArchetypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpponentArchetypesTableFilterComposer(
            $db: $db,
            $table: $db.opponentArchetypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MatchesTableOrderingComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isTopCut => $composableBuilder(
    column: $table.isTopCut,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get opponentName => $composableBuilder(
    column: $table.opponentName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get onThePlay => $composableBuilder(
    column: $table.onThePlay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gamesWon => $composableBuilder(
    column: $table.gamesWon,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gamesLost => $composableBuilder(
    column: $table.gamesLost,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get gamesDrawn => $composableBuilder(
    column: $table.gamesDrawn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get result => $composableBuilder(
    column: $table.result,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get playedAt => $composableBuilder(
    column: $table.playedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get notes => $composableBuilder(
    column: $table.notes,
    builder: (column) => ColumnOrderings(column),
  );

  $$TournamentsTableOrderingComposer get tournamentId {
    final $$TournamentsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tournamentId,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentsTableOrderingComposer(
            $db: $db,
            $table: $db.tournaments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GamesTableOrderingComposer get gameId {
    final $$GamesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableOrderingComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FormatsTableOrderingComposer get formatId {
    final $$FormatsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.formatId,
      referencedTable: $db.formats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FormatsTableOrderingComposer(
            $db: $db,
            $table: $db.formats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DecksTableOrderingComposer get deckId {
    final $$DecksTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableOrderingComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OpponentArchetypesTableOrderingComposer get opponentArchetypeId {
    final $$OpponentArchetypesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.opponentArchetypeId,
      referencedTable: $db.opponentArchetypes,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$OpponentArchetypesTableOrderingComposer(
            $db: $db,
            $table: $db.opponentArchetypes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MatchesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MatchesTable> {
  $$MatchesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get roundNumber => $composableBuilder(
    column: $table.roundNumber,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isTopCut =>
      $composableBuilder(column: $table.isTopCut, builder: (column) => column);

  GeneratedColumn<String> get opponentName => $composableBuilder(
    column: $table.opponentName,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get onThePlay =>
      $composableBuilder(column: $table.onThePlay, builder: (column) => column);

  GeneratedColumn<int> get gamesWon =>
      $composableBuilder(column: $table.gamesWon, builder: (column) => column);

  GeneratedColumn<int> get gamesLost =>
      $composableBuilder(column: $table.gamesLost, builder: (column) => column);

  GeneratedColumn<int> get gamesDrawn => $composableBuilder(
    column: $table.gamesDrawn,
    builder: (column) => column,
  );

  GeneratedColumnWithTypeConverter<MatchResult, String> get result =>
      $composableBuilder(column: $table.result, builder: (column) => column);

  GeneratedColumn<DateTime> get playedAt =>
      $composableBuilder(column: $table.playedAt, builder: (column) => column);

  GeneratedColumn<String> get notes =>
      $composableBuilder(column: $table.notes, builder: (column) => column);

  $$TournamentsTableAnnotationComposer get tournamentId {
    final $$TournamentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tournamentId,
      referencedTable: $db.tournaments,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$TournamentsTableAnnotationComposer(
            $db: $db,
            $table: $db.tournaments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$GamesTableAnnotationComposer get gameId {
    final $$GamesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.gameId,
      referencedTable: $db.games,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$GamesTableAnnotationComposer(
            $db: $db,
            $table: $db.games,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$FormatsTableAnnotationComposer get formatId {
    final $$FormatsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.formatId,
      referencedTable: $db.formats,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$FormatsTableAnnotationComposer(
            $db: $db,
            $table: $db.formats,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$DecksTableAnnotationComposer get deckId {
    final $$DecksTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.deckId,
      referencedTable: $db.decks,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$DecksTableAnnotationComposer(
            $db: $db,
            $table: $db.decks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  $$OpponentArchetypesTableAnnotationComposer get opponentArchetypeId {
    final $$OpponentArchetypesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.opponentArchetypeId,
          referencedTable: $db.opponentArchetypes,
          getReferencedColumn: (t) => t.id,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$OpponentArchetypesTableAnnotationComposer(
                $db: $db,
                $table: $db.opponentArchetypes,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return composer;
  }
}

class $$MatchesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MatchesTable,
          Match,
          $$MatchesTableFilterComposer,
          $$MatchesTableOrderingComposer,
          $$MatchesTableAnnotationComposer,
          $$MatchesTableCreateCompanionBuilder,
          $$MatchesTableUpdateCompanionBuilder,
          (Match, $$MatchesTableReferences),
          Match,
          PrefetchHooks Function({
            bool tournamentId,
            bool gameId,
            bool formatId,
            bool deckId,
            bool opponentArchetypeId,
          })
        > {
  $$MatchesTableTableManager(_$AppDatabase db, $MatchesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MatchesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MatchesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MatchesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String?> tournamentId = const Value.absent(),
                Value<String> gameId = const Value.absent(),
                Value<String> formatId = const Value.absent(),
                Value<String> deckId = const Value.absent(),
                Value<int?> roundNumber = const Value.absent(),
                Value<bool> isTopCut = const Value.absent(),
                Value<String?> opponentName = const Value.absent(),
                Value<String?> opponentArchetypeId = const Value.absent(),
                Value<bool?> onThePlay = const Value.absent(),
                Value<int> gamesWon = const Value.absent(),
                Value<int> gamesLost = const Value.absent(),
                Value<int> gamesDrawn = const Value.absent(),
                Value<MatchResult> result = const Value.absent(),
                Value<DateTime> playedAt = const Value.absent(),
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchesCompanion(
                id: id,
                tournamentId: tournamentId,
                gameId: gameId,
                formatId: formatId,
                deckId: deckId,
                roundNumber: roundNumber,
                isTopCut: isTopCut,
                opponentName: opponentName,
                opponentArchetypeId: opponentArchetypeId,
                onThePlay: onThePlay,
                gamesWon: gamesWon,
                gamesLost: gamesLost,
                gamesDrawn: gamesDrawn,
                result: result,
                playedAt: playedAt,
                notes: notes,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                Value<String?> tournamentId = const Value.absent(),
                required String gameId,
                required String formatId,
                required String deckId,
                Value<int?> roundNumber = const Value.absent(),
                Value<bool> isTopCut = const Value.absent(),
                Value<String?> opponentName = const Value.absent(),
                Value<String?> opponentArchetypeId = const Value.absent(),
                Value<bool?> onThePlay = const Value.absent(),
                Value<int> gamesWon = const Value.absent(),
                Value<int> gamesLost = const Value.absent(),
                Value<int> gamesDrawn = const Value.absent(),
                required MatchResult result,
                required DateTime playedAt,
                Value<String?> notes = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MatchesCompanion.insert(
                id: id,
                tournamentId: tournamentId,
                gameId: gameId,
                formatId: formatId,
                deckId: deckId,
                roundNumber: roundNumber,
                isTopCut: isTopCut,
                opponentName: opponentName,
                opponentArchetypeId: opponentArchetypeId,
                onThePlay: onThePlay,
                gamesWon: gamesWon,
                gamesLost: gamesLost,
                gamesDrawn: gamesDrawn,
                result: result,
                playedAt: playedAt,
                notes: notes,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable(table),
                  $$MatchesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                tournamentId = false,
                gameId = false,
                formatId = false,
                deckId = false,
                opponentArchetypeId = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (tournamentId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.tournamentId,
                                    referencedTable: $$MatchesTableReferences
                                        ._tournamentIdTable(db),
                                    referencedColumn: $$MatchesTableReferences
                                        ._tournamentIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (gameId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.gameId,
                                    referencedTable: $$MatchesTableReferences
                                        ._gameIdTable(db),
                                    referencedColumn: $$MatchesTableReferences
                                        ._gameIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (formatId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.formatId,
                                    referencedTable: $$MatchesTableReferences
                                        ._formatIdTable(db),
                                    referencedColumn: $$MatchesTableReferences
                                        ._formatIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (deckId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.deckId,
                                    referencedTable: $$MatchesTableReferences
                                        ._deckIdTable(db),
                                    referencedColumn: $$MatchesTableReferences
                                        ._deckIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }
                        if (opponentArchetypeId) {
                          state =
                              state.withJoin(
                                    currentTable: table,
                                    currentColumn: table.opponentArchetypeId,
                                    referencedTable: $$MatchesTableReferences
                                        ._opponentArchetypeIdTable(db),
                                    referencedColumn: $$MatchesTableReferences
                                        ._opponentArchetypeIdTable(db)
                                        .id,
                                  )
                                  as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [];
                  },
                );
              },
        ),
      );
}

typedef $$MatchesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MatchesTable,
      Match,
      $$MatchesTableFilterComposer,
      $$MatchesTableOrderingComposer,
      $$MatchesTableAnnotationComposer,
      $$MatchesTableCreateCompanionBuilder,
      $$MatchesTableUpdateCompanionBuilder,
      (Match, $$MatchesTableReferences),
      Match,
      PrefetchHooks Function({
        bool tournamentId,
        bool gameId,
        bool formatId,
        bool deckId,
        bool opponentArchetypeId,
      })
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$GamesTableTableManager get games =>
      $$GamesTableTableManager(_db, _db.games);
  $$FormatsTableTableManager get formats =>
      $$FormatsTableTableManager(_db, _db.formats);
  $$DecksTableTableManager get decks =>
      $$DecksTableTableManager(_db, _db.decks);
  $$DeckCardsTableTableManager get deckCards =>
      $$DeckCardsTableTableManager(_db, _db.deckCards);
  $$OpponentArchetypesTableTableManager get opponentArchetypes =>
      $$OpponentArchetypesTableTableManager(_db, _db.opponentArchetypes);
  $$TournamentsTableTableManager get tournaments =>
      $$TournamentsTableTableManager(_db, _db.tournaments);
  $$MatchesTableTableManager get matches =>
      $$MatchesTableTableManager(_db, _db.matches);
}
