import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

const String _logTag = "IRCNetworkChannelMessagesBloc";

class IRCNetworkChannelNewMessageBloc extends Providable {
  final LoungeService _lounge;
  final IRCNetworkChannel channel;

  IRCNetworkChannelNewMessageBloc(this._lounge, this.channel);

  sendMessage(String text) async =>
      await _lounge.sendChatMessageRequest(channel.remoteId, text);

  @override
  void dispose() {}
}
