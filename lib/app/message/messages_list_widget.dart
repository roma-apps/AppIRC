import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_channel_widget.dart';
import 'package:flutter_appirc/app/chat/chat_messages_list_bloc.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_widgets.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';
import 'package:flutter_appirc/app/message/messages_special_widgets.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

var _logger =
    MyLogger(logTag: "NetworkChannelMessagesListWidget", enabled: true);

class NetworkChannelMessagesListWidget extends StatefulWidget {
  final VisibleAreaCallback visibleAreaCallback;
  NetworkChannelMessagesListWidget(this.visibleAreaCallback);

  @override
  _NetworkChannelMessagesListWidgetState createState() =>
      _NetworkChannelMessagesListWidgetState(visibleAreaCallback);
}

class _NetworkChannelMessagesListWidgetState extends State<NetworkChannelMessagesListWidget> {
  final VisibleAreaCallback visibleAreaCallback;

  final ItemPositionsListener positionsListener = ItemPositionsListener.create();

  final ItemScrollController scrollController = ItemScrollController();



  @override
  void dispose() {
    super.dispose();
    positionsListener.itemPositions.removeListener(onVisiblePositionsChanged);

  }

  @override
  void initState() {
    super.initState();

    positionsListener.itemPositions.addListener(onVisiblePositionsChanged);
  }

  void onVisiblePositionsChanged() {
    var visiblePositions = positionsListener.itemPositions.value;
    if (visiblePositions.isNotEmpty) {
      visibleAreaCallback(
          visiblePositions.first.index, visiblePositions.last.index);
    }
  }

  _NetworkChannelMessagesListWidgetState(this.visibleAreaCallback);

  final scrolledToStartIndex = false;

  @override
  Widget build(BuildContext context) {
    var channelBloc = NetworkChannelBloc.of(context);
    ChatMessagesListBloc chatListMessagesBloc = Provider.of(context);

    return StreamBuilder<ChatMessagesWrapperState>(
        stream: chatListMessagesBloc.allMessagesStateStream,
        initialData: chatListMessagesBloc.allMessagesState,
        builder: (BuildContext context,
            AsyncSnapshot<ChatMessagesWrapperState> snapshot) {
          var chatMessagesWrapperState = snapshot.data;
          var messagesWrappers = chatMessagesWrapperState.messages;
          if (messagesWrappers != null) {
            messagesWrappers = messagesWrappers
                .where((messageWrapper) => _isNeedPrint(messageWrapper))
                .toList();
          }

          if (messagesWrappers == null || messagesWrappers.length == 0) {
            return StreamBuilder<bool>(
              stream: channelBloc.networkChannelConnectedStream,
              initialData: channelBloc.networkChannelConnected,
              builder: (BuildContext context,
                  AsyncSnapshot<bool> snapshot) {
                var connected = snapshot.data;

                if (connected) {
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
              padding: const EdgeInsets.symmetric(vertical: 10.0),
              child:

//              ListView.builder(

                  ScrollablePositionedList.builder(
                      itemCount: messagesWrappers.length,
                      itemScrollController: scrollController,
                      itemPositionsListener: positionsListener,

//                  controller: messagesBloc.scrollController,
                      itemBuilder: (BuildContext context, int index) {
                        if(index >= messagesWrappers.length || index < 0) {
                          return SizedBox.shrink();
                        }
//                        _logger.d(() => "$index");
                        var messageWrapper = messagesWrappers[index];
                        var message = messageWrapper.message;

                        var chatMessageType = message.chatMessageType;

                        Widget messageBody;
                        switch (chatMessageType) {
                          case ChatMessageType.SPECIAL:
                            var specialMessage = message as SpecialMessage;
                            messageBody = buildSpecialMessageWidget(
                                context, specialMessage);
                            break;
                          case ChatMessageType.REGULAR:
                            messageBody = buildRegularMessage(context, message);
                            break;
                        }

                        if (messageBody == null) {
                          throw Exception(
                              "Invalid message type = $chatMessageType");
                        }

                        Border border;
                        if (messageWrapper.includedInSearchResult) {
                          border = Border.all(color: Colors.red);
                        } else {

                          border = Border.all(color: Colors.transparent);
                        }
                        return Container(
                            decoration: BoxDecoration(border: border),
                            child: messageBody);
                      }),
            );

            var forcedMessagesListIndex = chatMessagesWrapperState.newScrollIndex;
            if(forcedMessagesListIndex != null) {
//            scrollController.scrollTo(
//                index: forcedMessagesListIndex,
//                duration: Duration(seconds: 1),
//                curve: Curves.easeInOutCubic);

            Timer.run(() {

            scrollController.jumpTo(
                index: forcedMessagesListIndex);
            });

            }


//            var itemScrollPosition = messagesBloc.itemScrollPosition;
//            if (itemScrollPosition != null && itemScrollPosition > 0 &&
//                itemScrollPosition < messages.length) {
//              itemScrollController.jumpTo(
//                  index: itemScrollPosition, alignment: 1.0);
//            }


//         Timer.run( () {
//              var bottomOffset = _scrollController.position.maxScrollExtent * 3;
//              // TODO: Remove magic 3 number
//              // Looks like bug in ListView _scrollController.position
//              // .maxScrollExtent should be always bottom value
//              // However it is not true when list view contains Text
//              // with new lines characters
//              _scrollController.animateTo(bottomOffset,
//                  duration: const Duration(milliseconds: 200),
//                  curve: Curves.easeOut);
////              _scrollController.jumpTo(
////                  _scrollController.position.maxScrollExtent);
//            });
            return result;
          }
        });
  }
}

_isNeedPrint(ChatMessageWrapper messageWrapper) {
  var message = messageWrapper.message;
  if (message is RegularMessage) {
    var regularMessageType = message.regularMessageType;
    return regularMessageType != RegularMessageType.RAW;
  } else {
    return true;
  }
}
