import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_channel_widget.dart';
import 'package:flutter_appirc/app/chat/chat_messages_list_bloc.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_widgets.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';
import 'package:flutter_appirc/app/message/messages_special_widgets.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';
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

class _NetworkChannelMessagesListWidgetState
    extends State<NetworkChannelMessagesListWidget> {
  final VisibleAreaCallback visibleAreaCallback;

  final ItemPositionsListener positionsListener =
      ItemPositionsListener.create();

  final ItemScrollController scrollController = ItemScrollController();


  @override
  void dispose() {
    super.dispose();
    positionsListener.itemPositions.removeListener(onVisiblePositionsChanged);
  }
  final scrollDirection = Axis.vertical;


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
          var originalMessagesWrappers = chatMessagesWrapperState.messages;
          var filteredMessagesWrappers;
          if (originalMessagesWrappers != null) {
            filteredMessagesWrappers = originalMessagesWrappers
                .where((messageWrapper) => _isNeedPrint(messageWrapper))
                .toList();
          }

          if (filteredMessagesWrappers == null ||
              filteredMessagesWrappers.isEmpty) {
            return StreamBuilder<bool>(
              stream: channelBloc.networkChannelConnectedStream,
              initialData: channelBloc.networkChannelConnected,
              builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
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
            var moreHistoryAvailable =
                chatMessagesWrapperState.moreHistoryAvailable;
            var itemCount = filteredMessagesWrappers.length;

            if (moreHistoryAvailable) {
              itemCount += 1;
            }

            _logger.d(() => "rebuild ScrollablePositionedList");
//            return ListView.builder(
            return ScrollablePositionedList.builder(
                itemCount: itemCount,

                itemScrollController: scrollController,

                itemBuilder: (BuildContext context, int index) {





                  if (moreHistoryAvailable && index == 0) {
                    // return the header
                    return _buildLoadMoreButton(context,
                        channelBloc, originalMessagesWrappers);
                  }
                  index -= 1;

//                  if (index >= filteredMessagesWrappers.length ||
//                      index < 0) {
//                    // hack for ScrollablePositionedList
//                    // sometimes it is ask for widgets outside
//                    // original bounds
//                    return SizedBox.shrink();
//                  }

                  _logger.d(() => "$index");

                  var messageWrapper = filteredMessagesWrappers[index];
                  var message = messageWrapper.message;

                  var chatMessageType = message.chatMessageType;

                  Widget messageBody;
                  switch (chatMessageType) {
                    case ChatMessageType.SPECIAL:
                      var specialMessage = message as SpecialMessage;
                      messageBody =
                          buildSpecialMessageWidget(context, specialMessage);
                      break;
                    case ChatMessageType.REGULAR:
                      messageBody = buildRegularMessage(context, message);
                      break;
                  }

                  if (messageBody == null) {
                    throw Exception("Invalid message type = $chatMessageType");
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

                });

//            var result = Padding(
//              padding: const EdgeInsets.symmetric(vertical: 10.0),
//              child:
//
//
//
//                  StreamBuilder<bool>(
//                      stream:
//                          channelBloc.networkChannelMoreHistoryAvailableStream,
//                      initialData:
//                          channelBloc.networkChannelMoreHistoryAvailable,
//                      builder: (context, snapshot) {
//
//
//                      }),
//            );

//            var forcedMessagesListIndex =
//                chatMessagesWrapperState.newScrollIndex;
//            if (forcedMessagesListIndex != null) {
//              Timer.run(() {
//                scrollController.jumpTo(index: forcedMessagesListIndex);
//              });
//            }

//            var itemScrollPosition = messagesBloc.itemScrollPosition;
//            if (itemScrollPosition != null && itemScrollPosition > 0 &&
//                itemScrollPosition < messages.length) {
//              itemScrollController.jumpTo(
//                  index: itemScrollPosition, alignment: 1.0);
//            }

//            return result;
          }
        });
  }

  Widget _buildLoadMoreButton(
          BuildContext context,
          NetworkChannelBloc channelBloc,
          List<ChatMessageWrapper> messageWrappers) =>
      createSkinnedPlatformButton(context, onPressed: () {
        doAsyncOperationWithDialog(context, () async {
          var oldestRegularMessage = messageWrappers
              .firstWhere((messageWrapper) =>
                  messageWrapper.message.chatMessageType ==
                  ChatMessageType.REGULAR)
              .message as RegularMessage;

          return await channelBloc.loadMoreHistory(oldestRegularMessage);
        });
      },
          child: Text(AppLocalizations.of(context).tr("chat.messages"
              ".load_more")));
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
