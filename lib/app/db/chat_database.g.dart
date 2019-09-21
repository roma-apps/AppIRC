// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_database.dart';

// **************************************************************************
// FloorGenerator
// **************************************************************************

class $FloorChatDatabase {
  /// Creates a database builder for a persistent database.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$ChatDatabaseBuilder databaseBuilder(String name) =>
      _$ChatDatabaseBuilder(name);

  /// Creates a database builder for an in memory database.
  /// Information stored in an in memory database disappears when the process is killed.
  /// Once a database is built, you should keep a reference to it and re-use it.
  static _$ChatDatabaseBuilder inMemoryDatabaseBuilder() =>
      _$ChatDatabaseBuilder(null);
}

class _$ChatDatabaseBuilder {
  _$ChatDatabaseBuilder(this.name);

  final String name;

  final List<Migration> _migrations = [];

  Callback _callback;

  /// Adds migrations to the builder.
  _$ChatDatabaseBuilder addMigrations(List<Migration> migrations) {
    _migrations.addAll(migrations);
    return this;
  }

  /// Adds a database [Callback] to the builder.
  _$ChatDatabaseBuilder addCallback(Callback callback) {
    _callback = callback;
    return this;
  }

  /// Creates the database and initializes it.
  Future<ChatDatabase> build() async {
    final database = _$ChatDatabase();
    database.database = await database.open(
      name ?? ':memory:',
      _migrations,
      _callback,
    );
    return database;
  }
}

class _$ChatDatabase extends ChatDatabase {
  _$ChatDatabase([StreamController<String> listener]) {
    changeListener = listener ?? StreamController<String>.broadcast();
  }

  RegularMessageDao _regularMessagesDaoInstance;

  SpecialMessageDao _specialMessagesDaoInstance;

  Future<sqflite.Database> open(String name, List<Migration> migrations,
      [Callback callback]) async {
    final path = join(await sqflite.getDatabasesPath(), name);

    return sqflite.openDatabase(
      path,
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        MigrationAdapter.runMigrations(
            database, startVersion, endVersion, migrations);

        await callback?.onUpgrade?.call(database, startVersion, endVersion);
      },
      onCreate: (database, version) async {
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `RegularMessage` (`localId` INTEGER PRIMARY KEY AUTOINCREMENT, `channelLocalId` INTEGER, `chatMessageTypeId` INTEGER, `channelRemoteId` INTEGER, `command` TEXT, `hostMask` TEXT, `text` TEXT, `paramsJsonEncoded` TEXT, `regularMessageTypeId` INTEGER, `self` INTEGER, `highlight` INTEGER, `previewsJsonEncoded` TEXT, `dateMicrosecondsSinceEpoch` INTEGER, `fromRemoteId` INTEGER, `fromNick` TEXT, `fromMode` TEXT)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `SpecialMessage` (`localId` INTEGER PRIMARY KEY AUTOINCREMENT, `channelLocalId` INTEGER, `chatMessageTypeId` INTEGER, `channelRemoteId` INTEGER, `dataJsonEncoded` TEXT, `specialTypeId` INTEGER)');

        await callback?.onCreate?.call(database, version);
      },
    );
  }

  @override
  RegularMessageDao get regularMessagesDao {
    return _regularMessagesDaoInstance ??=
        _$RegularMessageDao(database, changeListener);
  }

  @override
  SpecialMessageDao get specialMessagesDao {
    return _specialMessagesDaoInstance ??=
        _$SpecialMessageDao(database, changeListener);
  }
}

