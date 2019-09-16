import 'package:flutter_appirc/app/networks/irc_network_channel_model.dart';

import 'package:flutter_appirc/lounge/lounge_service.dart';
import 'package:flutter_appirc/provider/provider.dart';

class IRCNetworkChannelBloc extends Providable {
  final LoungeService _lounge;
  final IRCNetworkChannel channel;

  IRCNetworkChannelBloc(this._lounge, this.channel);

  @override
  void dispose() {}
}
