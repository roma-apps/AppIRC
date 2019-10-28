import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/state/network_state_model.dart';

enum ChatInitState { notStarted, inProgress, finished }

class ChatInitInformation {
  int activeChannelRemoteId;
  List<NetworkWithState> networksWithState;

  ChatInitInformation(this.activeChannelRemoteId, this.networksWithState);

  ChatInitInformation.name(
      {@required this.activeChannelRemoteId, @required this.networksWithState});
}
