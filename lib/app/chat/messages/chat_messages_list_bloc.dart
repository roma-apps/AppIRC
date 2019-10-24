import 'dart:async';

import 'package:flutter_appirc/app/channel/messages/channel_messages_list_bloc.dart';
import 'package:flutter_appirc/app/chat/messages/chat_messages_loader_bloc.dart';
import 'package:flutter_appirc/app/chat/messages/chat_messages_model.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

var _logger = MyLogger(logTag: "ChatMessagesListBloc", enabled: true);

abstract class MoreHistoryOwner {
  bool get networkChannelMoreHistoryAvailable;

  Stream<bool> get networkChannelMoreHistoryAvailableStream;
}

class ChatMessagesListBloc extends Providable {
  ChannelMessagesListBloc channelMessagesListBloc;
  NetworkChannelMessagesLoaderBloc messagesLoaderBloc;
  MoreHistoryOwner moreHistoryOwner;

  ChatMessagesListBloc(this.channelMessagesListBloc, this.messagesLoaderBloc,
      this.moreHistoryOwner) {
    init();

    addDisposable(streamSubscription:
        messagesLoaderBloc.messagesStream.listen((newMessages) {
      _onMessagesChanged(
          newMessages, moreHistoryOwner.networkChannelMoreHistoryAvailable);
    }));

    addDisposable(streamSubscription: moreHistoryOwner
        .networkChannelMoreHistoryAvailableStream
        .listen((moreHistoryAvailable) {
      _onMessagesChanged(messagesLoaderBloc.messages,
          moreHistoryOwner.networkChannelMoreHistoryAvailable);
    }));

    addDisposable(streamSubscription:
        channelMessagesListBloc.isNeedSearchStream.listen((isNeedSearch) {
      if (isNeedSearch) {
        _search(messagesLoaderBloc.messages,
            channelMessagesListBloc.searchFieldBloc.value, true);
      } else {
        _searchStateSubject.add(ChatMessagesListSearchState.empty);
        updateMessagesList();
      }
    }));

    addDisposable(subject: _listStateSubject);
    addDisposable(subject: _searchStateSubject);
  }

  void init() {
    var messages = messagesLoaderBloc.messages;

    _logger.d(() => "init messages ${messages.length}");
    ChatMessagesListState initListState = ChatMessagesListState.name(
        messages: messages,
        moreHistoryAvailable:
            moreHistoryOwner.networkChannelMoreHistoryAvailable);
    ChatMessagesListSearchState initSearchState;

    if (channelMessagesListBloc.isNeedSearch) {
      var searchTerm = channelMessagesListBloc.searchFieldBloc.value;
      var filteredMessages = filterMessages(messages, searchTerm);

      initSearchState = ChatMessagesListSearchState.name(
          foundMessages: filteredMessages,
          searchTerm: searchTerm,
          selectedFoundMessage:
              filteredMessages.isNotEmpty ? filteredMessages[0] : null);
    } else {
      initSearchState = ChatMessagesListSearchState.empty;
    }

    _listStateSubject = BehaviorSubject(seedValue: initListState);
    _searchStateSubject = BehaviorSubject(seedValue: initSearchState);
  }

  void _onMessagesChanged(
      List<ChatMessage> newMessages, bool moreHistoryAvailable) {
    _logger.d(() => "newMessages = ${newMessages.length} "
        "moreHistoryAvailable = $moreHistoryAvailable");
    _listStateSubject.add(ChatMessagesListState.name(
        messages: newMessages, moreHistoryAvailable: moreHistoryAvailable));
    if (channelMessagesListBloc.isNeedSearch) {
      _search(
          newMessages, channelMessagesListBloc.searchFieldBloc.value, false);
    }
  }

  void _search(
      List<ChatMessage> messages, String searchTerm, bool isSearchTermChanged) {
    var filteredMessages = filterMessages(messages, searchTerm);

    _logger.d(() => "_search $searchTerm "
        "isNeedChangeSelectedFoundMessage $isSearchTermChanged"
        "messages ${messages.length}"
        "filteredMessages ${filteredMessages.length}");

    _searchStateSubject.add(ChatMessagesListSearchState.name(
        foundMessages: filteredMessages,
        searchTerm: searchTerm,
        selectedFoundMessage:
            filteredMessages.isNotEmpty ? filteredMessages.first : null));

    if (isSearchTermChanged) {
      // redraw search highlighted words
      updateMessagesList();
    }
  }

  void updateMessagesList() {
    _onMessagesChanged(listState.messages, listState.moreHistoryAvailable);
  }

  Stream<bool> get searchNextEnabledStream => searchStateStream
      .map((state) => state?.isCanMoveNext ?? false)
      .distinct();

  bool get searchNextEnabled => searchState?.isCanMoveNext ?? false;

  Stream<bool> get searchPreviousEnabledStream => searchStateStream
      .map((state) => state?.isCanMovePrevious ?? false)
      .distinct();

  bool get searchPreviousEnabled => searchState?.isCanMovePrevious ?? false;

  BehaviorSubject<ChatMessagesListState> _listStateSubject;

  Stream<ChatMessagesListState> get listStateStream => _listStateSubject.stream;

  ChatMessagesListState get listState => _listStateSubject.value;

  BehaviorSubject<ChatMessagesListSearchState> _searchStateSubject;

  Stream<ChatMessagesListSearchState> get searchStateStream =>
      _searchStateSubject.stream;

  ChatMessagesListSearchState get searchState => _searchStateSubject.value;

//
//  void _research(bool isSearchTermChanged) {
//    _logger.d(() => "_research $isSearchTermChanged");
//
//    List<ChatMessage> filteredMessages;
//    var searchTermIsNotEmpty = _currentSearchTerm != null &&
//        _currentSearchTerm.isNotEmpty;
//    var filteredForPrint = _currentLoadedMessages;
//    if (searchTermIsNotEmpty) {
//      filteredMessages = filterMessages(filteredForPrint, _currentSearchTerm);
//    }
//
//    _listStateSubject.add(ChatMessagesListState.name(
//        messages: _currentLoadedMessages, moreHistoryAvailable:));
//
//    if (searchTermIsNotEmpty) {
//      _searchStateSubject.add(ChatMessagesListSearchState(filteredMessages, 0));
//    } else {
//      _searchStateSubject.add(null);
//    }
//
//    if (searchTermIsNotEmpty) {
//      if (isSearchTermChanged && filteredMessages.isNotEmpty) {
//        goToFirstFoundMessage();
//      }
//    } else {}
//  }

  List<ChatMessage> filterMessages(
      List<ChatMessage> messages, String searchTerm) {
    return messages
        .where(
            (message) => message.isContainsText(searchTerm, ignoreCase: true))
        .toList();
  }

  void changeSelectedMessage(int newSelectedFoundMessageIndex) {
    var state = searchState;
    var foundMessage = state.foundMessages[newSelectedFoundMessageIndex];

    _logger.d(() => "changeSelectedMessage "
        "index $newSelectedFoundMessageIndex"
        "foundMessage $foundMessage");
    _searchStateSubject.add(ChatMessagesListSearchState.name(
        foundMessages: state.foundMessages,
        searchTerm: state.searchTerm,
        selectedFoundMessage: foundMessage));
  }

  void goToNextFoundMessage() {
    changeSelectedMessage(searchState.selectedFoundMessageIndex + 1);
  }

  void goToPreviousFoundMessage() {
    changeSelectedMessage(searchState.selectedFoundMessageIndex - 1);
  }
}
