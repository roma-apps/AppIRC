import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_channel_widget.dart';
import 'package:flutter_appirc/app/chat/chat_messages_list_bloc.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_skin_bloc.dart';
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

  StreamSubscription<int> positionSubscription;

  @override
  void dispose() {
    super.dispose();
    positionsListener.itemPositions.removeListener(onVisiblePositionsChanged);
    positionSubscription?.cancel();
  }

  @override
  void initState() {
    super.initState();

    positionsListener.itemPositions.addListener(onVisiblePositionsChanged);

    Timer.run(() {
      ChatMessagesListBloc chatListMessagesBloc = Provider.of(context);
      positionSubscription =
          chatListMessagesBloc.allMessagesPositionStream.listen((newPosition) {
        if (newPosition != null) {
          scrollController?.jumpTo(
              index: newPosition + lastBuildMessagesStartIndex);
        }
      });
    });
  }

  var lastBuildMessagesStartIndex = 0;

  void onVisiblePositionsChanged() {
    var visiblePositions = positionsListener.itemPositions.value;
    _logger.d(() => "visiblePositions $visiblePositions");

    if (visiblePositions.isNotEmpty) {
      var minIndex = visiblePositions.first.index;
      var maxIndex = visiblePositions.first.index;

      visiblePositions.forEach((position) {
        if (minIndex > position.index) {
          minIndex = position.index;
        }

        if (maxIndex < position.index) {
          maxIndex = position.index;
        }
      });
      minIndex -= lastBuildMessagesStartIndex;
      maxIndex -= lastBuildMessagesStartIndex;

      if (minIndex < 0) {
        minIndex = 0;
      }
      visibleAreaCallback(minIndex, maxIndex);
    }
  }

  _NetworkChannelMessagesListWidgetState(this.visibleAreaCallback);

  final scrolledToStartIndex = false;

  @override
  Widget build(BuildContext context) {
    var channelBloc = NetworkChannelBloc.of(context);
    ChatMessagesListBloc chatListMessagesBloc = Provider.of(context);
    _logger.d(() => "_NetworkChannelMessagesListWidgetState build"
        "${channelBloc.channel.name}");

    return StreamBuilder<ChatMessagesWrapperState>(
        stream: chatListMessagesBloc.allMessagesStateStream,
        initialData: chatListMessagesBloc.allMessagesState,
        builder: (BuildContext context,
            AsyncSnapshot<ChatMessagesWrapperState> snapshot) {
          var chatMessagesWrapperState = snapshot.data;
          _logger.d(() => "chatMessagesWrapperState build for "
              "${channelBloc.channel.name} "
              "=${chatMessagesWrapperState.messages?.length}");

//          // todo: remove hack
//          if (chatMessagesWrapperState.channel != null &&
//              chatMessagesWrapperState.channel != channelBloc.channel) {
//            return SizedBox.shrink();
//          }

          var originalMessagesWrappers = chatMessagesWrapperState.messages;
          List<ChatMessageWrapper> filteredMessagesWrappers =
              originalMessagesWrappers;

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

            _logger.d(() => "rebuild ScrollablePositionedList $itemCount"
                "for ${channelBloc.channel.name} ");
//            return ListView.builder(
            var lastIndex = itemCount - 1;
            int initialScrollIndex;

            _logger.d(() => "rebuild chatMessagesWrapperState.newScrollIndex "
                "${chatMessagesWrapperState.newScrollIndex}");

            if (chatMessagesWrapperState.newScrollIndex != null) {
              initialScrollIndex = chatMessagesWrapperState.newScrollIndex;
            } else {
              var firstUnreadRemoteMessageId =
                  Provider.of<NetworkChannelBlocProvider>(context)
                      .networkChannelBloc
                      .networkChannelState
                      .firstUnreadRemoteMessageId;

              _logger.d(() => "rebuild firstUnreadRemoteMessageId "
                  "$firstUnreadRemoteMessageId");
              if (firstUnreadRemoteMessageId != null) {
                var foundIndex = filteredMessagesWrappers.indexWhere((wrapper) {
                  var message = wrapper.message;
                  if (message is RegularMessage) {
                    return message.messageRemoteId ==
                        firstUnreadRemoteMessageId;
                  } else {
                    return false;
                  }
                });

                _logger.d(() => "rebuild firstUnreadRemoteMessageId "
                    "foundIndex $foundIndex");
                if (foundIndex != null && foundIndex > 0) {
                  initialScrollIndex = foundIndex;
                } else {
                  initialScrollIndex = lastIndex;
                }
              } else {
                initialScrollIndex = lastIndex;
              }
            }

            if (moreHistoryAvailable) {
              initialScrollIndex -= 1;
              lastBuildMessagesStartIndex = 1;
            } else {
              lastBuildMessagesStartIndex = 0;
            }
            var initialAlignment = 0.0;

            return ScrollablePositionedList.builder(
                initialScrollIndex: initialScrollIndex,
                initialAlignment: initialAlignment,
                itemScrollController: scrollController,
                itemPositionsListener: positionsListener,
//            return ListView.builder(
                itemCount: itemCount,
                itemBuilder: (BuildContext context, int index) {
                  if (moreHistoryAvailable && index == 0) {
                    // return the header
                    return _buildLoadMoreButton(
                        context, channelBloc, originalMessagesWrappers);
                  }
                  index -= 1;

                  if (index >= filteredMessagesWrappers.length) {
                    return SizedBox.shrink();
                  }

                  _logger.d(() => "build index $index");

                  var messageWrapper = filteredMessagesWrappers[index];
                  var message = messageWrapper.message;

                  var chatMessageType = message.chatMessageType;

                  Widget messageBody;
                  switch (chatMessageType) {
                    case ChatMessageType.SPECIAL:
                      var specialMessage = message as SpecialMessage;
                      messageBody =
                          buildSpecialMessageWidget(context, specialMessage,
                              messageWrapper.includedInSearchResult,
                              chatMessagesWrapperState.searchTerm);
                      messageBody = Text("index $index");
                      break;
                    case ChatMessageType.REGULAR:
                      messageBody = buildRegularMessage(context, message,
                          messageWrapper.includedInSearchResult,
                          chatMessagesWrapperState.searchTerm);
//                      messageBody = Text("index $index");
                      break;
                  }

                  if (messageBody == null) {
                    throw Exception("Invalid message type = $chatMessageType");
                  }

                  var decoration;
                  bool isHighlightBySearch =
                      messageWrapper.includedInSearchResult;
                  bool isHighlightByServer;


                  if (message is RegularMessage) {
                    isHighlightByServer = message.highlight;
                  }

                  if (isHighlightBySearch) {
                    var messagesSkin =
                        Provider.of<MessagesRegularSkinBloc>(context);
                    decoration = BoxDecoration(
                        color: messagesSkin.highlightSearchBackgroundColor);
                  } else {
                    if (isHighlightByServer ??= false) {
                      var messagesSkin =
                          Provider.of<MessagesRegularSkinBloc>(context);
                      decoration = BoxDecoration(
                          color: messagesSkin.highlightServerBackgroundColor);
                    }
                  }

                  return Container(decoration: decoration, child: messageBody);
                });
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
