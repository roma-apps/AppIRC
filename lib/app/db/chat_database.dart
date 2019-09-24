import 'dart:async';

import 'package:floor/floor.dart';
import 'package:flutter_appirc/app/message/messages_regular_db.dart';
import 'package:flutter_appirc/app/message/messages_special_db.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';



part 'chat_database.g.dart';

@Database(version: 1, entities: [RegularMessageDB, SpecialMessageDB])
abstract class ChatDatabase extends FloorDatabase {
  RegularMessageDao get regularMessagesDao;

  SpecialMessageDao get specialMessagesDao;
}

class ChatDatabaseProvider extends Providable {
  final ChatDatabase db;

  ChatDatabaseProvider(this.db);
}
