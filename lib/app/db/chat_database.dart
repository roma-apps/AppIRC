import 'dart:async';

import 'package:floor/floor.dart';
import 'package:flutter_appirc/app/message/messages_regular_db_dao.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_special_db_dao.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:sqflite/sqflite.dart' as sqflite;
import 'package:path/path.dart';


part 'chat_database.g.dart';

@Database(version: 1, entities: [RegularMessage, SpecialMessage])
abstract class ChatDatabase extends FloorDatabase {
  RegularMessageDao get regularMessagesDao;
  SpecialMessageDao get specialMessagesDao;
}

class ChatDatabaseProvider extends Providable {
  final ChatDatabase db;

  ChatDatabaseProvider(this.db);

}
