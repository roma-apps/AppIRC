import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_condensed_model.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_condensed_widget.dart';
import 'package:flutter_appirc/app/message/list/date_separator/message_list_date_separator_model.dart';
import 'package:flutter_appirc/app/message/list/date_separator/message_list_date_separator_widget.dart';
import 'package:flutter_appirc/app/message/list/jump_to_newest/message_list_jump_to_newest_bloc.dart';
import 'package:flutter_appirc/app/message/list/jump_to_newest/message_list_jump_to_newest_widget.dart';
import 'package:flutter_appirc/app/message/list/load_more/message_list_load_more_bloc.dart';
import 'package:flutter_appirc/app/message/list/load_more/message_list_load_more_widget.dart';
import 'package:flutter_appirc/app/message/list/message_list_bloc.dart';
import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/app/message/message_widget.dart';
import 'package:flutter_appirc/disposable/async_disposable.dart';
import 'package:flutter_appirc/disposable/disposable.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/text_skin_bloc.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

var _logger = MyLogger(logTag: "message_list_widget.dart", enabled: true);

class MessageListWidget extends StatefulWidget {
  final MessageListLoadMoreBloc loadMoreBloc;
  final MessagesListJumpToNewestBloc messagesListJumpToNewestBloc;

  MessageListWidget(this.loadMoreBloc, this.messagesListJumpToNewestBloc);

  @override
  _MessageListWidgetState createState() => _MessageListWidgetState();
}

class _MessageListWidgetState extends State<MessageListWidget> {
  final ItemPositionsListener _positionsListener =
      ItemPositionsListener.create();

  final ItemScrollController _scrollController = ItemScrollController();

  int _lastBuildMessagesStartIndex = 0;
  List<MessageListItem> _lastBuildItems;

  @override
  void dispose() {
    super.dispose();
    _positionsListener.itemPositions.removeListener(onVisiblePositionsChanged);
    disposable.dispose();
  }

  CompositeDisposable disposable = CompositeDisposable([]);

  @override
  void initState() {
    super.initState();

    _positionsListener.itemPositions.addListener(onVisiblePositionsChanged);

    Timer.run(() {
      MessageListBloc messageListBloc = Provider.of(context);

      disposable.add(StreamSubscriptionDisposable(messageListBloc
          .listJumpDestinationStream
          .listen((newJumpDestination) {
        nextJumpDestination = newJumpDestination;
        Timer.run(() {
          _jumpToMessage();
        });
      })));
    });
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
        if (minIndex == 0) {
          widget.loadMoreBloc.loadMore();
        }

        minIndex -= _lastBuildMessagesStartIndex;
        maxIndex -= _lastBuildMessagesStartIndex;

        if (minIndex < 0) {
          minIndex = 0;
        }

        if (maxIndex >= _lastBuildItems.length) {
          maxIndex = _lastBuildItems.length - 1;
        }

        if (maxIndex == _lastBuildItems.length - 1) {
          widget.messagesListJumpToNewestBloc.onVisibleAreaChanged(true);
        } else {
          widget.messagesListJumpToNewestBloc.onVisibleAreaChanged(false);
        }

        _logger.d(() => "minIndex $minIndex "
            "maxIndex $maxIndex "
            "_lastBuildItems.length ${_lastBuildItems.length}");

        // context always valid, because this function used only when widget is
        // visible
        ChannelBloc channelBloc = ChannelBloc.of(context);

        channelBloc.messagesBloc.onVisibleMessagesBounds(
            MessageListVisibleBounds.fromUi(
                minRegularMessageRemoteId: _lastBuildItems[minIndex]
                    .oldestRegularMessage
                    ?.messageRemoteId,
                maxRegularMessageRemoteId: _lastBuildItems[maxIndex]
                    .oldestRegularMessage
                    ?.messageRemoteId));
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
        chatListMessagesBloc.calculateInitScrollPositionMessage(
            visibleMessagesBounds, chatMessageListState.items);

    return _buildListWidget(
        context, chatMessageListState.items, initScrollPositionItem);
  }

