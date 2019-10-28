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
            'CREATE TABLE IF NOT EXISTS `RegularMessageDB` (`localId` INTEGER PRIMARY KEY AUTOINCREMENT, `channelLocalId` INTEGER, `chatMessageTypeId` INTEGER, `channelRemoteId` INTEGER, `command` TEXT, `hostMask` TEXT, `text` TEXT, `paramsJsonEncoded` TEXT, `nicknamesJsonEncoded` TEXT, `regularMessageTypeId` INTEGER, `self` INTEGER, `highlight` INTEGER, `previewsJsonEncoded` TEXT, `linksJsonEncoded` TEXT, `dateMicrosecondsSinceEpoch` INTEGER, `fromRemoteId` INTEGER, `fromNick` TEXT, `fromMode` TEXT, `newNick` TEXT, `messageRemoteId` INTEGER)');
        await database.execute(
            'CREATE TABLE IF NOT EXISTS `SpecialMessageDB` (`localId` INTEGER PRIMARY KEY AUTOINCREMENT, `channelLocalId` INTEGER, `chatMessageTypeId` INTEGER, `channelRemoteId` INTEGER, `dataJsonEncoded` TEXT, `specialTypeId` INTEGER, `dateMicrosecondsSinceEpoch` INTEGER, `linksJsonEncoded` TEXT)');

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
        _regularMessageDBInsertionAdapter = InsertionAdapter(
            database,
            'RegularMessageDB',
            (RegularMessageDB item) => <String, dynamic>{
                  'localId': item.localId,
                  'channelLocalId': item.channelLocalId,
                  'chatMessageTypeId': item.chatMessageTypeId,
                  'channelRemoteId': item.channelRemoteId,
                  'command': item.command,
                  'hostMask': item.hostMask,
                  'text': item.text,
                  'paramsJsonEncoded': item.paramsJsonEncoded,
                  'nicknamesJsonEncoded': item.nicknamesJsonEncoded,
                  'regularMessageTypeId': item.regularMessageTypeId,
                  'self': item.self,
                  'highlight': item.highlight,
                  'previewsJsonEncoded': item.previewsJsonEncoded,
                  'linksJsonEncoded': item.linksJsonEncoded,
                  'dateMicrosecondsSinceEpoch': item.dateMicrosecondsSinceEpoch,
                  'fromRemoteId': item.fromRemoteId,
                  'fromNick': item.fromNick,
                  'fromMode': item.fromMode,
                  'newNick': item.newNick,
                  'messageRemoteId': item.messageRemoteId
                },
            changeListener),
        _regularMessageDBUpdateAdapter = UpdateAdapter(
            database,
            'RegularMessageDB',
            ['localId'],
            (RegularMessageDB item) => <String, dynamic>{
                  'localId': item.localId,
                  'channelLocalId': item.channelLocalId,
                  'chatMessageTypeId': item.chatMessageTypeId,
                  'channelRemoteId': item.channelRemoteId,
                  'command': item.command,
                  'hostMask': item.hostMask,
                  'text': item.text,
                  'paramsJsonEncoded': item.paramsJsonEncoded,
                  'nicknamesJsonEncoded': item.nicknamesJsonEncoded,
                  'regularMessageTypeId': item.regularMessageTypeId,
                  'self': item.self,
                  'highlight': item.highlight,
                  'previewsJsonEncoded': item.previewsJsonEncoded,
                  'linksJsonEncoded': item.linksJsonEncoded,
                  'dateMicrosecondsSinceEpoch': item.dateMicrosecondsSinceEpoch,
                  'fromRemoteId': item.fromRemoteId,
                  'fromNick': item.fromNick,
                  'fromMode': item.fromMode,
                  'newNick': item.newNick,
                  'messageRemoteId': item.messageRemoteId
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _regularMessageDBMapper = (Map<String, dynamic> row) =>
      RegularMessageDB(
          row['localId'] as int,
          row['channelLocalId'] as int,
          row['chatMessageTypeId'] as int,
          row['channelRemoteId'] as int,
          row['command'] as String,
          row['hostMask'] as String,
          row['text'] as String,
          row['paramsJsonEncoded'] as String,
          row['nicknamesJsonEncoded'] as String,
          row['regularMessageTypeId'] as int,
          row['self'] as int,
          row['highlight'] as int,
          row['previewsJsonEncoded'] as String,
          row['linksJsonEncoded'] as String,
          row['dateMicrosecondsSinceEpoch'] as int,
          row['fromRemoteId'] as int,
          row['fromNick'] as String,
          row['fromMode'] as String,
          row['newNick'] as String,
          row['messageRemoteId'] as int);

  final InsertionAdapter<RegularMessageDB> _regularMessageDBInsertionAdapter;

  final UpdateAdapter<RegularMessageDB> _regularMessageDBUpdateAdapter;

  @override
  Future<List<RegularMessageDB>> getAllMessages() async {
    return _queryAdapter.queryList('SELECT * FROM RegularMessageDB',
        mapper: _regularMessageDBMapper);
  }

  @override
  Future<RegularMessageDB> findMessageWithRemoteId(int remoteId) async {
    return _queryAdapter.query(
        'SELECT * FROM RegularMessageDB WHERE messageRemoteId = ?',
        arguments: <dynamic>[remoteId],
        mapper: _regularMessageDBMapper);
  }

  @override
  Future<List<RegularMessageDB>> getChannelMessages(int channelRemoteId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RegularMessageDB WHERE channelRemoteId = ?',
        arguments: <dynamic>[channelRemoteId],
        mapper: _regularMessageDBMapper);
  }

  @override
  Future<List<RegularMessageDB>> getChannelMessagesOrderByDate(
      int channelRemoteId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RegularMessageDB WHERE channelRemoteId = ? ORDER BY dateMicrosecondsSinceEpoch ASC',
        arguments: <dynamic>[channelRemoteId],
        mapper: _regularMessageDBMapper);
  }

  @override
  Stream<List<RegularMessageDB>> getChannelMessagesStream(int channelRemoteId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM RegularMessageDB WHERE channelRemoteId = ?',
        arguments: <dynamic>[channelRemoteId],
        tableName: 'RegularMessageDB',
        mapper: _regularMessageDBMapper);
  }

  @override
  Stream<List<RegularMessageDB>> getChannelMessagesOrderByDateStream(
      int channelRemoteId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM RegularMessageDB WHERE channelRemoteId = ? ORDER BY dateMicrosecondsSinceEpoch ASC',
        arguments: <dynamic>[channelRemoteId],
        tableName: 'RegularMessageDB',
        mapper: _regularMessageDBMapper);
  }

  @override
  Future<void> deleteAllRegularMessages() async {
    await _queryAdapter.queryNoReturn('DELETE FROM RegularMessageDB');
  }

  @override
  Future<void> deleteChannelRegularMessages(int channelRemoteId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM RegularMessageDB WHERE channelRemoteId = ?',
        arguments: <dynamic>[channelRemoteId]);
  }

  @override
  Future<int> insertRegularMessage(RegularMessageDB regularMessage) {
    return _regularMessageDBInsertionAdapter.insertAndReturnId(
        regularMessage, sqflite.ConflictAlgorithm.abort);
  }

  @override
  Future<int> updateRegularMessage(RegularMessageDB regularMessage) {
    return _regularMessageDBUpdateAdapter.updateAndReturnChangedRows(
        regularMessage, sqflite.ConflictAlgorithm.abort);
  }
}

