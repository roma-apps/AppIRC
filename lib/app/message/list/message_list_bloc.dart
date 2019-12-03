import 'dart:async';

import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/messages/channel_message_list_bloc.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_condensed_model.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_regular_condensed.dart';
import 'package:flutter_appirc/app/message/list/date_separator/message_list_date_separator_model.dart';
import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/app/message/message_loader_bloc.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

import 'condensed/message_condensed_bloc.dart';

var _logger = MyLogger(logTag: "message_list_bloc.dart", enabled: true);

class MessageListBloc extends Providable {
  final ChannelBloc channelBloc;
  final ChannelMessageListBloc _channelMessagesListBloc;
  final MessageCondensedBloc _messageCondensedBloc;

  Stream<MessageListVisibleBounds> get visibleMessagesBoundsStream =>
      channelMessagesListBloc.visibleMessagesBoundsStream;

  MessageListVisibleBounds get visibleMessagesBounds =>
      channelMessagesListBloc.visibleMessagesBounds;

  ChannelMessageListBloc get channelMessagesListBloc =>
      _channelMessagesListBloc;
  final MessageLoaderBloc _messageLoaderBloc;

  BehaviorSubject<MessageListState> _listStateSubject;

  Stream<MessageListState> get listStateStream => _listStateSubject.stream;

  MessageListState get listState => _listStateSubject.value;

  BehaviorSubject<MessageListJumpDestination> _listJumpDestinationSubject =
      BehaviorSubject();

  Stream<MessageListJumpDestination> get listJumpDestinationStream =>
      _listJumpDestinationSubject.stream;

  MessageListJumpDestination get listJumpDestination =>
      _listJumpDestinationSubject.value;

  MessageListBloc(this.channelBloc, this._channelMessagesListBloc,
      this._messageLoaderBloc, this._messageCondensedBloc) {
    init();

    addDisposable(subject: _listJumpDestinationSubject);

    addDisposable(streamSubscription:
        _messageLoaderBloc.messagesListStream.listen((messageList) {
      _onMessagesChanged(messageList.allMessages, messageList.lastAddedMessages,
          messageList.messageListUpdateType);
    }));

    addDisposable(streamSubscription: _channelMessagesListBloc
        .visibleMessagesBoundsStream
        .listen((visibleMessageBounds) {
      if (visibleMessageBounds?.updateType ==
          MessageListVisibleBoundsUpdateType.push) {
        _listJumpDestinationSubject.add(MessageListJumpDestination(
            items: listState.items,
            selectedFoundItem: listState.items.firstWhere(
                (item) => item.isContainsMessageWithRemoteId(
                    visibleMessageBounds.minRegularMessageRemoteId),
                orElse: () => null),
            alignment: 0.5));
      }
    }));

    addDisposable(subject: _listStateSubject);
  }

  void init() {
    var messagesList = _messageLoaderBloc.messagesList;
    var messages = messagesList.allMessages;
    var messageListItems = _convertMessagesToMessageListItems(messages);

    MessageListState initListState = MessageListState.name(
        items: messageListItems,
        newItems: messages,
        updateType: MessageListUpdateType.loadedFromLocalDatabase);
    _logger.d(() => "init messages $initListState");

    _listStateSubject = BehaviorSubject(seedValue: initListState);
  }

  void _onMessagesChanged(
      List<ChatMessage> newMessages,
      List<ChatMessage> lastAddedMessages,
      MessageListUpdateType updateType) {
    _logger.d(() => "newMessages = ${newMessages.length} ");

    var messageListItems = _convertMessagesToMessageListItems(newMessages);

    _updateMessageListItems(messageListItems, lastAddedMessages, updateType);
  }

