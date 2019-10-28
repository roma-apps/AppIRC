import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/list/message_list_bloc.dart';
import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/app/message/list/message_list_skin_bloc.dart';
import 'package:flutter_appirc/app/message/list/search/message_list_search_model.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_widget.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_widget.dart';
import 'package:flutter_appirc/async/async_dialog.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';
import 'package:flutter_appirc/skin/text_skin_bloc.dart';
import 'package:flutter_widgets/flutter_widgets.dart';

var _logger = MyLogger(logTag: "message_list_widget.dart", enabled: true);

class MessageListWidget extends StatefulWidget {

  MessageListWidget();

  @override
  _MessageListWidgetState createState() =>
      _MessageListWidgetState();
}

class _MessageListWidgetState extends State<MessageListWidget> {


  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();

  final ItemScrollController _scrollController = ItemScrollController();

  StreamSubscription<MessageListSearchState> _positionSubscription;

  int _lastBuildMessagesStartIndex = 0;
  List<ChatMessage> _lastBuildFilteredMessages;

  @override
  void dispose() {
    super.dispose();
    _positionsListener.itemPositions.removeListener(onVisiblePositionsChanged);
    _positionSubscription?.cancel();
  }

  @override
  void initState() {
    super.initState();

    _positionsListener.itemPositions.addListener(onVisiblePositionsChanged);

  }

  void _jumpTo(MessageListSearchState newState) {
    _logger.d(() => "newSearchState $newState");
    var message = newState.selectedFoundMessage;
    if (message != null) {
      var indexToJump = _lastBuildFilteredMessages?.indexOf(message);
      _logger.d(() => "_jumpToSavedIndex $message"
          "indexToJump $indexToJump");
      _scrollController?.jumpTo(
          index: indexToJump + _lastBuildMessagesStartIndex);
    }
  }

  void onVisiblePositionsChanged() {
    if (_lastBuildFilteredMessages != null) {
      var visiblePositions = _positionsListener.itemPositions.value;
      _logger.d(() => "visiblePositions $visiblePositions"
          "_lastBuildMessagesStartIndex $_lastBuildMessagesStartIndex");

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

        if (maxIndex >= _lastBuildFilteredMessages.length) {
          maxIndex = _lastBuildFilteredMessages.length - 1;
        }

        // context always valid, because this function used only when widget is
        // visible
        ChannelBloc channelBloc = ChannelBloc.of(context);

        channelBloc.messagesBloc.onVisibleMessagesBounds(
            MessageListVisibleBounds(
                min: _lastBuildFilteredMessages[minIndex],
                max: _lastBuildFilteredMessages[maxIndex]));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    MessageListBloc chatListMessagesBloc = Provider.of(context);

    _logger.d(() => "build for ${chatListMessagesBloc.listState}");

    return StreamBuilder<MessageListState>(
        stream: chatListMessagesBloc.listStateStream,
        initialData: chatListMessagesBloc.listState,
        builder:
            (BuildContext context, AsyncSnapshot<MessageListState> snapshot) {
          MessageListState chatMessageListState = snapshot.data;
          return _buildMessagesList(context, chatMessageListState);
        });
  }

  Widget _buildMessagesList(
      BuildContext context, MessageListState chatMessageListState) {
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
      return _buildMessagesListWidget(
          context, chatMessageListState, filteredMessages);
    }
  }

  Widget _buildMessagesListWidget(
      BuildContext context,
      MessageListState chatMessageListState,
      List<ChatMessage> filteredMessages) {
    MessageListBloc chatListMessagesBloc = Provider.of(context);
    var visibleMessagesBounds =
        chatListMessagesBloc.channelMessagesListBloc.visibleMessagesBounds;

    ChatMessage initScrollPositionMessage = _calculateInitScrollPositionMessage(
        context, visibleMessagesBounds, filteredMessages);


    return StreamBuilder<MessageListSearchState>(
      stream: chatListMessagesBloc.searchStateStream,
      initialData: chatListMessagesBloc.searchState,
      builder: (context, snapshot) {

        var searchState = snapshot.data;

        _jumpTo(searchState);
        return _buildListWidget(
            context,
            chatMessageListState.messages,
            filteredMessages,
            chatMessageListState.moreHistoryAvailable ?? false,
//            chatListMessagesBloc.searchState,
            searchState,
            initScrollPositionMessage);
      }
    );
  }

