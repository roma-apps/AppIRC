import 'package:flutter_appirc/app/chat/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/rxdart.dart';

class ChatUnreadBloc extends Providable {
  // ignore: close_sinks
  final BehaviorSubject<bool> _haveUnreadMessagesController =
      BehaviorSubject(seedValue: false);
  Stream<bool> get isHaveUnreadMessagesStream =>
      _haveUnreadMessagesController.stream.distinct();
  bool get isHaveUnreadMessages => _haveUnreadMessagesController.value;

  final ChatNetworkChannelsStateBloc channelsStateBloc;
  ChatUnreadBloc(this.channelsStateBloc) {
    addDisposable(subject: _haveUnreadMessagesController);

    addDisposable(
        streamSubscription: channelsStateBloc.anyStateChangedStream.listen((_) {
      _update();
    }));
    _update();
  }

  void _update() {
    var haveUnread = false;
    for(var state in channelsStateBloc.states) {
      haveUnread = state.unreadCount > 0;
      if(haveUnread) {
        break;
      }
    }
    _haveUnreadMessagesController.add(haveUnread);
  }
}
