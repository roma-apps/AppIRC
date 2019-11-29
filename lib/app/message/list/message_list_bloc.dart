import 'dart:async';

import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/messages/channel_message_list_bloc.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_condensed_model.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_regular_condensed.dart';
import 'package:flutter_appirc/app/message/list/date_separator/message_list_date_separator_model.dart';
import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/app/message/list/search/message_list_search_model.dart';
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

  ChannelMessageListBloc get channelMessagesListBloc =>
      _channelMessagesListBloc;
  final MessageLoaderBloc _messageLoaderBloc;

//  final MoreHistoryOwner _moreHistoryOwner;

  Stream<bool> get searchNextEnabledStream => searchStateStream
      .map((state) => state?.isCanMoveNext ?? false)
      .distinct();

  bool get searchNextEnabled => searchState?.isCanMoveNext ?? false;

  Stream<bool> get searchPreviousEnabledStream => searchStateStream
      .map((state) => state?.isCanMovePrevious ?? false)
      .distinct();

  bool get searchPreviousEnabled => searchState?.isCanMovePrevious ?? false;

  BehaviorSubject<MessageListState> _listStateSubject;

  Stream<MessageListState> get listStateStream => _listStateSubject.stream;

  MessageListState get listState => _listStateSubject.value;

  BehaviorSubject<MessageListJumpDestination> _listJumpDestinationSubject  =
      BehaviorSubject();

  Stream<MessageListJumpDestination> get listJumpDestinationStream =>
      _listJumpDestinationSubject.stream;

  MessageListJumpDestination get listJumpDestination =>
      _listJumpDestinationSubject.value;

  BehaviorSubject<MessageListSearchState> _searchStateSubject;

  Stream<MessageListSearchState> get searchStateStream =>
      _searchStateSubject.stream;

  MessageListSearchState get searchState => _searchStateSubject.value;

  String get searchTerm => searchState.searchTerm;

  MessageListBloc(
      this.channelBloc,
      this._channelMessagesListBloc,
      this._messageLoaderBloc,
//      this._moreHistoryOwner,
      this._messageCondensedBloc) {
    init();

    addDisposable(subject: _listJumpDestinationSubject);

    addDisposable(streamSubscription:
        _messageLoaderBloc.messagesListStream.listen((messageList) {
      _onMessagesChanged(
          messageList.allMessages,
//          _moreHistoryOwner.moreHistoryAvailable ?? false,
          messageList.messageListUpdateType);
    }));

//    addDisposable(streamSubscription: _moreHistoryOwner
//        .moreHistoryAvailableStream
//        .listen((moreHistoryAvailable) {
//      _updateMessageListItems(
//          listState.items,
//          _moreHistoryOwner.moreHistoryAvailable ?? false,
//          MessageListUpdateType.notUpdated);
//    }));

    addDisposable(streamSubscription:
        channelMessagesListBloc.isNeedSearchStream.listen((isNeedSearch) {
      if (isNeedSearch) {
        _search(listState.items, channelMessagesListBloc.searchFieldBloc.value,
            true);
      } else {
        _searchStateSubject.add(MessageListSearchState.empty);
//        updateMessagesList();
      }
    }));

    addDisposable(streamSubscription: _channelMessagesListBloc
        .visibleMessagesBoundsStream
        .listen((visibleMessageBounds) {
      if (visibleMessageBounds?.updateType ==
          MessageListVisibleBoundsUpdateType.push) {
        _listJumpDestinationSubject.add(MessageListJumpDestination(
            items: listState.items,
            selectedFoundItem: listState.items.firstWhere((item) =>
                item.isContainsMessageWithRemoteId(
                    visibleMessageBounds.minRegularMessageRemoteId), orElse:
            () => null),
            alignment: 0.5));
      }
    }));

    addDisposable(subject: _listStateSubject);
    addDisposable(subject: _searchStateSubject);
  }

  void init() {
    var messagesList = _messageLoaderBloc.messagesList;
    var messages = messagesList.allMessages;
    var messageListItems = _convertMessagesToMessageListItems(messages);

    MessageListState initListState = MessageListState.name(
        items: messageListItems);
    _logger.d(() => "init messages $initListState");
    MessageListSearchState initSearchState;

    if (channelMessagesListBloc.isNeedSearch) {
      var searchTerm = channelMessagesListBloc.searchFieldBloc.value;
      List<MessageListItem> filteredItems =
          _filterItems(messageListItems, searchTerm);

      initSearchState = MessageListSearchState.name(
          foundItems: filteredItems,
          searchTerm: searchTerm,
          selectedFoundItem: filteredItems.isNotEmpty ? filteredItems[0] : null,
          foundMessages: <ChatMessage>[]);
    } else {
      initSearchState = MessageListSearchState.empty;
    }

    _listStateSubject = BehaviorSubject(seedValue: initListState);
    _searchStateSubject = BehaviorSubject(seedValue: initSearchState);
  }

  void _onMessagesChanged(
      List<ChatMessage> newMessages,
//      bool moreHistoryAvailable,
      MessageListUpdateType lastAddedPosition) {
    _logger.d(() => "newMessages = ${newMessages.length} "
//        "moreHistoryAvailable = $moreHistoryAvailable"
        );

    var messageListItems = _convertMessagesToMessageListItems(newMessages);

    _updateMessageListItems(
        messageListItems,
//        moreHistoryAvailable,
        lastAddedPosition);
  }

  void _updateMessageListItems(List<MessageListItem> messageListItems,
//      bool moreHistoryAvailable,
      MessageListUpdateType updateType) {



    var visibleMessagesBounds =
        channelMessagesListBloc.visibleMessagesBounds;

    MessageListItem initScrollPositionItem =
    calculateInitScrollPositionMessage(visibleMessagesBounds, listState.items);

    if (updateType == MessageListUpdateType.historyFromBackend) {
      _listJumpDestinationSubject.add(MessageListJumpDestination(
          items: listState.items,
          selectedFoundItem: initScrollPositionItem,
          alignment: 0.0));
    }
    if (updateType == MessageListUpdateType.replacedByBackend) {
        _listJumpDestinationSubject.add(MessageListJumpDestination(
          items:  listState.items,
          selectedFoundItem: listState.items.last,
          alignment: 0.9));
    }

    if (updateType == MessageListUpdateType.loadedFromLocalDatabase) {
          _listJumpDestinationSubject.add(MessageListJumpDestination(
          items:  listState.items,
          selectedFoundItem: initScrollPositionItem,
          alignment: 0));
    }

    var messageListState = MessageListState.name(
        items: messageListItems);
    _logger.d(() => "_updateMessageListItems $messageListState");
    _listStateSubject.add(messageListState);
    if (channelMessagesListBloc.isNeedSearch) {
      _search(messageListItems, channelMessagesListBloc.searchFieldBloc.value,
          false);
    }
  }

  void _search(List<MessageListItem> messageListItems, String searchTerm,
      bool isSearchTermChanged) {
//    List<MessageListItem> filteredItems =
//    _filterItems(messageListItems, searchTerm);


//    var searchState = MessageListSearchState.name(
//        foundItems: filteredItems,
//        searchTerm: searchTerm,
//        selectedFoundItem:
//        filteredItems.isNotEmpty ? filteredItems.first : null);
    var searchState = _createSearchState(messageListItems, searchTerm);
    _logger.d(() => "_search $searchState ");
    _searchStateSubject.add(searchState);

    _listJumpDestinationSubject.add(MessageListJumpDestination(
        items: listState.items,
        selectedFoundItem: searchState.selectedFoundItem,
        alignment: 0));

    if (isSearchTermChanged) {
      // redraw search highlighted words
//      updateMessagesList();
    }
  }

