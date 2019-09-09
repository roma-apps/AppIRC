import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

class IRCNetworkChannelBloc extends Providable {
  final LoungeService _lounge;
  final IRCNetworkChannel channel;

  IRCNetworkChannelBloc(this._lounge, this.channel);

  @override
  void dispose() {}
}
