import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc_provider.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/channels/chat_network_channels_blocs_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/user/users_list_bloc.dart';
import 'package:flutter_appirc/app/user/users_list_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class NetworkChannelUsersPage extends StatefulWidget {
  final Network _network;
  final NetworkChannel _channel;

  NetworkChannelUsersPage(this._network, this._channel);

  @override
  State<StatefulWidget> createState() {
    return NetworkChannelUsersPageState(_network, _channel);
  }
}

class NetworkChannelUsersPageState extends State<NetworkChannelUsersPage> {
  final Network _network;
  final NetworkChannel _channel;

  NetworkChannelUsersPageState(this._network, this._channel);

  @override
  Widget build(BuildContext context) {
    var channelBloc = ChatNetworkChannelsBlocsBloc.of(context)
        .getNetworkChannelBloc(_channel);

    var channelUsersListBloc = ChannelUsersListBloc(channelBloc);

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(AppLocalizations.of(context).tr('chat.users_list.title')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Provider(
            providable: NetworkChannelBlocProvider(channelBloc),
            child: Provider(
                providable: channelUsersListBloc,
                child: ChannelUsersListWidget()),
          ),
        ),
      ),
    );
  }
}