class _$RegularMessageDao extends RegularMessageDao {
  _$RegularMessageDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _regularMessageInsertionAdapter = InsertionAdapter(
            database,
            'RegularMessage',
            (RegularMessage item) => <String, dynamic>{
                  'localId': item.localId,
                  'channelLocalId': item.channelLocalId,
                  'chatMessageTypeId': item.chatMessageTypeId,
                  'channelRemoteId': item.channelRemoteId,
                  'command': item.command,
                  'hostMask': item.hostMask,
                  'text': item.text,
                  'paramsJsonEncoded': item.paramsJsonEncoded,
                  'regularMessageTypeId': item.regularMessageTypeId,
                  'self': item.self,
                  'highlight': item.highlight,
                  'previewsJsonEncoded': item.previewsJsonEncoded,
                  'dateMicrosecondsSinceEpoch': item.dateMicrosecondsSinceEpoch,
                  'fromRemoteId': item.fromRemoteId,
                  'fromNick': item.fromNick,
                  'fromMode': item.fromMode
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _regularMessageMapper = (Map<String, dynamic> row) =>
      RegularMessage(
          row['localId'] as int,
          row['channelLocalId'] as int,
          row['chatMessageTypeId'] as int,
          row['channelRemoteId'] as int,
          row['command'] as String,
          row['hostMask'] as String,
          row['text'] as String,
          row['paramsJsonEncoded'] as String,
          row['regularMessageTypeId'] as int,
          row['self'] as int,
          row['highlight'] as int,
          row['previewsJsonEncoded'] as String,
          row['dateMicrosecondsSinceEpoch'] as int,
          row['fromRemoteId'] as int,
          row['fromNick'] as String,
          row['fromMode'] as String);

  final InsertionAdapter<RegularMessage> _regularMessageInsertionAdapter;

  @override
  Future<List<RegularMessage>> getAllMessages() async {
    return _queryAdapter.queryList('SELECT * FROM RegularMessage',
        mapper: _regularMessageMapper);
  }

  @override
  Future<List<RegularMessage>> getChannelMessages(int channelRemoteId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RegularMessage WHERE channelRemoteId = ?',
        arguments: <dynamic>[channelRemoteId],
        mapper: _regularMessageMapper);
  }

  @override
  Stream<List<RegularMessage>> getChannelMessagesStream(int channelRemoteId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM RegularMessage WHERE channelRemoteId = ?',
        arguments: <dynamic>[channelRemoteId],
        tableName: 'RegularMessage',
        mapper: _regularMessageMapper);
  }

  @override
  Future<void> deleteAllRegularMessages() async {
    await _queryAdapter.queryNoReturn('DELETE FROM RegularMessage');
  }

  @override
  Future<void> deleteChannelRegularMessages(int channelRemoteId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM RegularMessage WHERE channelRemoteId = ?',
        arguments: <dynamic>[channelRemoteId]);
  }

  @override
  Future<int> insertRegularMessage(RegularMessage specialMessage) {
    return _regularMessageInsertionAdapter.insertAndReturnId(
        specialMessage, sqflite.ConflictAlgorithm.abort);
  }
}

class _$SpecialMessageDao extends SpecialMessageDao {
  _$SpecialMessageDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _specialMessageInsertionAdapter = InsertionAdapter(
            database,
            'SpecialMessage',
            (SpecialMessage item) => <String, dynamic>{
                  'localId': item.localId,
                  'channelLocalId': item.channelLocalId,
                  'chatMessageTypeId': item.chatMessageTypeId,
                  'channelRemoteId': item.channelRemoteId,
                  'dataJsonEncoded': item.dataJsonEncoded,
                  'specialTypeId': item.specialTypeId
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _specialMessageMapper = (Map<String, dynamic> row) =>
      SpecialMessage(
          row['localId'] as int,
          row['channelLocalId'] as int,
          row['chatMessageTypeId'] as int,
          row['channelRemoteId'] as int,
          row['dataJsonEncoded'] as String,
          row['specialTypeId'] as int);

  final InsertionAdapter<SpecialMessage> _specialMessageInsertionAdapter;

  @override
  Future<List<SpecialMessage>> getAllMessages() async {
    return _queryAdapter.queryList('SELECT * FROM SpecialMessage',
        mapper: _specialMessageMapper);
  }

  @override
  Future<List<SpecialMessage>> getChannelMessages(int channelRemoteId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM SpecialMessage WHERE channelRemoteId = ?',
        arguments: <dynamic>[channelRemoteId],
        mapper: _specialMessageMapper);
  }

  @override
  Stream<List<SpecialMessage>> getChannelMessagesStream(int channelRemoteId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM SpecialMessage WHERE channelRemoteId = ?',
        arguments: <dynamic>[channelRemoteId],
        tableName: 'SpecialMessage',
        mapper: _specialMessageMapper);
  }

  @override
  Future<void> deleteAllSpecialMessages() async {
    await _queryAdapter.queryNoReturn('DELETE FROM SpecialMessage');
  }

  @override
  Future<void> deleteChannelSpecialMessages(int channelRemoteId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM SpecialMessage WHERE channelRemoteId = ?',
        arguments: <dynamic>[channelRemoteId]);
  }

  @override
  Future<int> insertSpecialMessage(SpecialMessage specialMessage) {
    return _specialMessageInsertionAdapter.insertAndReturnId(
        specialMessage, sqflite.ConflictAlgorithm.abort);
  }
}
