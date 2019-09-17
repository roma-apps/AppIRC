import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/networks/irc_network_channel_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

class IRCNetworkChannelBloc extends Providable {
  final ChatBackendService backendService;
  final IRCNetworkChannel channel;

  IRCNetworkChannelBloc(this.backendService, this.channel);

  @override
  void dispose() {}
}
