import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/network_model.dart';

enum ChatInitState { NOT_STARTED, IN_PROGRESS, FINISHED }

class ChatInitInformation {
  int activeChannelRemoteId;
  List<NetworkWithState> networksWithState;

  ChatInitInformation(this.activeChannelRemoteId, this.networksWithState);

  ChatInitInformation.name(
      {@required this.activeChannelRemoteId, @required this.networksWithState});
}
