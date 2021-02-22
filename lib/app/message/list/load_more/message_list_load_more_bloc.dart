import 'dart:async';

import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/list/load_more/message_list_load_more_model.dart';
import 'package:flutter_appirc/app/message/list/message_list_bloc.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/subjects.dart';

var _logger = Logger("message_list_load_more_bloc.dart");

class MessageListLoadMoreBloc extends DisposableOwner {
  // ignore: close_sinks
  BehaviorSubject<LoadMoreState> _stateSubject = BehaviorSubject();

  Stream<LoadMoreState> get stateStream => _stateSubject.stream;

  LoadMoreState get state => _stateSubject.value;

  final ChannelBloc channelBloc;
  MessageListBloc messageListBloc;

  MessageListLoadMoreBloc(
    this.channelBloc,
    this.messageListBloc,
  ) {
    addDisposable(subject: _stateSubject);

    var moreHistoryAvaialble = (channelBloc?.channelState?.moreHistoryAvailable ?? false);
    _stateSubject = BehaviorSubject.seeded(
      moreHistoryAvaialble
          ? LoadMoreState.available
          : LoadMoreState.notAvailable,
    );

    addDisposable(
      streamSubscription: channelBloc.moreHistoryAvailableStream.listen(
        (moreHistoryAvailable) {
          Future.delayed(
            Duration(seconds: 1),
            () {
              _updateLoadMoreState(moreHistoryAvailable);
            },
          );
        },
      ),
    );
  }

  Future loadMore() async {
    if (state == LoadMoreState.available) {
      _stateSubject.add(LoadMoreState.loading);
      var listState = messageListBloc.listState;

      var items = listState.items;

      var oldestRegularItem = items
          ?.firstWhere((item) => item.isHaveRegularMessage, orElse: () => null);

      var oldestRegularMessage = oldestRegularItem.oldestRegularMessage;

      await channelBloc.loadMoreHistory(oldestRegularMessage);
    } else {
      _logger.warning(() => "can't loadMore() because state = $state");
    }
  }

  void _updateLoadMoreState(bool moreHistoryAvailable) {
    if (moreHistoryAvailable) {
      _stateSubject.add(LoadMoreState.available);
    } else {
      _stateSubject.add(LoadMoreState.notAvailable);
    }
  }
}
