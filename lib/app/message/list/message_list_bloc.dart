import 'dart:async';

import 'package:flutter_appirc/app/channel/messages/channel_message_list_bloc.dart';
import 'package:flutter_appirc/app/message/list/message_list_model.dart';
import 'package:flutter_appirc/app/message/list/search/message_list_search_model.dart';
import 'package:flutter_appirc/app/message/message_loader_bloc.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
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
      _onMessagesChanged(newMessages,
          _moreHistoryOwner.moreHistoryAvailable ?? false);
    }));

    addDisposable(streamSubscription: _moreHistoryOwner
        .moreHistoryAvailableStream
        .listen((moreHistoryAvailable) {
      _onMessagesChanged(_messageLoaderBloc.messages,
          _moreHistoryOwner.moreHistoryAvailable ?? false);
    }));

    addDisposable(streamSubscription:
        channelMessagesListBloc.isNeedSearchStream.listen((isNeedSearch) {
      if (isNeedSearch) {
        _search(_messageLoaderBloc.messages,
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

    _logger.d(() => "init messages ${messages.length}");
    MessageListState initListState = MessageListState.name(
        messages: messages,
        moreHistoryAvailable:
            _moreHistoryOwner.moreHistoryAvailable);
    MessageListSearchState initSearchState;

    if (channelMessagesListBloc.isNeedSearch) {
      var searchTerm = channelMessagesListBloc.searchFieldBloc.value;
      var filteredMessages = filterMessages(messages, searchTerm);

      initSearchState = MessageListSearchState.name(
          foundMessages: filteredMessages,
          searchTerm: searchTerm,
          selectedFoundMessage:
              filteredMessages.isNotEmpty ? filteredMessages[0] : null);
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
    _listStateSubject.add(MessageListState.name(
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

    var searchState = MessageListSearchState.name(
        foundMessages: filteredMessages,
        searchTerm: searchTerm,
        selectedFoundMessage:
            filteredMessages.isNotEmpty ? filteredMessages.first : null);
    _searchStateSubject.add(searchState);

    if (isSearchTermChanged) {
      // redraw search highlighted words
      updateMessagesList();
    }
  }

  void updateMessagesList() {
    _onMessagesChanged(listState.messages, listState.moreHistoryAvailable);
  }


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
        "index $newSelectedFoundMessageIndex "
        "foundMessage $foundMessage");
    var listSearchState = MessageListSearchState.name(
        foundMessages: state.foundMessages,
        searchTerm: state.searchTerm,
        selectedFoundMessage: foundMessage);
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
