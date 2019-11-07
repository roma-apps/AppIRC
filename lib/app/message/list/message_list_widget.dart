import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_condensed_model.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_condensed_widget.dart';
import 'package:flutter_appirc/app/message/list/date_separator/message_list_date_separator_model.dart';
import 'package:flutter_appirc/app/message/list/date_separator/message_list_date_separator_widget.dart';
import 'package:flutter_appirc/app/message/list/message_list_bloc.dart';
import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/app/message/list/search/message_list_search_model.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
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
  _MessageListWidgetState createState() => _MessageListWidgetState();
}

class _MessageListWidgetState extends State<MessageListWidget> {
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();

  final ItemScrollController _scrollController = ItemScrollController();

  StreamSubscription<MessageListSearchState> _positionSubscription;

  int _lastBuildMessagesStartIndex = 0;
  List<MessageListItem> _lastBuildItems;

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
    var message = newState.selectedFoundItem;
    if (message != null) {
      var indexToJump = _lastBuildItems?.indexOf(message);
      _logger.d(() => "_jumpToSavedIndex $message"
          "indexToJump $indexToJump");
      _scrollController?.jumpTo(
          index: indexToJump + _lastBuildMessagesStartIndex);
    }
  }

  void onVisiblePositionsChanged() {
    if (_lastBuildItems != null) {
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

        if (maxIndex >= _lastBuildItems.length) {
          maxIndex = _lastBuildItems.length - 1;
        }

        _logger.d(() => "minIndex $minIndex"
            "maxIndex $maxIndex"
            "_lastBuildItems.length ${_lastBuildItems.length}");

        // context always valid, because this function used only when widget is
        // visible
        ChannelBloc channelBloc = ChannelBloc.of(context);

        channelBloc.messagesBloc.onVisibleMessagesBounds(
            MessageListVisibleBounds(
                min: _lastBuildItems[minIndex],
                max: _lastBuildItems[maxIndex]));
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
    var items = chatMessageListState.items;

    _logger.d(() => "_buildMessagesList "
        "items ${items.length} ");

    if (items == null || items.isEmpty) {
      return _buildListViewEmptyWidget(context);
    } else {
      return _buildMessagesListWidget(context, chatMessageListState);
    }
  }

  Widget _buildMessagesListWidget(
      BuildContext context, MessageListState chatMessageListState) {
    MessageListBloc chatListMessagesBloc = Provider.of(context);
    var visibleMessagesBounds =
        chatListMessagesBloc.channelMessagesListBloc.visibleMessagesBounds;

    MessageListItem initScrollPositionItem =
        _calculateInitScrollPositionMessage(
            context, visibleMessagesBounds, chatMessageListState.items);

    return StreamBuilder<MessageListSearchState>(
        stream: chatListMessagesBloc.searchStateStream,
        initialData: chatListMessagesBloc.searchState,
        builder: (context, snapshot) {
          var searchState = snapshot.data;

          Timer.run(() {
            _jumpTo(searchState);
          });
          return _buildListWidget(
              context,
              chatMessageListState.items,
              chatMessageListState.moreHistoryAvailable ?? false,
              chatListMessagesBloc.searchState,
              initScrollPositionItem);
        });
  }

  MessageListItem _calculateInitScrollPositionMessage(
      BuildContext context,
      MessageListVisibleBounds visibleMessagesBounds,
      List<MessageListItem> items) {
    MessageListItem initScrollPositionItem;

    if (visibleMessagesBounds != null) {
      initScrollPositionItem = visibleMessagesBounds.min;
    } else {
      ChannelBloc channelBloc = ChannelBloc.of(context);
      var firstUnreadRemoteMessageId =
          channelBloc.channelState.firstUnreadRemoteMessageId;
      if (firstUnreadRemoteMessageId != null) {
        initScrollPositionItem = items.firstWhere((item) {
          return item.isContainsMessageWithRemoteId(firstUnreadRemoteMessageId);
        }, orElse: () => null);
      }
      if (initScrollPositionItem == null) {
        _logger.w(() => "use latest message for init scroll");
        initScrollPositionItem = items.last;
      }
      _logger.d(() => "_buildMessagesList "
          "visibleMessagesBounds $visibleMessagesBounds "
          "initScrollPositionItem $initScrollPositionItem ");
    }
    return initScrollPositionItem;
  }

  Widget _buildListWidget(
      BuildContext context,
      List<MessageListItem> items,
      bool moreHistoryAvailable,
      MessageListSearchState searchState,
      MessageListItem messageForInitScrollItem) {
    _lastBuildItems = items;
    var itemCount = items.length;

    int initialScrollIndex =
        items.indexWhere((item) => item == messageForInitScrollItem);

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
        "items ${items?.length}"
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
//          _logger.d(() => "itemBuilder $index items "
//              "${items.length}");

          if (moreHistoryAvailable) {
            if (index == 0) {
              // return the header
              // we should pass non-filtered list to extract non-filtered
              // oldest message
              return _buildLoadMoreButton(context, items);
            } else {
              // move start index
              index -= 1;
            }
          }

          if (index >= items.length || index < 0) {
            return null;
          }

          var item = items[index];
          var inSearchResults =
              searchState?.isMessageInSearchResults(item) ?? false;
          return _buildListItem(
              context, item, inSearchResults, searchState?.searchTerm);
        });
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

Widget _buildLoadMoreButton(
        BuildContext context, List<MessageListItem> items) =>
    createSkinnedPlatformButton(context, onPressed: () {
      doAsyncOperationWithDialog(
          context: context,
          asyncCode: () async {
            var oldestRegularItem = items?.firstWhere(
                (item) => item.isHaveRegularMessage,
                orElse: () => null);

            var oldestRegularMessage = oldestRegularItem.oldestRegularMessage;

            var channelBloc = ChannelBloc.of(context);
            return await channelBloc.loadMoreHistory(oldestRegularMessage);
          },
          cancellationValue: null,
          isDismissible: true);
    },
        child: Text(AppLocalizations.of(context)
            .tr("chat.messages_list.action.load_more")));

Widget _buildListItem(BuildContext context, MessageListItem item,
    bool inSearchResults, String searchTerm) {
  if (item is SimpleMessageListItem) {
    return buildDecoratedMessageWidget(
        context: context,
        message: item.message,
        inSearchResults: inSearchResults,
        searchTerm: searchTerm);
  } else if (item is CondensedMessageListItem) {
    return CondensedMessageWidget(item, inSearchResults, searchTerm);
  } else if (item is DaysDateSeparatorMessageListItem) {
    return DaysDateSeparatorMessageListItemWidget(item);
  } else {
    throw "Invalid message list item type $item";
  }
}
