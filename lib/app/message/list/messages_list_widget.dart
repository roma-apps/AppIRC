import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/messages/chat_messages_list_bloc.dart';
import 'package:flutter_appirc/app/chat/messages/chat_messages_model.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/regular/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/regular/messages_regular_skin_bloc.dart';
import 'package:flutter_appirc/app/message/regular/messages_regular_widgets.dart';
import 'package:flutter_appirc/app/message/special/messages_special_model.dart';
import 'package:flutter_appirc/app/message/special/messages_special_widgets.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

var _logger =
    MyLogger(logTag: "messages_list_widget.dart", enabled: true);

class NetworkChannelMessagesListWidget extends StatefulWidget {
  NetworkChannelMessagesListWidget();

  @override
  _NetworkChannelMessagesListWidgetState createState() =>
      _NetworkChannelMessagesListWidgetState();
}

class _NetworkChannelMessagesListWidgetState
    extends State<NetworkChannelMessagesListWidget> {
  ItemPositionsListener positionsListener;

  ItemScrollController scrollController;

  StreamSubscription<ChatMessagesListSearchState> positionSubscription;

  List<ChatMessage> lastBuiltMessages;
  ChatMessage lastSearchJumpMessage;

  int _lastBuildMessagesStartIndex = 0;
  List<ChatMessage> _lastBuildFilteredMessages;

  @override
  void dispose() {
    super.dispose();
    positionsListener.itemPositions.removeListener(onVisiblePositionsChanged);
    positionSubscription?.cancel();
  }

  @override
  void initState() {
    super.initState();
    scrollController = ItemScrollController();
    positionsListener = ItemPositionsListener.create();

    positionsListener.itemPositions.addListener(onVisiblePositionsChanged);

    Timer.run(() {
      // we need Timer.run to have valid context for Provider

      ChatMessagesListBloc chatListMessagesBloc = Provider.of(context);
      positionSubscription =
          chatListMessagesBloc.searchStateStream.listen((newState) {
        var message = newState.selectedFoundMessage;
        if (message != null) {
          var indexToJump = _lastBuildFilteredMessages?.indexOf(message);
          scrollController.jumpTo(
              index: indexToJump + _lastBuildMessagesStartIndex);
        }
      });
    });
  }

  void onVisiblePositionsChanged() {
    if (_lastBuildFilteredMessages != null) {
      var visiblePositions = positionsListener.itemPositions.value;
//      _logger.d(() => "visiblePositions $visiblePositions");

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
        minIndex -= _lastBuildMessagesStartIndex;
        maxIndex -= _lastBuildMessagesStartIndex;

        if (minIndex < 0) {
          minIndex = 0;
        }

        // context always valid, because this function used only when widget is
        // visible
        NetworkChannelBloc channelBloc = NetworkChannelBloc.of(context);

        channelBloc.messagesBloc.onVisibleMessagesBounds(VisibleMessagesBounds(
            min: _lastBuildFilteredMessages[minIndex],
            max: _lastBuildFilteredMessages[maxIndex]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ChatMessagesListBloc chatListMessagesBloc = Provider.of(context);

    _logger.d(() => "build for ${chatListMessagesBloc.listState}");

    return StreamBuilder<ChatMessagesListState>(
        stream: chatListMessagesBloc.listStateStream,
        initialData: chatListMessagesBloc.listState,
        builder: (BuildContext context,
            AsyncSnapshot<ChatMessagesListState> snapshot) {
          ChatMessagesListState chatMessageListState = snapshot.data;
          return _buildMessagesList(
              context, chatListMessagesBloc, chatMessageListState);
        });
  }

  Widget _buildMessagesList(
      BuildContext context,
      ChatMessagesListBloc chatListMessagesBloc,
      ChatMessagesListState chatMessageListState) {
    var originalMessages = chatMessageListState.messages;

    var filteredMessages = originalMessages
        .where((message) => _isNeedPrintChatMessage(message))
        .toList();

    _logger.d(() => "_buildMessagesList "
        "originalMessages ${originalMessages.length} "
        "filteredMessages ${filteredMessages?.length}");

    if (filteredMessages == null || filteredMessages.isEmpty) {
      return _buildListViewEmptyWidget(context);
    } else {
      var visibleMessagesBounds =
          chatListMessagesBloc.channelMessagesListBloc.visibleMessagesBounds;
      ChatMessage messageForInitScrollPosition;

      if (visibleMessagesBounds != null) {
        messageForInitScrollPosition = visibleMessagesBounds.min;
      } else {
        NetworkChannelBloc channelBloc = NetworkChannelBloc.of(context);
        var firstUnreadRemoteMessageId =
            channelBloc.networkChannelState.firstUnreadRemoteMessageId;
        if (firstUnreadRemoteMessageId != null) {
          messageForInitScrollPosition = filteredMessages.firstWhere((message) {
            if (message is RegularMessage) {
              return message.messageRemoteId == firstUnreadRemoteMessageId;
            } else {
              return false;
            }
          }, orElse: () => null);
        }
        if (messageForInitScrollPosition == null) {
          _logger.w(() => "use latest message for init scroll");
          messageForInitScrollPosition = filteredMessages.last;
        }
      }
      _logger.d(() => "_buildMessagesList "
          "visibleMessagesBounds $visibleMessagesBounds "
          "messageForInitScrollPosition $messageForInitScrollPosition "
          "firstUnreadRemoteMessageId ${NetworkChannelBloc.of(context).networkChannelState.firstUnreadRemoteMessageId}");

      return _buildListWidget(
          context,
          originalMessages,
          filteredMessages,
          chatMessageListState.moreHistoryAvailable,
          chatListMessagesBloc.searchState,
          messageForInitScrollPosition);
    }
  }

  Widget _buildListWidget(
      BuildContext context,
      List<ChatMessage> originalMessages,
      List<ChatMessage> filteredMessages,
      bool moreHistoryAvailable,
      ChatMessagesListSearchState searchState,
      ChatMessage messageForInitScrollPosition) {
    _lastBuildFilteredMessages = filteredMessages;
    var itemCount = filteredMessages.length;

    int initialScrollIndex =
        filteredMessages.indexOf(messageForInitScrollPosition);

    if (moreHistoryAvailable) {
      itemCount += 1;
      initialScrollIndex += 1;
      _lastBuildMessagesStartIndex = 1;
    } else {
      _lastBuildMessagesStartIndex = 0;
    }

    if (initialScrollIndex == 1 && moreHistoryAvailable) {
      // hack to display load more button
      // when list want to display first message
      initialScrollIndex = 0;
    }

    _logger.d(() => "_buildListWidget "
        "itemCount $itemCount "
        "initialScrollIndex = $initialScrollIndex "
        "moreHistoryAvailable $moreHistoryAvailable");

    double initialAlignment = 0.0;

    var lastIndex = itemCount - 1;
    if (initialScrollIndex == lastIndex && initialScrollIndex != 0) {
      // hack to display last message at the bottom
      // when list want to display last message
      initialScrollIndex += 1;
      initialAlignment = 1.0;
    }

    return ScrollablePositionedList.builder(
        initialScrollIndex: initialScrollIndex,
        itemScrollController: scrollController,
        itemPositionsListener: positionsListener,
        itemCount: itemCount,
        initialAlignment: initialAlignment,
        itemBuilder: (BuildContext context, int index) {
          _logger.d(() => "itemBuilder $index filteredMessages "
              "${filteredMessages.length}");

          if (moreHistoryAvailable) {
            if (index == 0) {
              // return the header
              // we should pass non-filtered list to extract non-filtered
              // oldest message
              return _buildLoadMoreButton(context, originalMessages);
            } else {
              // move start index
              index -= 1;
            }
          }

          if (index >= filteredMessages.length) {
            return null;
          }

          var message = filteredMessages[index];
          var inSearchResults =
              searchState?.isMessageInSearchResults(message) ?? false;
          return _buildListItem(
              context, message, inSearchResults, searchState?.searchTerm);
        });
  }

  Container _buildListItem(BuildContext context, ChatMessage message,
      bool inSearchResults, String searchTerm) {
    Widget messageBody =
        _buildMessageBody(context, message, inSearchResults, searchTerm);

    var decoration = _calculateDecoration(context, message, inSearchResults);

    return Container(decoration: decoration, child: messageBody);
  }

  Widget _buildMessageBody(BuildContext context, ChatMessage message,
      bool inSearchResults, String searchTerm) {
    Widget messageBody;

    var chatMessageType = message.chatMessageType;

    switch (chatMessageType) {
      case ChatMessageType.special:
        var specialMessage = message as SpecialMessage;
        messageBody = buildSpecialMessageWidget(
            context, specialMessage, inSearchResults, searchTerm);
        break;
      case ChatMessageType.regular:
        messageBody =
            buildRegularMessage(context, message, inSearchResults, searchTerm);
        break;
    }

    if (messageBody == null) {
      throw Exception("Invalid message type = $chatMessageType");
    }
    return messageBody;
  }

  _calculateDecoration(
      BuildContext context, ChatMessage message, bool isHighlightBySearch) {
    var decoration;
    bool isHighlightByServer;

    if (message is RegularMessage) {
      isHighlightByServer = message.highlight;
    }

    if (isHighlightBySearch) {
      var messagesSkin = Provider.of<MessagesRegularSkinBloc>(context);
      decoration =
          BoxDecoration(color: messagesSkin.highlightSearchBackgroundColor);
    } else {
      if (isHighlightByServer ??= false) {
        var messagesSkin = Provider.of<MessagesRegularSkinBloc>(context);
        decoration =
            BoxDecoration(color: messagesSkin.highlightServerBackgroundColor);
      }
    }
    return decoration;
  }

  StreamBuilder<bool> _buildListViewEmptyWidget(BuildContext context) {
    var channelBloc = NetworkChannelBloc.of(context);
    return StreamBuilder<bool>(
      stream: channelBloc.networkChannelConnectedStream,
      initialData: channelBloc.networkChannelConnected,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        var connected = snapshot.data;

        if (connected) {
          return Center(
              child: Text(
                  AppLocalizations.of(context).tr("chat.messages_list"
                      ".empty.connected"),
                  style: TextStyle(
                      color: AppSkinBloc.of(context).appSkinTheme.textColor)));
        } else {
          return Center(
              child: Text(
                  AppLocalizations.of(context).tr("chat.messages_list.empty"
                      ".not_connected"),
                  style: TextStyle(
                      color: AppSkinBloc.of(context).appSkinTheme.textColor)));
        }
      },
    );
  }
}

Widget _buildLoadMoreButton(BuildContext context, List<ChatMessage> messages) =>
    createSkinnedPlatformButton(context, onPressed: () {
      doAsyncOperationWithDialog(context, asyncCode: () async {
        var oldestRegularMessage = messages.firstWhere(
                (message) => message.chatMessageType == ChatMessageType.regular)
            as RegularMessage;

        var channelBloc = NetworkChannelBloc.of(context);
        return await channelBloc.loadMoreHistory(oldestRegularMessage);
      }, cancellationValue: null, isDismissible: true);
    },
        child: Text(AppLocalizations.of(context).tr("chat.messages_list.action"
            ".load_more")));

_isNeedPrintChatMessage(ChatMessage message) {
  if (message is RegularMessage) {
    var regularMessageType = message.regularMessageType;
    return regularMessageType != RegularMessageType.raw;
  } else {
    return true;
  }
}
