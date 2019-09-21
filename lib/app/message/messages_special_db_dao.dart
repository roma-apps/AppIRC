import 'package:floor/floor.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';

//part 'messages_special_db_dao.g.dart';

@dao
abstract class SpecialMessageDao {
  @Query('SELECT * FROM SpecialMessage')
  Future<List<SpecialMessage>> getAllMessages();

  @Query('SELECT * FROM SpecialMessage WHERE channelRemoteId = :channelRemoteId')
  Future<List<SpecialMessage>> getChannelMessages(int channelRemoteId);

  @Query('SELECT * FROM SpecialMessage WHERE channelRemoteId = :channelRemoteId')
  Stream<List<SpecialMessage>> getChannelMessagesStream(int channelRemoteId);

  @insert
  Future<int> insertSpecialMessage(SpecialMessage specialMessage);

  @Query('DELETE FROM SpecialMessage')
  Future<void> deleteAllSpecialMessages();


  @Query('DELETE FROM SpecialMessage WHERE channelRemoteId = :channelRemoteId')
  Future<void> deleteChannelSpecialMessages(int channelRemoteId);
}