//  void updateMessagesList() {
//    _updateMessageListItems(listState.items, listState.moreHistoryAvailable,
//        MessageListUpdateType.notUpdated);
//  }

  List<MessageListItem> _filterItems(
      List<MessageListItem> messageListItems, String searchTerm) {
    return messageListItems
        .where((item) => item.isContainsText(searchTerm, ignoreCase: true))
        .toList();
  }

  MessageListSearchState _createSearchState(
      List<MessageListItem> messageListItems, String searchTerm) {
    List<MessageListItem> foundItems = [];
    List<ChatMessage> foundMessages = [];

    messageListItems.forEach((item) {
      if (item is SimpleMessageListItem) {
        bool contains =
            item.message.isContainsText(searchTerm, ignoreCase: true);

        if (contains) {
          foundItems.add(item);
          foundMessages.add(item.message);
        }
      } else if (item is CondensedMessageListItem) {
        bool itemContains = false;

        item.messages.forEach((message) {
          bool contains = message.isContainsText(searchTerm, ignoreCase: true);

          if (contains) {
            itemContains = true;
            foundMessages.add(message);
          }
        });

        if (itemContains) {
          foundItems.add(item);
        }
      }
    });

    MessageListSearchState searchState = MessageListSearchState.name(
        foundItems: foundItems,
        foundMessages: foundMessages,
        searchTerm: searchTerm,
        selectedFoundItem: foundItems.isNotEmpty ? foundItems.first : null);

    return searchState;

//    return messageListItems
//        .where((item) => item.isContainsText(searchTerm, ignoreCase: true))
//        .toList();
  }

  void changeSelectedMessage(int newSelectedFoundMessageIndex) {
    var state = searchState;
    var foundMessage = state.foundItems[newSelectedFoundMessageIndex];

    _logger.d(() => "changeSelectedMessage "
        "index $newSelectedFoundMessageIndex "
        "foundMessage $foundMessage");
    var listSearchState = MessageListSearchState.name(
        foundItems: state.foundItems,
        searchTerm: state.searchTerm,
        selectedFoundItem: foundMessage,
        foundMessages: state.foundMessages);
    _searchStateSubject.add(listSearchState);
    _logger.d(() => "changeSelectedMessage after");
  }

  void goToNextFoundMessage() {
    changeSelectedMessage(searchState.selectedFoundMessageIndex + 1);
  }

  void goToPreviousFoundMessage() {
    changeSelectedMessage(searchState.selectedFoundMessageIndex - 1);
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

  bool isListItemInSearchResults(MessageListItem messageListItem) {
    if (searchState != null) {
      return searchState.isMessageListItemInSearchResults(messageListItem);
    } else {
      return false;
    }
  }

  bool isMessageInSearchResults(ChatMessage message) {
    return searchState.foundMessages.contains(message);

//    bool inSearchResults;
//    var term = this.searchTerm;
//    if (term != null) {
//      inSearchResults = message.isContainsText(searchTerm, ignoreCase: true);
//    } else {
//      inSearchResults = false;
//    }
//
//    return inSearchResults;
  }

  Stream<MessageInListState> getMessageInListStateStream(ChatMessage message) =>
      merge(_messageLoaderBloc.getMessageUpdateStream(message),
              _searchStateSubject)
          .distinct((oldState, newState) {


        var changed = oldState.inSearchResult == newState.inSearchResult &&
            oldState.searchTerm == newState.searchTerm &&
            oldState.message.linksInText == newState.message.linksInText &&
            _checkPreviews(oldState, newState);
            _logger.d(()=> "getMessageInListStateStream changed $changed"
            "oldState $oldState "
            "newState $newState "
            );
        return changed;
      });

  MessageInListState getMessageInListState(ChatMessage message) =>
      MessageInListState.name(
          message: message,
          inSearchResult: isMessageInSearchResults(message),
          searchTerm: searchTerm);

  Stream<MessageInListState> merge(
      Stream<ChatMessage> streamA, Stream<MessageListSearchState> streamB) {
    return Observable.combineLatest2(
        streamA, streamB, (a, b) => getMessageInListState(a));

//    return streamA
//        .transform(Observable.combineLatest(streamB, (a, b) =>
//        getMessageInListState(a)));
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
        initScrollPositionItem = items.last;
      }
      _logger.d(() => "_buildMessagesList "
          "visibleMessagesBounds $visibleMessagesBounds "
          "initScrollPositionItem $initScrollPositionItem ");
    }
    return initScrollPositionItem;
  }

}

bool _checkPreviews(MessageInListState oldState, MessageInListState newState) {
  var oldMessage = oldState.message;
  var newMessage = newState.message;
  if (oldMessage is RegularMessage && newMessage is RegularMessage) {
    return oldMessage.previews == newMessage.previews;
  } else {
    return true;
  }
}

