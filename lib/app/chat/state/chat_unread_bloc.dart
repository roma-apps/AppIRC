import 'package:flutter_appirc/app/chat/channels/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

MyLogger _logger = MyLogger(logTag: "chat_unread_bloc.dart", enabled: true);

class ChatUnreadBloc extends Providable {
  // ignore: close_sinks
  final BehaviorSubject<int> _channelsWithUnreadMessagesCountController =
      BehaviorSubject(seedValue: 0);
  Stream<int> get channelsWithUnreadMessagesCountStream =>
      _channelsWithUnreadMessagesCountController.stream.distinct();
  int get channelsWithUnreadMessagesCount =>
      _channelsWithUnreadMessagesCountController.value;

  final ChatNetworkChannelsStateBloc channelsStateBloc;
  ChatUnreadBloc(this.channelsStateBloc) : super() {
    addDisposable(subject: _channelsWithUnreadMessagesCountController);

    addDisposable(
        streamSubscription: channelsStateBloc.anyStateChangedStream.listen((_) {
      _update();
    }));
    _update();
  }

  void _update() {
    var unreadCount = 0;
    for (var state in channelsStateBloc.states) {
      var haveUnread = state.unreadCount > 0;
      if (haveUnread) {
        unreadCount++;
      }
    }
    _logger.d(() => "_update $unreadCount");
    _channelsWithUnreadMessagesCountController.add(unreadCount);
  }
}