  ChatMessage _calculateInitScrollPositionMessage(
      BuildContext context,
      MessageListVisibleBounds visibleMessagesBounds,
      List<ChatMessage> filteredMessages) {
    ChatMessage initScrollPositionMessage;

    if (visibleMessagesBounds != null) {
      initScrollPositionMessage = visibleMessagesBounds.min;
    } else {
      ChannelBloc channelBloc = ChannelBloc.of(context);
      var firstUnreadRemoteMessageId =
          channelBloc.channelState.firstUnreadRemoteMessageId;
      if (firstUnreadRemoteMessageId != null) {
        initScrollPositionMessage = filteredMessages.firstWhere((message) {
          if (message is RegularMessage) {
            return message.messageRemoteId == firstUnreadRemoteMessageId;
          } else {
            return false;
          }
        }, orElse: () => null);
      }
      if (initScrollPositionMessage == null) {
        _logger.w(() => "use latest message for init scroll");
        initScrollPositionMessage = filteredMessages.last;
      }
      _logger.d(() => "_buildMessagesList "
          "visibleMessagesBounds $visibleMessagesBounds "
          "initScrollPositionMessage $initScrollPositionMessage ");
    }
    return initScrollPositionMessage;
  }

  Widget _buildListWidget(
      BuildContext context,
      List<ChatMessage> originalMessages,
      List<ChatMessage> filteredMessages,
      bool moreHistoryAvailable,
      MessageListSearchState searchState,
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
        "filteredMessages ${filteredMessages?.length}"
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
        itemScrollController: _scrollController,
        itemPositionsListener: _positionsListener,
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

    var decoration =
        _createMessageDecoration(context, message, inSearchResults);

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

  isNeedHighlight(RegularMessage message) =>
      message.highlight == true ||
      message.regularMessageType == RegularMessageType.unknown;

  _createMessageDecoration(
      BuildContext context, ChatMessage message, bool isHighlightBySearch) {
    var decoration;
    bool isHighlightByServer;

    if (message is RegularMessage) {
      isHighlightByServer = isNeedHighlight(message);
    }

    var messagesSkin = Provider.of<MessageListSkinBloc>(context);
    if (isHighlightBySearch) {
      decoration = messagesSkin.highlightSearchDecoration;
    } else {
      if (isHighlightByServer ??= false) {
        decoration = messagesSkin.highlightServerDecoration;
      }
    }
    return decoration;
  }

  StreamBuilder<bool> _buildListViewEmptyWidget(BuildContext context) {
    TextSkinBloc textSkinBloc = Provider.of(context);
    var channelBloc = ChannelBloc.of(context);
    return StreamBuilder<bool>(
      stream: channelBloc.channelConnectedStream,
      initialData: channelBloc.channelConnected,
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        var connected = snapshot.data;

        if (connected) {
          return Center(
              child: Text(
                  AppLocalizations.of(context)
                      .tr("chat.messages_list.empty.connected"),
                  style: textSkinBloc.defaultTextStyle));
        } else {
          return Center(
              child: Text(
                  AppLocalizations.of(context)
                      .tr("chat.messages_list.empty.not_connected"),
                  style: textSkinBloc.defaultTextStyle));
        }
      },
    );
  }
}

Widget _buildLoadMoreButton(BuildContext context, List<ChatMessage> messages) =>
    createSkinnedPlatformButton(context, onPressed: () {
      doAsyncOperationWithDialog(
          context: context,
          asyncCode: () async {
            var oldestRegularMessage = messages?.firstWhere(
                (message) => message.chatMessageType == ChatMessageType.regular,
                orElse: null) as RegularMessage;

            var channelBloc = ChannelBloc.of(context);
            return await channelBloc.loadMoreHistory(oldestRegularMessage);
          },
          cancellationValue: null,
          isDismissible: true);
    },
        child: Text(AppLocalizations.of(context)
            .tr("chat.messages_list.action.load_more")));

_isNeedPrintChatMessage(ChatMessage message) {
  if (message is RegularMessage) {
    var regularMessageType = message.regularMessageType;
    return regularMessageType != RegularMessageType.raw;
  } else {
    return true;
  }
}
