import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';

enum ChatInitState { notStarted, inProgress, finished }

class ChatInitInformation {
  int activeChannelRemoteId;
  String authToken;
  List<NetworkWithState> networksWithState;
  List<ChannelWithState> channelsWithState;

  ChatInitInformation({
    @required this.activeChannelRemoteId,
    @required this.networksWithState,
    @required this.channelsWithState,
    @required this.authToken,
  });

  @override
  String toString() {
    return 'ChatInitInformation{'
        'activeChannelRemoteId: $activeChannelRemoteId, '
        'authToken: $authToken, '
        'networksWithState: $networksWithState, '
        'channelsWithState: $channelsWithState'
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatInitInformation &&
          runtimeType == other.runtimeType &&
          activeChannelRemoteId == other.activeChannelRemoteId &&
          authToken == other.authToken &&
          networksWithState == other.networksWithState &&
          channelsWithState == other.channelsWithState;

  @override
  int get hashCode =>
      activeChannelRemoteId.hashCode ^
      authToken.hashCode ^
      networksWithState.hashCode ^
      channelsWithState.hashCode;
}
