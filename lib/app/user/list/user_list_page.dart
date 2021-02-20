import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc_provider.dart';
import 'package:flutter_appirc/app/channel/channel_blocs_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/user/list/user_list_bloc.dart';
import 'package:flutter_appirc/app/user/list/user_list_widget.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_scaffold.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class ChannelUsersPage extends StatefulWidget {
  final Channel channel;

  ChannelUsersPage({@required this.channel});

  @override
  State<StatefulWidget> createState() {
    return ChannelUsersPageState(channel);
  }
}

class ChannelUsersPageState extends State<ChannelUsersPage> {
  final Channel channel;

  ChannelUsersPageState(this.channel);

  @override
  Widget build(BuildContext context) {
    var channelBloc = ChannelBlocsBloc.of(context).getChannelBloc(channel);

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
