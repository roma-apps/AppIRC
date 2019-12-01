import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/state/channel_state_model.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';

enum ChatInitState { notStarted, inProgress, finished }

class ChatInitInformation {
  int activeChannelRemoteId;
  String authToken;
  List<NetworkWithState> networksWithState;
  List<ChannelWithState> channelsWithState;

  ChatInitInformation(this.activeChannelRemoteId, this.authToken,
      this.networksWithState, this.channelsWithState);

  ChatInitInformation.name({
    @required this.activeChannelRemoteId,
    @required this.networksWithState,
    @required this.channelsWithState,
    @required this.authToken,
  });

  @override
  String toString() {
    return 'ChatInitInformation{activeChannelRemoteId: $activeChannelRemoteId,'
        ' authToken: $authToken,'
        ' networksWithState: $networksWithState,'
        ' channelsWithState: $channelsWithState}';
  }


}
