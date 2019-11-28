import 'dart:async';

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
  final ChannelMessageListBloc _channelMessagesListBloc;
  final MessageCondensedBloc _messageCondensedBloc;

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

  String get searchTerm => searchState.searchTerm;

  MessageListBloc(this._channelMessagesListBloc, this._messageLoaderBloc,
      this._moreHistoryOwner, this._messageCondensedBloc) {
    init();

    addDisposable(streamSubscription:
        _messageLoaderBloc.messagesListStream.listen((messageList) {
      _onMessagesChanged(
          messageList.allMessages,
          _moreHistoryOwner.moreHistoryAvailable ?? false,
          messageList.messageListUpdateType);
    }));

    addDisposable(streamSubscription: _moreHistoryOwner
        .moreHistoryAvailableStream
        .listen((moreHistoryAvailable) {
      _updateMessageListItems(
          listState.items,
          _moreHistoryOwner.moreHistoryAvailable ?? false,
          MessageListUpdateType.notUpdated);
    }));

    addDisposable(streamSubscription:
        channelMessagesListBloc.isNeedSearchStream.listen((isNeedSearch) {
      if (isNeedSearch) {
        _search(listState.items, channelMessagesListBloc.searchFieldBloc.value,
            true);
      } else {
        _searchStateSubject.add(MessageListSearchState.empty);
        updateMessagesList();
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
        items: messageListItems,
        moreHistoryAvailable: _moreHistoryOwner.moreHistoryAvailable,
        updateType: MessageListUpdateType.loadedFromLocalDatabase);
    _logger.d(() => "init messages $initListState");
    MessageListSearchState initSearchState;

    if (channelMessagesListBloc.isNeedSearch) {
      var searchTerm = channelMessagesListBloc.searchFieldBloc.value;
      List<MessageListItem> filteredItems =
          _filterItems(messageListItems, searchTerm);

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

  void _onMessagesChanged(List<ChatMessage> newMessages,
      bool moreHistoryAvailable, MessageListUpdateType lastAddedPosition) {
    _logger.d(() => "newMessages = ${newMessages.length} "
        "moreHistoryAvailable = $moreHistoryAvailable");

    var messageListItems = _convertMessagesToMessageListItems(newMessages);

    _updateMessageListItems(
        messageListItems, moreHistoryAvailable, lastAddedPosition);
  }

  void _updateMessageListItems(List<MessageListItem> messageListItems,
      bool moreHistoryAvailable, MessageListUpdateType lastAddedPosition) {
    var messageListState = MessageListState.name(
        items: messageListItems,
        moreHistoryAvailable: moreHistoryAvailable,
        updateType: lastAddedPosition);
    _logger.d(() => "_updateMessageListItems $messageListState");
    _listStateSubject.add(messageListState);
    if (channelMessagesListBloc.isNeedSearch) {
      _search(messageListItems, channelMessagesListBloc.searchFieldBloc.value,
          false);
    }
  }

  void _search(List<MessageListItem> messageListItems, String searchTerm,
      bool isSearchTermChanged) {
    List<MessageListItem> filteredItems =
        _filterItems(messageListItems, searchTerm);

    _logger.d(() => "_search $searchTerm "
        "isNeedChangeSelectedFoundMessage $isSearchTermChanged"
        "filteredItems ${filteredItems.length}");

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
    _updateMessageListItems(listState.items, listState.moreHistoryAvailable,
        MessageListUpdateType.notUpdated);
  }

  List<MessageListItem> _filterItems(
      List<MessageListItem> messageListItems, String searchTerm) {
    return messageListItems
        .where((item) => item.isContainsText(searchTerm, ignoreCase: true))
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
        items.add(DaysDateSeparatorMessageListItem(currentMessageDate));
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
    bool inSearchResults;
    var term = this.searchTerm;
    if (term != null) {
      inSearchResults = message.isContainsText(searchTerm, ignoreCase: true);
    } else {
      inSearchResults = false;
    }

    return inSearchResults;
  }
}
