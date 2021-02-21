import 'dart:async';

import 'package:floor/floor.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_db.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_db.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:sqflite/sqflite.dart' as sqflite;

part 'chat_database.g.dart';

@Database(
  version: 1,
  entities: [
    RegularMessageDB,
    SpecialMessageDB,
  ],
)
abstract class ChatDatabase extends FloorDatabase {
  RegularMessageDao get regularMessagesDao;

  SpecialMessageDao get specialMessagesDao;
}
