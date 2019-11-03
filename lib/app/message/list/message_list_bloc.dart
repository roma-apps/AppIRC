import 'dart:async';

import 'package:flutter_appirc/app/channel/messages/channel_message_list_bloc.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_condensed_model.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_regular_condensed.dart';
import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/app/message/list/search/message_list_search_model.dart';
import 'package:flutter_appirc/app/message/message_loader_bloc.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/app/message/special/message_special_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "message_list_bloc.dart", enabled: true);

class MessageListBloc extends Providable {
  final ChannelMessageListBloc _channelMessagesListBloc;
  ChannelMessageListBloc get channelMessagesListBloc =>
      _channelMessagesListBloc;
  final MessageLoaderBloc _messageLoaderBloc;
  final MoreHistoryOwner _moreHistoryOwner;

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

  BehaviorSubject<MessageListSearchState> _searchStateSubject;

  Stream<MessageListSearchState> get searchStateStream =>
      _searchStateSubject.stream;

  MessageListSearchState get searchState => _searchStateSubject.value;

  MessageListBloc(this._channelMessagesListBloc, this._messageLoaderBloc,
      this._moreHistoryOwner) {
    init();

    addDisposable(streamSubscription:
        _messageLoaderBloc.messagesStream.listen((newMessages) {
      _onMessagesChanged(
          newMessages, _moreHistoryOwner.moreHistoryAvailable ?? false);
    }));

    addDisposable(streamSubscription: _moreHistoryOwner
        .moreHistoryAvailableStream.distinct()
        .listen((moreHistoryAvailable) {
      _updateMessageListItems(listState.items,
          _moreHistoryOwner.moreHistoryAvailable ?? false);
    }));

    addDisposable(streamSubscription:
        channelMessagesListBloc.isNeedSearchStream.listen((isNeedSearch) {
      if (isNeedSearch) {
        _search(listState.items,
            channelMessagesListBloc.searchFieldBloc.value, true);
      } else {
        _searchStateSubject.add(MessageListSearchState.empty);
        updateMessagesList();
      }
    }));

    addDisposable(subject: _listStateSubject);
    addDisposable(subject: _searchStateSubject);
  }

  void init() {
    var messages = _messageLoaderBloc.messages;

    var messageListItems = _convertMessagesToMessageListItems(messages);

    _logger.d(() => "init messages ${messages.length}");
    MessageListState initListState = MessageListState.name(
        items: messageListItems,
        moreHistoryAvailable: _moreHistoryOwner.moreHistoryAvailable);
    MessageListSearchState initSearchState;

    if (channelMessagesListBloc.isNeedSearch) {
      var searchTerm = channelMessagesListBloc.searchFieldBloc.value;
      List<MessageListItem> filteredItems = _filterItems(messageListItems,
          searchTerm);

      initSearchState = MessageListSearchState.name(
          foundItems: filteredItems,
          searchTerm: searchTerm,
          selectedFoundItem:
          filteredItems.isNotEmpty ? filteredItems[0] : null);
    } else {
      initSearchState = MessageListSearchState.empty;
    }

    _listStateSubject = BehaviorSubject(seedValue: initListState);
    _searchStateSubject = BehaviorSubject(seedValue: initSearchState);
  }

  void _onMessagesChanged(
      List<ChatMessage> newMessages, bool moreHistoryAvailable) {
    _logger.d(() => "newMessages = ${newMessages.length} "
        "moreHistoryAvailable = $moreHistoryAvailable");


    var messageListItems = _convertMessagesToMessageListItems(newMessages);

    _updateMessageListItems(messageListItems, moreHistoryAvailable);
  }

  void _updateMessageListItems(List<MessageListItem> messageListItems, bool moreHistoryAvailable) {

    _listStateSubject.add(MessageListState.name(
        items: messageListItems, moreHistoryAvailable: moreHistoryAvailable));
    if (channelMessagesListBloc.isNeedSearch) {
      _search(
          messageListItems, channelMessagesListBloc.searchFieldBloc.value, false);
    }
  }

  void _search(
      List<MessageListItem> messageListItems, String searchTerm, bool isSearchTermChanged) {
    List<MessageListItem> filteredItems = _filterItems(messageListItems, searchTerm);

    _logger.d(() => "_search $searchTerm "
        "isNeedChangeSelectedFoundMessage $isSearchTermChanged"
        "filteredItems ${filteredItems.length}"
    );

    var searchState = MessageListSearchState.name(
        foundItems: filteredItems,
        searchTerm: searchTerm,
        selectedFoundItem:
        filteredItems.isNotEmpty ? filteredItems.first : null);
    _searchStateSubject.add(searchState);

    if (isSearchTermChanged) {
      // redraw search highlighted words
      updateMessagesList();
    }
  }

  void updateMessagesList() {
    _updateMessageListItems(listState.items, listState.moreHistoryAvailable);
  }

  List<MessageListItem> _filterItems(
      List<MessageListItem> messageListItems, String searchTerm) {
    return messageListItems
        .where(
            (item) => item.isContainsText(searchTerm, ignoreCase: true))
        .toList();
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
        selectedFoundItem: foundMessage);
    _searchStateSubject.add(listSearchState);
    _logger.d(() => "changeSelectedMessage after");
  }

  void goToNextFoundMessage() {
    changeSelectedMessage(searchState.selectedFoundMessageIndex + 1);
  }

  void goToPreviousFoundMessage() {
    changeSelectedMessage(searchState.selectedFoundMessageIndex - 1);
  }
}

List<MessageListItem> _convertMessagesToMessageListItems(
    List<ChatMessage> messages) {
  var items = <MessageListItem>[];

  List<ChatMessage> readyToCondenseMessages = [];
  messages.forEach((message) {
    if (message is RegularMessage) {
      var isPossibleToCondense = isPossibleToCondenseMessage(message);

      if (isPossibleToCondense) {
        readyToCondenseMessages.add(message);
      } else {
        if (readyToCondenseMessages.isNotEmpty) {
          items.add(CondensedMessageListItem(readyToCondenseMessages));
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
    items.add(CondensedMessageListItem(readyToCondenseMessages));
  }

  return items;
}
