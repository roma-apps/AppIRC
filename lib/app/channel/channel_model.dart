import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';

class Channel {
  int get localId => channelPreferences?.localId;

  set localId(int newId) => channelPreferences.localId = newId;

  ChannelPreferences channelPreferences;

  String get name => channelPreferences.name;
  final ChannelType type;

  final int remoteId;

  bool get isLobby => type == ChannelType.lobby;

  bool get isCanHaveSeveralUsers => type == ChannelType.channel;

  bool get isCanHaveTopic => type == ChannelType.channel;

  Channel(this.channelPreferences, this.type, this.remoteId);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Channel &&
          runtimeType == other.runtimeType &&
          remoteId == other.remoteId;

  @override
  int get hashCode => remoteId.hashCode;

  @override
  String toString() {
    return 'Channel{channelPreferences: $channelPreferences,'
        ' type: $type, remoteId: $remoteId}';
  }
}

enum ChannelType { lobby, special, query, channel, unknown }