class _$SpecialMessageDao extends SpecialMessageDao {
  _$SpecialMessageDao(this.database, this.changeListener)
      : _queryAdapter = QueryAdapter(database, changeListener),
        _specialMessageDBInsertionAdapter = InsertionAdapter(
            database,
            'SpecialMessageDB',
            (SpecialMessageDB item) => <String, dynamic>{
                  'localId': item.localId,
                  'channelLocalId': item.channelLocalId,
                  'chatMessageTypeId': item.chatMessageTypeId,
                  'channelRemoteId': item.channelRemoteId,
                  'dataJsonEncoded': item.dataJsonEncoded,
                  'specialTypeId': item.specialTypeId,
                  'dateMicrosecondsSinceEpoch': item.dateMicrosecondsSinceEpoch,
                  'linksJsonEncoded': item.linksJsonEncoded
                },
            changeListener);

  final sqflite.DatabaseExecutor database;

  final StreamController<String> changeListener;

  final QueryAdapter _queryAdapter;

  static final _specialMessageDBMapper = (Map<String, dynamic> row) =>
      SpecialMessageDB(
          row['localId'] as int,
          row['channelLocalId'] as int,
          row['chatMessageTypeId'] as int,
          row['channelRemoteId'] as int,
          row['dataJsonEncoded'] as String,
          row['specialTypeId'] as int,
          row['dateMicrosecondsSinceEpoch'] as int,
          row['linksJsonEncoded'] as String);

  final InsertionAdapter<SpecialMessageDB> _specialMessageDBInsertionAdapter;

  @override
  Future<List<SpecialMessageDB>> getAllMessages() async {
    return _queryAdapter.queryList('SELECT * FROM SpecialMessageDB',
        mapper: _specialMessageDBMapper);
  }

  @override
  Future<List<SpecialMessageDB>> getChannelMessages(int channelRemoteId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM SpecialMessageDB WHERE channelRemoteId = ?',
        arguments: <dynamic>[channelRemoteId],
        mapper: _specialMessageDBMapper);
  }

  @override
  Stream<List<SpecialMessageDB>> getChannelMessagesStream(int channelRemoteId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM SpecialMessageDB WHERE channelRemoteId = ?',
        arguments: <dynamic>[channelRemoteId],
        tableName: 'SpecialMessageDB',
        mapper: _specialMessageDBMapper);
  }

  @override
  Future<void> deleteAllSpecialMessages() async {
    await _queryAdapter.queryNoReturn('DELETE FROM SpecialMessageDB');
  }

  @override
  Future<void> deleteChannelSpecialMessages(int channelRemoteId) async {
    await _queryAdapter.queryNoReturn(
        'DELETE FROM SpecialMessageDB WHERE channelRemoteId = ?',
        arguments: <dynamic>[channelRemoteId]);
  }

  @override
  Future<int> insertSpecialMessage(SpecialMessageDB specialMessage) {
    return _specialMessageDBInsertionAdapter.insertAndReturnId(
        specialMessage, sqflite.ConflictAlgorithm.abort);
  }
}
