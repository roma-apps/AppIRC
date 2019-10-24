import 'dart:async';

import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_messages_list_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_messages_loader_bloc.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/app/message/messages_regular_model.dart';
import 'package:flutter_appirc/app/message/messages_special_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ChatMessageWrapper {
  bool includedInSearchResult;
  ChatMessage message;

  ChatMessageWrapper(this.includedInSearchResult, this.message);
}

class ChatMessagesWrapperState {
  List<ChatMessageWrapper> messages;
  int newScrollIndex;

  ChatMessagesWrapperState(this.messages, this.newScrollIndex);
}

class MessagesSearchState {
  List<ChatMessage> messages;
  int currentIndex;

  MessagesSearchState(this.messages, this.currentIndex);
}

class ChatMessageListVisibleArea {
  ChatMessage minVisibleMessage;
  ChatMessage maxVisibleMessage;

  ChatMessageListVisibleArea(this.minVisibleMessage, this.maxVisibleMessage);
}

class ChatMessagesListBloc extends Providable {
  ChatInputOutputBackendService backendService;
  ChannelMessagesListBloc _channelMessagesListBloc;
  NetworkChannelMessagesLoaderBloc _messagesLoaderBloc;

  bool mapSearchNextEnabled(MessagesSearchState foundState) {
    if (foundState != null) {
      return foundState.currentIndex < foundState.messages.length - 1;
    } else {
      return false;
    }
  }

  bool mapSearchPreviousEnabled(MessagesSearchState foundState) {
    if (foundState != null) {
      return foundState.currentIndex > 0;
    } else {
      return false;
    }
  }

  Stream<bool> get searchNextEnabledStream =>
      foundMessagesStream.map(mapSearchNextEnabled);

  bool get searchNextEnabled =>
      mapSearchNextEnabled(_foundMessagesController.value);

  Stream<bool> get searchPreviousEnabledStream =>
      foundMessagesStream.map(mapSearchPreviousEnabled);

  bool get searchPreviousEnabled =>
      mapSearchPreviousEnabled(_foundMessagesController.value);

  String get _currentSearchTerm =>
      _channelMessagesListBloc.searchFieldBloc.value;

  List<ChatMessage> get _currentLoadedMessages =>
      _messagesLoaderBloc.currentMessages;

  ChatMessagesListBloc(
      this._channelMessagesListBloc, this._messagesLoaderBloc) {
    addDisposable(streamSubscription:
        _messagesLoaderBloc.messagesStream.listen((newMessages) {
      _research(false);
    }));

    addDisposable(streamSubscription: _channelMessagesListBloc
        .searchFieldBloc.valueStream
        .listen((newSearchTerm) {
      _research(true);
    }));

    addDisposable(subject: _allMessagesStateController);
    addDisposable(subject: _foundMessagesController);
//    addDisposable(subject: _forcedMessagesListIndexController);
//    addDisposable(subject: _selectedFoundMessageIndexController);
  }

  void _research(bool isSearchTermChanged) {
    List<ChatMessage> filteredMessages;
    bool Function(ChatMessage chatMessage) isFoundFunction;
    var searchTermIsNotEmpty =
        _currentSearchTerm != null && _currentSearchTerm.isNotEmpty;
    if (searchTermIsNotEmpty) {
      filteredMessages =
          filterMessages(_currentLoadedMessages, _currentSearchTerm);

      isFoundFunction =
          (ChatMessage chatMessage) => filteredMessages.contains(chatMessage);
    } else {
      filteredMessages = [];

      isFoundFunction = (_) => false;
    }

    var messageWrappersList = _currentLoadedMessages.map((chatMessage) {
      return ChatMessageWrapper(isFoundFunction(chatMessage), chatMessage);
    }).toList();

    int newIndex;
    if (allMessagesState?.newScrollIndex == null) {
      var visibleArea = _channelMessagesListBloc.visibleArea;
      if (visibleArea != null) {
        var indexOf = _currentLoadedMessages.indexWhere((message) {
          return visibleArea.maxVisibleMessage == message;
        });
        if (indexOf > 0) {
          newIndex = indexOf;
        }
      }
    }

    _allMessagesStateController
        .add(ChatMessagesWrapperState(messageWrappersList, newIndex));

    if (searchTermIsNotEmpty) {
      _foundMessagesController.add(MessagesSearchState(filteredMessages, 0));
    } else {
      _foundMessagesController.add(null);
    }

    if (searchTermIsNotEmpty) {
      if (isSearchTermChanged && filteredMessages.isNotEmpty) {
        goToFirstFoundMessage();
      }
    } else {}
  }

