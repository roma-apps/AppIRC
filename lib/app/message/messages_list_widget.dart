import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_messages_loader_bloc.dart';
import 'package:flutter_appirc/app/db/chat_database.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_widgets.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';
import 'package:flutter_appirc/app/message/messages_special_widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';

class NetworkChannelMessagesListWidget extends StatelessWidget {
  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    var backendService = Provider.of<ChatOutputBackendService>(context);
    var channelBloc = Provider.of<NetworkChannelBloc>(context);
    var chatDatabase = Provider.of<ChatDatabaseProvider>(context).db;

    NetworkChannelMessagesLoaderBloc messagesLoader =
        NetworkChannelMessagesLoaderBloc(backendService, chatDatabase,
            channelBloc.network, channelBloc.channel);

    return StreamBuilder<List<ChatMessage>>(
        stream: messagesLoader.messagesStream,
        initialData: messagesLoader.currentMessages,
        builder:
            (BuildContext context, AsyncSnapshot<List<ChatMessage>> snapshot) {
          var messages = snapshot.data;
          if (messages != null) {
            messages =
                messages.where((message) => _isNeedPrint(message)).toList();
          }

          if (messages == null || messages.length == 0) {
            return StreamBuilder<NetworkChannelState>(
              stream: channelBloc.networkChannelStateStream,
              initialData: channelBloc.networkChannelState,
              builder: (BuildContext context,
                  AsyncSnapshot<NetworkChannelState> snapshot) {
                var currentChannelState = snapshot.data;

                if (currentChannelState.connected) {
                  return Center(
                      child: Text(
                          AppLocalizations.of(context).tr("chat.empty_channel"),
                          style: TextStyle(
                              color: AppSkinBloc.of(context)
                                  .appSkinTheme
                                  .textColor)));
                } else {
                  return Center(
                      child: Text(
                          AppLocalizations.of(context)
                              .tr("chat.not_connected_channel"),
                          style: TextStyle(
                              color: AppSkinBloc.of(context)
                                  .appSkinTheme
                                  .textColor)));
                }
              },
            );
          } else {
            var result = Padding(
              padding: const EdgeInsets.symmetric(vertical:10.0),
              child: ListView.builder(
                  itemCount: messages.length,
                  controller: _scrollController,
                  itemBuilder: (BuildContext context, int index) {
                    var message = messages[index];

                    var chatMessageType = message.chatMessageType;

                    switch (chatMessageType) {
                      case ChatMessageType.SPECIAL:
                        var specialMessage = message as SpecialMessage;
                        return buildSpecialMessageWidget(
                            context, specialMessage);
                        break;
                      case ChatMessageType.REGULAR:
                        return buildRegularMessage(context, message);
                        break;
                    }

                    throw Exception("Invalid message type = $chatMessageType");
                  }),
            );

         Timer.run( () {
              var bottomOffset = _scrollController.position.maxScrollExtent * 3;
              // TODO: Remove magic 3 number
              // Looks like bug in ListView _scrollController.position
              // .maxScrollExtent should be always bottom value
              // However it is not true when list view contains Text
              // with new lines characters
              _scrollController.animateTo(bottomOffset,
                  duration: const Duration(milliseconds: 200),
                  curve: Curves.easeOut);
//              _scrollController.jumpTo(
//                  _scrollController.position.maxScrollExtent);
            });
            return result;
          }
        });
  }
}

_isNeedPrint(ChatMessage message) {
  if (message is RegularMessage) {
    var regularMessageType = message.regularMessageType;
    return regularMessageType != RegularMessageType.RAW;
  } else {
    return true;
  }
}
