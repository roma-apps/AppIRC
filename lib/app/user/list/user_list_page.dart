import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc_provider.dart';
import 'package:flutter_appirc/app/channel/channel_blocs_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/user/list/user_list_bloc.dart';
import 'package:flutter_appirc/app/user/list/user_list_widget.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_scaffold.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ChannelUsersPage extends StatefulWidget {
  final Network _network;
  final Channel _channel;

  ChannelUsersPage(this._network, this._channel);

  @override
  State<StatefulWidget> createState() {
    return ChannelUsersPageState(_network, _channel);
  }
}

class ChannelUsersPageState extends State<ChannelUsersPage> {
  final Network _network;
  final Channel _channel;

  ChannelUsersPageState(this._network, this._channel);

  @override
  Widget build(BuildContext context) {
    var channelBloc = ChannelBlocsBloc.of(context)
        .getChannelBloc(_channel);

    var channelUsersListBloc = ChannelUsersListBloc(channelBloc);

    var platformScaffold = buildPlatformScaffold(
      context,
      appBar: PlatformAppBar(
        title: Text(tr('chat.users_list.title')),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Provider(
            providable: ChannelBlocProvider(channelBloc),
            child: Provider(
                providable: channelUsersListBloc,
                child: ChannelUsersListWidget()),
          ),
        ),
      ),
    );
    return platformScaffold;
  }
}