  void _updateMessageListItems(
      List<MessageListItem> messageListItems,
      List<ChatMessage> newMessages,
      MessageListUpdateType updateType) {
    var visibleMessagesBounds = channelMessagesListBloc.visibleMessagesBounds;

    MessageListItem initScrollPositionItem = calculateInitScrollPositionMessage(
        visibleMessagesBounds, listState.items);

    if (updateType == MessageListUpdateType.historyFromBackend) {
      _listJumpDestinationSubject.add(MessageListJumpDestination(
          items: listState.items,
          selectedFoundItem: initScrollPositionItem,
          alignment: 0.0));
    }

    if (updateType == MessageListUpdateType.loadedFromLocalDatabase) {
      _listJumpDestinationSubject.add(MessageListJumpDestination(
          items: listState.items,
          selectedFoundItem: initScrollPositionItem,
          alignment: 0));
    }

    var messageListState = MessageListState.name(
        items: messageListItems,
        newItems: newMessages,
        updateType: updateType);
    _logger.d(() => "_updateMessageListItems $messageListState");
    _listStateSubject.add(messageListState);
  }

  void _addCondensedItem(
      List<MessageListItem> items, List<ChatMessage> readyToCondenseMessages) {
    if (readyToCondenseMessages.length > 1) {
      var condensedMessageListItem =
          CondensedMessageListItem(readyToCondenseMessages);

      _messageCondensedBloc.restoreCondensedState(
          channelMessagesListBloc.channel, condensedMessageListItem);

      items.add(condensedMessageListItem);
    } else {
      items.add(SimpleMessageListItem(readyToCondenseMessages.first));
    }
  }

  List<MessageListItem> _convertMessagesToMessageListItems(
      List<ChatMessage> messages) {
    var items = <MessageListItem>[];

    DateTime lastMessageDate;
    List<ChatMessage> readyToCondenseMessages = [];
    messages.forEach((message) {
      var currentMessageDate = message.date;

      if (lastMessageDate?.day != currentMessageDate.day) {
        if (readyToCondenseMessages.isNotEmpty) {
          _addCondensedItem(items, readyToCondenseMessages);
          readyToCondenseMessages = [];
        }
        items
            .add(DaysDateSeparatorMessageListItem(message, currentMessageDate));
      }
      lastMessageDate = currentMessageDate;
      if (message is RegularMessage) {
        var isPossibleToCondense = isPossibleToCondenseMessage(message);

        if (isPossibleToCondense) {
          readyToCondenseMessages.add(message);
        } else {
          if (readyToCondenseMessages.isNotEmpty) {
            _addCondensedItem(items, readyToCondenseMessages);
            readyToCondenseMessages = [];
          }
          items.add(SimpleMessageListItem(message));
        }
      } else if (message is SpecialMessage) {
        items.add(SimpleMessageListItem(message));
      } else {
        throw "Invalid message type";
      }
    });

    if (readyToCondenseMessages.isNotEmpty) {
      _addCondensedItem(items, readyToCondenseMessages);
    }

    return items;
  }

  MessageListItem calculateInitScrollPositionMessage(
      MessageListVisibleBounds visibleMessagesBounds,
      List<MessageListItem> items) {
    MessageListItem initScrollPositionItem;

    if (visibleMessagesBounds != null) {
      var remoteId = visibleMessagesBounds.minRegularMessageRemoteId;
      initScrollPositionItem = items.firstWhere((item) {
        return item.isContainsMessageWithRemoteId(remoteId);
      }, orElse: () => null);
//      initScrollPositionItem = visibleMessagesBounds.min;
    } else {
      var firstUnreadRemoteMessageId =
          channelBloc.channelState.firstUnreadRemoteMessageId;
      if (firstUnreadRemoteMessageId != null) {
        initScrollPositionItem = items.firstWhere((item) {
          return item.isContainsMessageWithRemoteId(firstUnreadRemoteMessageId);
        }, orElse: () => null);
      }
      if (initScrollPositionItem == null) {
        _logger.w(() => "use latest message for init scroll");
        if (items?.isNotEmpty == true) {
          initScrollPositionItem = items.last;
        }
      }
      _logger.d(() => "_buildMessagesList "
          "visibleMessagesBounds $visibleMessagesBounds "
          "initScrollPositionItem $initScrollPositionItem ");
    }
    return initScrollPositionItem;
  }

  jumpToLatestMessage() {
    if (listState.items?.isNotEmpty == true) {
      _listJumpDestinationSubject.add(MessageListJumpDestination(
          items: listState.items,
          selectedFoundItem: listState.items.last,
          alignment: 0.9));
    }
  }
}
