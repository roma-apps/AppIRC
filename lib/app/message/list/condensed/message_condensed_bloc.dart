import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/message/list/condensed/message_condensed_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';

class MessageCondensedBloc extends DisposableOwner {
  final Map<Channel, Map<int, bool>> _states = {};

  void onCondensedStateChanged(
      Channel channel, CondensedMessageListItem item) {
    if (!_states.containsKey(channel)) {
      _states[channel] = {};
    }

    var remoteId = item.oldestRegularMessage.messageRemoteId;
    _states[channel][remoteId] = item.isCondensed;

  }

  void restoreCondensedState(Channel channel, CondensedMessageListItem item) {
    if (_states.containsKey(channel)) {
    var remoteId = item.oldestRegularMessage.messageRemoteId;
      if (_states[channel].containsKey(remoteId)) {
        item.isCondensed = _states[channel][remoteId];
      }
    }
  }
}