  List<ChatMessage> filterMessages(
      List<ChatMessage> messages, String searchTerm) {
    return messages.where((message) {
      if (message is RegularMessage) {
        return message.text.contains(searchTerm);
      } else if (message is SpecialMessage) {
        return message.data.isContainsText(searchTerm);
      } else {
        throw "Not supported $message";
      }
    }).toList();
  }

  BehaviorSubject<ChatMessagesWrapperState> _allMessagesStateController =
      BehaviorSubject(seedValue: ChatMessagesWrapperState([], null));

  Stream<ChatMessagesWrapperState> get allMessagesStateStream =>
      _allMessagesStateController.stream;

  ChatMessagesWrapperState get allMessagesState =>
      _allMessagesStateController.value;

  BehaviorSubject<MessagesSearchState> _foundMessagesController =
      BehaviorSubject();

  Stream<MessagesSearchState> get foundMessagesStream =>
      _foundMessagesController.stream;

  MessagesSearchState get foundMessages => _foundMessagesController.value;

//  BehaviorSubject<int> _selectedFoundMessageIndexController = BehaviorSubject();
//  Stream<int> get selectedFoundMessageIndexStream =>
//      _selectedFoundMessageIndexController.stream;
//  int get selectedFoundMessageIndex =>
//      _selectedFoundMessageIndexController.value;

//  Stream<int> get selectedFoundMessagePositionStream =>
//      selectedFoundMessageIndexStream
//          .map((index) => index != null ? index + 1 : null);
//
//  int get selectedFoundMessagePosition =>
//      selectedFoundMessageIndex != null ? selectedFoundMessageIndex + 1 : null;
//
//  BehaviorSubject<int> _forcedMessagesListIndexController = BehaviorSubject();
//  Stream<int> get forcedMessagesListIndexStream =>
//      _forcedMessagesListIndexController.stream;
//  int get forcedMessagesListIndex => _forcedMessagesListIndexController.value;

  void onMessagesScrolled(int minVisibleIndex, int maxVisibleIndex) {
    var isNotEmpty = _currentLoadedMessages.isNotEmpty;
    var isInit = (minVisibleIndex == 0 && maxVisibleIndex == 0);
//    _logger.d(() =>
//        "onMessagesScrolled [$minVisibleIndex, $maxVisibleIndex] "
//            "isNotEmpty = $isNotEmpty" +
//        "isInit = $isInit");
    if (isNotEmpty && !isInit) {
      _channelMessagesListBloc.visibleArea = ChatMessageListVisibleArea(
          _currentLoadedMessages[minVisibleIndex],
          _currentLoadedMessages[maxVisibleIndex]);
    }
  }

  void goToNextFoundMessage() {
    changeSelectedMessage(foundMessages.currentIndex + 1);
  }

  void goToPreviousFoundMessage() {
    changeSelectedMessage(foundMessages.currentIndex - 1);
  }

  void goToFirstFoundMessage() {
    changeSelectedMessage(0);
  }

  void onNeedChangeScrollIndex() {
    var selectedMessage = foundMessages.messages[foundMessages.currentIndex];

    var index = _currentLoadedMessages.indexOf(selectedMessage);

    allMessagesState.newScrollIndex = index;

    _allMessagesStateController.add(allMessagesState);
  }

  void changeSelectedMessage(int newSelectedFoundMessageIndex) {
    foundMessages.currentIndex = (newSelectedFoundMessageIndex);
    _foundMessagesController.add(foundMessages);
    onNeedChangeScrollIndex();
  }
}
