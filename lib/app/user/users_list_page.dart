import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/user/users_list_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class NetworkChannelUsersPage extends StatefulWidget {
  final Network network;
  final NetworkChannel channel;

  NetworkChannelUsersPage(this.network, this.channel);

  @override
  State<StatefulWidget> createState() {
    return NetworkChannelUsersPageState(network, channel);
  }
}

class NetworkChannelUsersPageState
    extends State<NetworkChannelUsersPage> {
  final Network network;
  final NetworkChannel channel;

  NetworkChannelUsersPageState(this.network, this.channel);

  @override
  Widget build(BuildContext context) {
    var backendService = Provider.of<ChatInputOutputBackendService>(context);
    var channelsStateBloc = Provider.of<ChatNetworkChannelsStateBloc>(context);

    var channelBloc =
        NetworkChannelBloc(backendService, network, channel, channelsStateBloc);

    channelBloc.getNetworkChannelUsers();

    return PlatformScaffold(
      appBar: PlatformAppBar(
        title: Text(AppLocalizations.of(context).tr('chat.users.title')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Provider(
              providable: channelBloc,
              child: ChannelUserInfosWidget(
                  channelBloc.usersStream, channelBloc.users)),
        ),
      ),
    );
  }
}
