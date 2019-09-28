import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_messages_loader_bloc.dart';
import 'package:flutter_appirc/app/db/chat_database.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_widgets.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';
import 'package:flutter_appirc/app/message/messages_special_widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';

class IRCNetworkChannelMessagesListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var backendService = Provider.of<ChatOutputBackendService>(context);
    var channelBloc = Provider.of<NetworkChannelBloc>(context);
    var chatDatabase = Provider.of<ChatDatabaseProvider>(context).db;

    NetworkChannelMessagesLoaderBloc messagesLoader =
        NetworkChannelMessagesLoaderBloc(backendService,
            chatDatabase, channelBloc.network, channelBloc.channel);

    return StreamBuilder<List<ChatMessage>>(
        stream: messagesLoader.messagesStream,
        builder:
            (BuildContext context, AsyncSnapshot<List<ChatMessage>> snapshot) {
          var messages = snapshot.data;
          if (messages != null) {
            messages =
                messages.where((message) => _isNeedPrint(message)).toList();
          }

          if (messages == null || messages.length == 0) {
            return Center(
                child: Text(
                    AppLocalizations.of(context).tr("chat.empty_channel")));
          } else {
            var scrollController = ScrollController();

            SchedulerBinding.instance.addPostFrameCallback((_) {
              scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut);
            });

            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                  itemCount: messages.length,
                  controller: scrollController,
                  itemBuilder: (BuildContext context, int index) {
                    var message = messages[index];

                    var chatMessageType = message.chatMessageType;

                    switch (chatMessageType) {
                      case ChatMessageType.SPECIAL:
                        var specialMessage = message as SpecialMessage;
                        return buildSpecialMessageWidget(context,specialMessage);
                        break;
                      case ChatMessageType.REGULAR:
                        return NetworkChannelMessageWidget(message);
                        break;
                    }

                    throw Exception(
                        "Invalid message type = $chatMessageType");
                  }),
            );
          }
        });
  }
}

_isNeedPrint(ChatMessage message) {
  if (message is RegularMessage) {
    var regularMessageType = message.regularMessageType;
    return regularMessageType != RegularMessageType.UNHANDLED &&
        regularMessageType != RegularMessageType.RAW;
  } else {
    return true;
  }
}
