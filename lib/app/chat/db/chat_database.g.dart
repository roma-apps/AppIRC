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
    final path = name != null
        ? await sqfliteDatabaseFactory.getDatabasePath(name)
        : ':memory:';
    final database = _$ChatDatabase();
    database.database = await database.open(
      path,
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

  Future<sqflite.Database> open(String path, List<Migration> migrations,
      [Callback callback]) async {
    final databaseOptions = sqflite.OpenDatabaseOptions(
      version: 1,
      onConfigure: (database) async {
        await database.execute('PRAGMA foreign_keys = ON');
      },
      onOpen: (database) async {
        await callback?.onOpen?.call(database);
      },
      onUpgrade: (database, startVersion, endVersion) async {
        await MigrationAdapter.runMigrations(
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
    return sqfliteDatabaseFactory.openDatabase(path, options: databaseOptions);
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

  final InsertionAdapter<RegularMessageDB> _regularMessageDBInsertionAdapter;

  final UpdateAdapter<RegularMessageDB> _regularMessageDBUpdateAdapter;

  @override
  Future<List<RegularMessageDB>> getAllMessages() async {
    return _queryAdapter.queryList('SELECT * FROM RegularMessageDB',
        mapper: (Map<String, dynamic> row) => RegularMessageDB(
            localId: row['localId'] as int,
            channelLocalId: row['channelLocalId'] as int,
            messageRemoteId: row['messageRemoteId'] as int,
            chatMessageTypeId: row['chatMessageTypeId'] as int,
            channelRemoteId: row['channelRemoteId'] as int,
            command: row['command'] as String,
            hostMask: row['hostMask'] as String,
            text: row['text'] as String,
            paramsJsonEncoded: row['paramsJsonEncoded'] as String,
            regularMessageTypeId: row['regularMessageTypeId'] as int,
            self: row['self'] as int,
            highlight: row['highlight'] as int,
            previewsJsonEncoded: row['previewsJsonEncoded'] as String,
            linksJsonEncoded: row['linksJsonEncoded'] as String,
            dateMicrosecondsSinceEpoch:
                row['dateMicrosecondsSinceEpoch'] as int,
            fromRemoteId: row['fromRemoteId'] as int,
            fromNick: row['fromNick'] as String,
            fromMode: row['fromMode'] as String,
            newNick: row['newNick'] as String,
            nicknamesJsonEncoded: row['nicknamesJsonEncoded'] as String));
  }

  @override
  Future<RegularMessageDB> findMessageWithRemoteId(int messageRemoteId) async {
    return _queryAdapter.query(
        'SELECT * FROM RegularMessageDB WHERE messageRemoteId = ?',
        arguments: <dynamic>[messageRemoteId],
        mapper: (Map<String, dynamic> row) => RegularMessageDB(
            localId: row['localId'] as int,
            channelLocalId: row['channelLocalId'] as int,
            messageRemoteId: row['messageRemoteId'] as int,
            chatMessageTypeId: row['chatMessageTypeId'] as int,
            channelRemoteId: row['channelRemoteId'] as int,
            command: row['command'] as String,
            hostMask: row['hostMask'] as String,
            text: row['text'] as String,
            paramsJsonEncoded: row['paramsJsonEncoded'] as String,
            regularMessageTypeId: row['regularMessageTypeId'] as int,
            self: row['self'] as int,
            highlight: row['highlight'] as int,
            previewsJsonEncoded: row['previewsJsonEncoded'] as String,
            linksJsonEncoded: row['linksJsonEncoded'] as String,
            dateMicrosecondsSinceEpoch:
                row['dateMicrosecondsSinceEpoch'] as int,
            fromRemoteId: row['fromRemoteId'] as int,
            fromNick: row['fromNick'] as String,
            fromMode: row['fromMode'] as String,
            newNick: row['newNick'] as String,
            nicknamesJsonEncoded: row['nicknamesJsonEncoded'] as String));
  }

  @override
  Future<RegularMessageDB> findMessageLocalIdWithRemoteId(
      int messageRemoteId) async {
    return _queryAdapter.query(
        'SELECT localId FROM RegularMessageDB WHERE messageRemoteId = ?',
        arguments: <dynamic>[messageRemoteId],
        mapper: (Map<String, dynamic> row) => RegularMessageDB(
            localId: row['localId'] as int,
            channelLocalId: row['channelLocalId'] as int,
            messageRemoteId: row['messageRemoteId'] as int,
            chatMessageTypeId: row['chatMessageTypeId'] as int,
            channelRemoteId: row['channelRemoteId'] as int,
            command: row['command'] as String,
            hostMask: row['hostMask'] as String,
            text: row['text'] as String,
            paramsJsonEncoded: row['paramsJsonEncoded'] as String,
            regularMessageTypeId: row['regularMessageTypeId'] as int,
            self: row['self'] as int,
            highlight: row['highlight'] as int,
            previewsJsonEncoded: row['previewsJsonEncoded'] as String,
            linksJsonEncoded: row['linksJsonEncoded'] as String,
            dateMicrosecondsSinceEpoch:
                row['dateMicrosecondsSinceEpoch'] as int,
            fromRemoteId: row['fromRemoteId'] as int,
            fromNick: row['fromNick'] as String,
            fromMode: row['fromMode'] as String,
            newNick: row['newNick'] as String,
            nicknamesJsonEncoded: row['nicknamesJsonEncoded'] as String));
  }

  @override
  Future<RegularMessageDB> findMessageWithChannelAndRemoteId(
      int channelRemoteId, int messageRemoteId) async {
    return _queryAdapter.query(
        'SELECT * FROM RegularMessageDB WHERE messageRemoteId = ? AND channelRemoteId = ?',
        arguments: <dynamic>[channelRemoteId, messageRemoteId],
        mapper: (Map<String, dynamic> row) => RegularMessageDB(
            localId: row['localId'] as int,
            channelLocalId: row['channelLocalId'] as int,
            messageRemoteId: row['messageRemoteId'] as int,
            chatMessageTypeId: row['chatMessageTypeId'] as int,
            channelRemoteId: row['channelRemoteId'] as int,
            command: row['command'] as String,
            hostMask: row['hostMask'] as String,
            text: row['text'] as String,
            paramsJsonEncoded: row['paramsJsonEncoded'] as String,
            regularMessageTypeId: row['regularMessageTypeId'] as int,
            self: row['self'] as int,
            highlight: row['highlight'] as int,
            previewsJsonEncoded: row['previewsJsonEncoded'] as String,
            linksJsonEncoded: row['linksJsonEncoded'] as String,
            dateMicrosecondsSinceEpoch:
                row['dateMicrosecondsSinceEpoch'] as int,
            fromRemoteId: row['fromRemoteId'] as int,
            fromNick: row['fromNick'] as String,
            fromMode: row['fromMode'] as String,
            newNick: row['newNick'] as String,
            nicknamesJsonEncoded: row['nicknamesJsonEncoded'] as String));
  }

  @override
  Future<List<RegularMessageDB>> getChannelMessages(int channelRemoteId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RegularMessageDB WHERE channelRemoteId = ?',
        arguments: <dynamic>[channelRemoteId],
        mapper: (Map<String, dynamic> row) => RegularMessageDB(
            localId: row['localId'] as int,
            channelLocalId: row['channelLocalId'] as int,
            messageRemoteId: row['messageRemoteId'] as int,
            chatMessageTypeId: row['chatMessageTypeId'] as int,
            channelRemoteId: row['channelRemoteId'] as int,
            command: row['command'] as String,
            hostMask: row['hostMask'] as String,
            text: row['text'] as String,
            paramsJsonEncoded: row['paramsJsonEncoded'] as String,
            regularMessageTypeId: row['regularMessageTypeId'] as int,
            self: row['self'] as int,
            highlight: row['highlight'] as int,
            previewsJsonEncoded: row['previewsJsonEncoded'] as String,
            linksJsonEncoded: row['linksJsonEncoded'] as String,
            dateMicrosecondsSinceEpoch:
                row['dateMicrosecondsSinceEpoch'] as int,
            fromRemoteId: row['fromRemoteId'] as int,
            fromNick: row['fromNick'] as String,
            fromMode: row['fromMode'] as String,
            newNick: row['newNick'] as String,
            nicknamesJsonEncoded: row['nicknamesJsonEncoded'] as String));
  }

  @override
  Future<List<RegularMessageDB>> getChannelMessagesOrderByDate(
      int channelRemoteId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RegularMessageDB WHERE channelRemoteId = ? ORDER BY dateMicrosecondsSinceEpoch ASC',
        arguments: <dynamic>[channelRemoteId],
        mapper: (Map<String, dynamic> row) => RegularMessageDB(
            localId: row['localId'] as int,
            channelLocalId: row['channelLocalId'] as int,
            messageRemoteId: row['messageRemoteId'] as int,
            chatMessageTypeId: row['chatMessageTypeId'] as int,
            channelRemoteId: row['channelRemoteId'] as int,
            command: row['command'] as String,
            hostMask: row['hostMask'] as String,
            text: row['text'] as String,
            paramsJsonEncoded: row['paramsJsonEncoded'] as String,
            regularMessageTypeId: row['regularMessageTypeId'] as int,
            self: row['self'] as int,
            highlight: row['highlight'] as int,
            previewsJsonEncoded: row['previewsJsonEncoded'] as String,
            linksJsonEncoded: row['linksJsonEncoded'] as String,
            dateMicrosecondsSinceEpoch:
                row['dateMicrosecondsSinceEpoch'] as int,
            fromRemoteId: row['fromRemoteId'] as int,
            fromNick: row['fromNick'] as String,
            fromMode: row['fromMode'] as String,
            newNick: row['newNick'] as String,
            nicknamesJsonEncoded: row['nicknamesJsonEncoded'] as String));
  }

  @override
  Future<List<RegularMessageDB>> searchChannelMessagesOrderByDate(
      int channelRemoteId, String search, String nickSearch) async {
    return _queryAdapter.queryList(
        'SELECT * FROM RegularMessageDB WHERE channelRemoteId = ? AND (text LIKE ? OR fromNick LIKE ?) ORDER BY dateMicrosecondsSinceEpoch ASC',
        arguments: <dynamic>[channelRemoteId, search, nickSearch],
        mapper: (Map<String, dynamic> row) => RegularMessageDB(
            localId: row['localId'] as int,
            channelLocalId: row['channelLocalId'] as int,
            messageRemoteId: row['messageRemoteId'] as int,
            chatMessageTypeId: row['chatMessageTypeId'] as int,
            channelRemoteId: row['channelRemoteId'] as int,
            command: row['command'] as String,
            hostMask: row['hostMask'] as String,
            text: row['text'] as String,
            paramsJsonEncoded: row['paramsJsonEncoded'] as String,
            regularMessageTypeId: row['regularMessageTypeId'] as int,
            self: row['self'] as int,
            highlight: row['highlight'] as int,
            previewsJsonEncoded: row['previewsJsonEncoded'] as String,
            linksJsonEncoded: row['linksJsonEncoded'] as String,
            dateMicrosecondsSinceEpoch:
                row['dateMicrosecondsSinceEpoch'] as int,
            fromRemoteId: row['fromRemoteId'] as int,
            fromNick: row['fromNick'] as String,
            fromMode: row['fromMode'] as String,
            newNick: row['newNick'] as String,
            nicknamesJsonEncoded: row['nicknamesJsonEncoded'] as String));
  }

  @override
  Future<RegularMessageDB> getNewestAllChannelsMessage() async {
    return _queryAdapter.query(
        'SELECT * FROM RegularMessageDB ORDER BY messageRemoteId DESC LIMIT 1',
        mapper: (Map<String, dynamic> row) => RegularMessageDB(
            localId: row['localId'] as int,
            channelLocalId: row['channelLocalId'] as int,
            messageRemoteId: row['messageRemoteId'] as int,
            chatMessageTypeId: row['chatMessageTypeId'] as int,
            channelRemoteId: row['channelRemoteId'] as int,
            command: row['command'] as String,
            hostMask: row['hostMask'] as String,
            text: row['text'] as String,
            paramsJsonEncoded: row['paramsJsonEncoded'] as String,
            regularMessageTypeId: row['regularMessageTypeId'] as int,
            self: row['self'] as int,
            highlight: row['highlight'] as int,
            previewsJsonEncoded: row['previewsJsonEncoded'] as String,
            linksJsonEncoded: row['linksJsonEncoded'] as String,
            dateMicrosecondsSinceEpoch:
                row['dateMicrosecondsSinceEpoch'] as int,
            fromRemoteId: row['fromRemoteId'] as int,
            fromNick: row['fromNick'] as String,
            fromMode: row['fromMode'] as String,
            newNick: row['newNick'] as String,
            nicknamesJsonEncoded: row['nicknamesJsonEncoded'] as String));
  }

  @override
  Future<RegularMessageDB> getNewestChannelMessage(int channelRemoteId) async {
    return _queryAdapter.query(
        'SELECT * FROM RegularMessageDB WHERE channelRemoteId = ? ORDER BY messageRemoteId DESC LIMIT 1',
        arguments: <dynamic>[channelRemoteId],
        mapper: (Map<String, dynamic> row) => RegularMessageDB(
            localId: row['localId'] as int,
            channelLocalId: row['channelLocalId'] as int,
            messageRemoteId: row['messageRemoteId'] as int,
            chatMessageTypeId: row['chatMessageTypeId'] as int,
            channelRemoteId: row['channelRemoteId'] as int,
            command: row['command'] as String,
            hostMask: row['hostMask'] as String,
            text: row['text'] as String,
            paramsJsonEncoded: row['paramsJsonEncoded'] as String,
            regularMessageTypeId: row['regularMessageTypeId'] as int,
            self: row['self'] as int,
            highlight: row['highlight'] as int,
            previewsJsonEncoded: row['previewsJsonEncoded'] as String,
            linksJsonEncoded: row['linksJsonEncoded'] as String,
            dateMicrosecondsSinceEpoch:
                row['dateMicrosecondsSinceEpoch'] as int,
            fromRemoteId: row['fromRemoteId'] as int,
            fromNick: row['fromNick'] as String,
            fromMode: row['fromMode'] as String,
            newNick: row['newNick'] as String,
            nicknamesJsonEncoded: row['nicknamesJsonEncoded'] as String));
  }

  @override
  Future<RegularMessageDB> getOldestChannelMessage(int channelRemoteId) async {
    return _queryAdapter.query(
        'SELECT * FROM RegularMessageDB WHERE channelRemoteId = ? ORDER BY messageRemoteId ASC LIMIT 1',
        arguments: <dynamic>[channelRemoteId],
        mapper: (Map<String, dynamic> row) => RegularMessageDB(
            localId: row['localId'] as int,
            channelLocalId: row['channelLocalId'] as int,
            messageRemoteId: row['messageRemoteId'] as int,
            chatMessageTypeId: row['chatMessageTypeId'] as int,
            channelRemoteId: row['channelRemoteId'] as int,
            command: row['command'] as String,
            hostMask: row['hostMask'] as String,
            text: row['text'] as String,
            paramsJsonEncoded: row['paramsJsonEncoded'] as String,
            regularMessageTypeId: row['regularMessageTypeId'] as int,
            self: row['self'] as int,
            highlight: row['highlight'] as int,
            previewsJsonEncoded: row['previewsJsonEncoded'] as String,
            linksJsonEncoded: row['linksJsonEncoded'] as String,
            dateMicrosecondsSinceEpoch:
                row['dateMicrosecondsSinceEpoch'] as int,
            fromRemoteId: row['fromRemoteId'] as int,
            fromNick: row['fromNick'] as String,
            fromMode: row['fromMode'] as String,
            newNick: row['newNick'] as String,
            nicknamesJsonEncoded: row['nicknamesJsonEncoded'] as String));
  }

  @override
  Stream<List<RegularMessageDB>> getChannelMessagesStream(int channelRemoteId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM RegularMessageDB WHERE channelRemoteId = ?',
        arguments: <dynamic>[channelRemoteId],
        queryableName: 'RegularMessageDB',
        isView: false,
        mapper: (Map<String, dynamic> row) => RegularMessageDB(
            localId: row['localId'] as int,
            channelLocalId: row['channelLocalId'] as int,
            messageRemoteId: row['messageRemoteId'] as int,
            chatMessageTypeId: row['chatMessageTypeId'] as int,
            channelRemoteId: row['channelRemoteId'] as int,
            command: row['command'] as String,
            hostMask: row['hostMask'] as String,
            text: row['text'] as String,
            paramsJsonEncoded: row['paramsJsonEncoded'] as String,
            regularMessageTypeId: row['regularMessageTypeId'] as int,
            self: row['self'] as int,
            highlight: row['highlight'] as int,
            previewsJsonEncoded: row['previewsJsonEncoded'] as String,
            linksJsonEncoded: row['linksJsonEncoded'] as String,
            dateMicrosecondsSinceEpoch:
                row['dateMicrosecondsSinceEpoch'] as int,
            fromRemoteId: row['fromRemoteId'] as int,
            fromNick: row['fromNick'] as String,
            fromMode: row['fromMode'] as String,
            newNick: row['newNick'] as String,
            nicknamesJsonEncoded: row['nicknamesJsonEncoded'] as String));
  }

  @override
  Stream<List<RegularMessageDB>> getChannelMessagesOrderByDateStream(
      int channelRemoteId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM RegularMessageDB WHERE channelRemoteId = ? ORDER BY dateMicrosecondsSinceEpoch ASC',
        arguments: <dynamic>[channelRemoteId],
        queryableName: 'RegularMessageDB',
        isView: false,
        mapper: (Map<String, dynamic> row) => RegularMessageDB(
            localId: row['localId'] as int,
            channelLocalId: row['channelLocalId'] as int,
            messageRemoteId: row['messageRemoteId'] as int,
            chatMessageTypeId: row['chatMessageTypeId'] as int,
            channelRemoteId: row['channelRemoteId'] as int,
            command: row['command'] as String,
            hostMask: row['hostMask'] as String,
            text: row['text'] as String,
            paramsJsonEncoded: row['paramsJsonEncoded'] as String,
            regularMessageTypeId: row['regularMessageTypeId'] as int,
            self: row['self'] as int,
            highlight: row['highlight'] as int,
            previewsJsonEncoded: row['previewsJsonEncoded'] as String,
            linksJsonEncoded: row['linksJsonEncoded'] as String,
            dateMicrosecondsSinceEpoch:
                row['dateMicrosecondsSinceEpoch'] as int,
            fromRemoteId: row['fromRemoteId'] as int,
            fromNick: row['fromNick'] as String,
            fromMode: row['fromMode'] as String,
            newNick: row['newNick'] as String,
            nicknamesJsonEncoded: row['nicknamesJsonEncoded'] as String));
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
        regularMessage, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateRegularMessage(RegularMessageDB regularMessage) {
    return _regularMessageDBUpdateAdapter.updateAndReturnChangedRows(
        regularMessage, OnConflictStrategy.abort);
  }

  @override
  Future<dynamic> upsertRegularMessage(RegularMessage regularMessage) async {
    if (database is sqflite.Transaction) {
      return super.upsertRegularMessage(regularMessage);
    } else {
      return (database as sqflite.Database)
          .transaction<dynamic>((transaction) async {
        final transactionDatabase = _$ChatDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.regularMessagesDao
            .upsertRegularMessage(regularMessage);
      });
    }
  }

  @override
  Future<dynamic> upsertRegularMessages(List<RegularMessage> messages) async {
    if (database is sqflite.Transaction) {
      return super.upsertRegularMessages(messages);
    } else {
      return (database as sqflite.Database)
          .transaction<dynamic>((transaction) async {
        final transactionDatabase = _$ChatDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.regularMessagesDao
            .upsertRegularMessages(messages);
      });
    }
  }

  @override
  Future<dynamic> insertRegularMessages(List<RegularMessageDB> messages) async {
    if (database is sqflite.Transaction) {
      return super.insertRegularMessages(messages);
    } else {
      return (database as sqflite.Database)
          .transaction<dynamic>((transaction) async {
        final transactionDatabase = _$ChatDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.regularMessagesDao
            .insertRegularMessages(messages);
      });
    }
  }

  @override
  Future<dynamic> updateRegularMessages(List<RegularMessageDB> messages) async {
    if (database is sqflite.Transaction) {
      return super.updateRegularMessages(messages);
    } else {
      return (database as sqflite.Database)
          .transaction<dynamic>((transaction) async {
        final transactionDatabase = _$ChatDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.regularMessagesDao
            .updateRegularMessages(messages);
      });
    }
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
            changeListener),
        _specialMessageDBUpdateAdapter = UpdateAdapter(
            database,
            'SpecialMessageDB',
            ['localId'],
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

  final InsertionAdapter<SpecialMessageDB> _specialMessageDBInsertionAdapter;

  final UpdateAdapter<SpecialMessageDB> _specialMessageDBUpdateAdapter;

  @override
  Future<List<SpecialMessageDB>> getAllMessages() async {
    return _queryAdapter.queryList('SELECT * FROM SpecialMessageDB',
        mapper: (Map<String, dynamic> row) => SpecialMessageDB(
            localId: row['localId'] as int,
            channelLocalId: row['channelLocalId'] as int,
            chatMessageTypeId: row['chatMessageTypeId'] as int,
            channelRemoteId: row['channelRemoteId'] as int,
            dataJsonEncoded: row['dataJsonEncoded'] as String,
            specialTypeId: row['specialTypeId'] as int,
            dateMicrosecondsSinceEpoch:
                row['dateMicrosecondsSinceEpoch'] as int,
            linksJsonEncoded: row['linksJsonEncoded'] as String));
  }

  @override
  Future<List<SpecialMessageDB>> getChannelMessages(int channelRemoteId) async {
    return _queryAdapter.queryList(
        'SELECT * FROM SpecialMessageDB WHERE channelRemoteId = ?',
        arguments: <dynamic>[channelRemoteId],
        mapper: (Map<String, dynamic> row) => SpecialMessageDB(
            localId: row['localId'] as int,
            channelLocalId: row['channelLocalId'] as int,
            chatMessageTypeId: row['chatMessageTypeId'] as int,
            channelRemoteId: row['channelRemoteId'] as int,
            dataJsonEncoded: row['dataJsonEncoded'] as String,
            specialTypeId: row['specialTypeId'] as int,
            dateMicrosecondsSinceEpoch:
                row['dateMicrosecondsSinceEpoch'] as int,
            linksJsonEncoded: row['linksJsonEncoded'] as String));
  }

  @override
  Future<List<SpecialMessageDB>> searchChannelMessagesOrderByDate(
      int channelRemoteId, String search) async {
    return _queryAdapter.queryList(
        'SELECT * FROM SpecialMessageDB WHERE channelRemoteId = ? AND dataJsonEncoded LIKE ? ORDER BY dateMicrosecondsSinceEpoch ASC',
        arguments: <dynamic>[channelRemoteId, search],
        mapper: (Map<String, dynamic> row) => SpecialMessageDB(
            localId: row['localId'] as int,
            channelLocalId: row['channelLocalId'] as int,
            chatMessageTypeId: row['chatMessageTypeId'] as int,
            channelRemoteId: row['channelRemoteId'] as int,
            dataJsonEncoded: row['dataJsonEncoded'] as String,
            specialTypeId: row['specialTypeId'] as int,
            dateMicrosecondsSinceEpoch:
                row['dateMicrosecondsSinceEpoch'] as int,
            linksJsonEncoded: row['linksJsonEncoded'] as String));
  }

  @override
  Stream<List<SpecialMessageDB>> getChannelMessagesStream(int channelRemoteId) {
    return _queryAdapter.queryListStream(
        'SELECT * FROM SpecialMessageDB WHERE channelRemoteId = ?',
        arguments: <dynamic>[channelRemoteId],
        queryableName: 'SpecialMessageDB',
        isView: false,
        mapper: (Map<String, dynamic> row) => SpecialMessageDB(
            localId: row['localId'] as int,
            channelLocalId: row['channelLocalId'] as int,
            chatMessageTypeId: row['chatMessageTypeId'] as int,
            channelRemoteId: row['channelRemoteId'] as int,
            dataJsonEncoded: row['dataJsonEncoded'] as String,
            specialTypeId: row['specialTypeId'] as int,
            dateMicrosecondsSinceEpoch:
                row['dateMicrosecondsSinceEpoch'] as int,
            linksJsonEncoded: row['linksJsonEncoded'] as String));
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
        specialMessage, OnConflictStrategy.abort);
  }

  @override
  Future<int> updateSpecialMessage(SpecialMessageDB specialMessage) {
    return _specialMessageDBUpdateAdapter.updateAndReturnChangedRows(
        specialMessage, OnConflictStrategy.abort);
  }

  @override
  Future<dynamic> upsertSpecialMessage(SpecialMessage specialMessage) async {
    if (database is sqflite.Transaction) {
      return super.upsertSpecialMessage(specialMessage);
    } else {
      return (database as sqflite.Database)
          .transaction<dynamic>((transaction) async {
        final transactionDatabase = _$ChatDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.specialMessagesDao
            .upsertSpecialMessage(specialMessage);
      });
    }
  }

  @override
  Future<dynamic> upsertSpecialMessages(List<SpecialMessage> messages) async {
    if (database is sqflite.Transaction) {
      return super.upsertSpecialMessages(messages);
    } else {
      return (database as sqflite.Database)
          .transaction<dynamic>((transaction) async {
        final transactionDatabase = _$ChatDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.specialMessagesDao
            .upsertSpecialMessages(messages);
      });
    }
  }

  @override
  Future<dynamic> insertSpecialMessages(List<SpecialMessageDB> messages) async {
    if (database is sqflite.Transaction) {
      return super.insertSpecialMessages(messages);
    } else {
      return (database as sqflite.Database)
          .transaction<dynamic>((transaction) async {
        final transactionDatabase = _$ChatDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.specialMessagesDao
            .insertSpecialMessages(messages);
      });
    }
  }

  @override
  Future<dynamic> updateSpecialMessages(List<SpecialMessageDB> messages) async {
    if (database is sqflite.Transaction) {
      return super.updateSpecialMessages(messages);
    } else {
      return (database as sqflite.Database)
          .transaction<dynamic>((transaction) async {
        final transactionDatabase = _$ChatDatabase(changeListener)
          ..database = transaction;
        return transactionDatabase.specialMessagesDao
            .updateSpecialMessages(messages);
      });
    }
  }
}
