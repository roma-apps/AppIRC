import 'package:floor/floor.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';

//part 'messages_regular_db_dao.g.dart';

@dao
abstract class RegularMessageDao {
  @Query('SELECT * FROM RegularMessage')
  Future<List<RegularMessage>> getAllMessages();

  @Query('SELECT * FROM RegularMessage WHERE channelRemoteId = :channelRemoteId')
  Future<List<RegularMessage>> getChannelMessages(int channelRemoteId);

  @Query('SELECT * FROM RegularMessage WHERE channelRemoteId = :channelRemoteId')
  Stream<List<RegularMessage>> getChannelMessagesStream(int channelRemoteId);

  @insert
  Future<int> insertRegularMessage(RegularMessage specialMessage);

  @Query('DELETE FROM RegularMessage')
  Future<void> deleteAllRegularMessages();


  @Query('DELETE FROM RegularMessage WHERE channelRemoteId = :channelRemoteId')
  Future<void> deleteChannelRegularMessages(int channelRemoteId);

}
