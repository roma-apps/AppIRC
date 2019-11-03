import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/list/load_more/message_list_load_more_model.dart';
import 'package:flutter_appirc/app/message/regular/message_regular_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

MyLogger _logger =
    MyLogger(logTag: "message_list_load_more_bloc.dart", enabled: true);

class MessageListLoadMoreBloc extends Providable {
  // ignore: close_sinks
  final BehaviorSubject<MessageListLoadMoreState> _stateSubject =
      BehaviorSubject(seedValue: MessageListLoadMoreState.notAvailable);
  final ChannelBloc _channelBloc;

  Stream<MessageListLoadMoreState> get stateStream =>
      _stateSubject.stream.distinct();

  MessageListLoadMoreState get state => _stateSubject.value;

  MessageListLoadMoreBloc(this._channelBloc) {
    addDisposable(subject: _stateSubject);
    addDisposable(streamSubscription:
        _channelBloc.moreHistoryAvailableStream.listen((moreHistoryAvailable) {
      if (moreHistoryAvailable == true) {
        _stateSubject.add(MessageListLoadMoreState.available);
      } else {
        _stateSubject.add(MessageListLoadMoreState.notAvailable);
      }
    }));
  }

  Future sendLoadMoreRequest(RegularMessage oldestMessage) async {
    var oldState = state;

    _logger.d(() => "sendLoadMoreRequest oldState = $oldestMessage");

    if (oldState == MessageListLoadMoreState.available) {
      _stateSubject.add(MessageListLoadMoreState.loading);
      _channelBloc.loadMoreHistory(oldestMessage);
    }
  }
}