  MessageListJumpDestination nextJumpDestination;

  void _jumpToMessage() {
    if (nextJumpDestination != null && _scrollController != null) {
      var indexToJump = nextJumpDestination.items?.indexWhere(
          (listItem) => listItem == nextJumpDestination.selectedFoundItem);
      _logger.d(() => "_jumpToMessage ${nextJumpDestination.selectedFoundItem}"
          "indexToJump $indexToJump");
      try {
        _scrollController?.jumpTo(
            index: indexToJump + _lastBuildMessagesStartIndex,
            alignment: nextJumpDestination.alignment);
      } catch (e) {
        _logger.e(() => "error during _jumpToMessage $e");
      }
      nextJumpDestination = null;
    }
  }

  Widget _buildListWidget(
      BuildContext context,
      List<MessageListItem> items,
//      MessageListSearchState searchState,
      MessageListItem messageForInitScrollItem) {
    _lastBuildItems = items;
    var itemCount = items.length;

    int initialScrollIndex =
        items.indexWhere((item) => item == messageForInitScrollItem);

    // more history
    itemCount += 1;
    initialScrollIndex += 1;
    _lastBuildMessagesStartIndex = 1;

    if (initialScrollIndex == 1) {
      // hack to display load more button
      // when list want to display first message
      initialScrollIndex = 0;
    }

    _logger.d(() => "_buildListWidget "
        "itemCount $itemCount "
        "items ${items?.length}"
        "initialScrollIndex = $initialScrollIndex ");

    double initialAlignment = 0.0;

    var lastIndex = itemCount - 1;
    if (initialScrollIndex == lastIndex && initialScrollIndex != 0) {
      // hack to display last message at the bottom
      // when list want to display last message
      initialScrollIndex += 1;
      initialAlignment = 1.0;
    }

    return Stack(
      children: <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 2.0),
          child: ScrollablePositionedList.builder(
              initialScrollIndex: initialScrollIndex,
              itemScrollController: _scrollController,
              itemPositionsListener: _positionsListener,
              itemCount: itemCount,
              initialAlignment: initialAlignment,
              itemBuilder: (BuildContext context, int index) {
                _logger.d(() => "itemBuilder $index items "
                    "${items.length}");

                if (index == 0) {
                  // return the header
                  // we should pass non-filtered list to extract non-filtered
                  // oldest message
                  return MessageListLoadMoreWidget();
                } else {
                  // move start index
                  index -= 1;
                }

                if (index >= items.length || index < 0) {
                  return null;
                }

                var item = items[index];
                return _buildListItem(
                  context, item,
                );
              }),
        ),
        _buildJumpWidget(context)
      ],
    );
  }

  Widget _buildJumpWidget(BuildContext context) {

    ChannelBloc channelBloc = ChannelBloc.of(context);

    return channelBloc.channel.type != ChannelType.special ? Align(
          alignment: Alignment.bottomCenter,
          child: MessageListJumpToNewestWidget()) : SizedBox.shrink();
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
                  tr("chat.messages_list.empty.connected"),
                  style: textSkinBloc.defaultTextStyle));
        } else {
          return Center(
              child: Text(
                  tr("chat.messages_list.empty.not_connected"),
                  style: textSkinBloc.defaultTextStyle));
        }
      },
    );
  }
}

Widget _buildListItem(
  BuildContext context,
  MessageListItem item,
) {
  if (item is SimpleMessageListItem) {
    return buildMessageWidget(
        message: item.message,
        messageInListState: notInSearchState,
        enableMessageActions: true,
        messageWidgetType: MessageWidgetType.formatted);
  } else if (item is CondensedMessageListItem) {
    return CondensedMessageWidget(item);
  } else if (item is DaysDateSeparatorMessageListItem) {
    return DaysDateSeparatorMessageListItemWidget(item);
  } else {
    throw "Invalid message list item type $item";
  }
}
