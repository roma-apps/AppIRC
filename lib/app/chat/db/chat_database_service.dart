import 'package:flutter_appirc/app/chat/db/chat_database.dart';
import 'package:flutter_appirc/async/loading/init/async_init_loading_bloc_impl.dart';

class ChatDatabaseService extends AsyncInitLoadingBloc {
  ChatDatabase chatDatabase;

  ChatDatabaseService();

  @override
  Future internalAsyncInit() async {
    chatDatabase =
        await $FloorChatDatabase.databaseBuilder('appirc_database.db').build();
  }
}
