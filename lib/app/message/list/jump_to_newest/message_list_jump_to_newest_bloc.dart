import 'package:flutter_appirc/app/message/list/jump_to_newest/message_list_jump_to_newest_model.dart';
import 'package:flutter_appirc/app/message/list/message_list_bloc.dart';
import 'package:flutter_appirc/app/message/message_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/subjects.dart';

MyLogger _logger =
    MyLogger(logTag: "message_list_jump_to_newest_bloc.dart", enabled: true);

class MessagesListJumpToNewestBloc extends Providable {
  final MessageListBloc _messageListBloc;

  // ignore: close_sinks
  final BehaviorSubject<MessagesListJumpToNewestState> _stateSubject =
      BehaviorSubject.seeded(
    MessagesListJumpToNewestState.name(
      isLastMessageShown: true,
      newMessagesCount: 0,
    ),
  );

  Stream<MessagesListJumpToNewestState> get stateStream => _stateSubject.stream;

  MessagesListJumpToNewestState get state => _stateSubject.value;

  MessagesListJumpToNewestBloc(this._messageListBloc) {
    addDisposable(subject: _stateSubject);

    addDisposable(streamSubscription:
        _messageListBloc.listStateStream.listen((newListState) {
      switch (newListState.updateType) {
        case MessageListUpdateType.newMessagesFromBackend:
          onNewMessagesAdded(newListState.newItems.length);
          break;
        case MessageListUpdateType.loadedFromLocalDatabase:
        case MessageListUpdateType.historyFromBackend:
        case MessageListUpdateType.notUpdated:
          break;
      }
    }));
  }

  void onVisibleAreaChanged(bool isLastMessageShown) {
    _logger
        .d(() => "onVisibleAreaChanged isLastMessageShown $isLastMessageShown");
    if (isLastMessageShown) {
      state.newMessagesCount = 0;
    }
    state.isLastMessageShown = isLastMessageShown;

    _stateSubject.add(state);
  }

  void onNewMessagesAdded(int newMessagesCount) {
    _logger.d(() => "onNewMessagesAdded newMessagesCount $newMessagesCount");
    if (newMessagesCount == 0) {
      return;
    }

    state.newMessagesCount += newMessagesCount;
    state.isLastMessageShown = false;

    _stateSubject.add(state);
  }

  void jumpToLatestMessage() {
    _messageListBloc.jumpToLatestMessage();
  }
}
