import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_blocs_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/list/channel_list_item_widget.dart';
import 'package:flutter_appirc/app/chat/active_channel/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_blocs_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/ui/theme/appirc_ui_theme_model.dart';
import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

var _logger = Logger("channel_list_widget.dart");

class ChannelListWidget extends StatelessWidget {
  final VoidCallback onActionCallback;

  final bool isChildInListView;

  ChannelListWidget({
    @required this.onActionCallback,
    @required this.isChildInListView,
  });

  @override
  Widget build(BuildContext context) {
    var networksListBloc = Provider.of<NetworkListBloc>(context);

    var network = Provider.of<Network>(context);
    var channelsListBloc = networksListBloc.getChannelListBloc(network);

    if (channelsListBloc == null) {
      return const SizedBox.shrink();
    }

    return StreamBuilder<List<Channel>>(
      stream: channelsListBloc.channelsStream,
      initialData: channelsListBloc.channels,
      builder: (context, snapshot) {
        var channels = snapshot.data;

        _logger.fine(() => "channels $channels");
        var filteredChannels = channels
            .where(
              (channel) => !channel.isLobby,
            )
            .toList();
        _logger.fine(() => "filteredChannels $filteredChannels");

        return Provider<List<Channel>>.value(
          value: filteredChannels,
          child: _ChannelListBodyWidget(
            isChildInListView: isChildInListView,
            onActionCallback: onActionCallback,
          ),
        );
      },
    );
  }
}

class _ChannelListBodyWidget extends StatelessWidget {
  final VoidCallback onActionCallback;
  final bool isChildInListView;

  _ChannelListBodyWidget({
    @required this.isChildInListView,
    @required this.onActionCallback,
  });

  @override
  Widget build(BuildContext context) {
    var filteredChannels = Provider.of<List<Channel>>(context);

    bool shrinkWrap;
    ClampingScrollPhysics scrollPhysics;
    if (isChildInListView) {
      shrinkWrap = true;
      scrollPhysics = ClampingScrollPhysics();
    } else {
      shrinkWrap = false;
    }
    return ListView.builder(
      shrinkWrap: shrinkWrap,
      physics: scrollPhysics,
      itemCount: filteredChannels.length,
      itemBuilder: (BuildContext context, int index) => Provider.value(
        value: filteredChannels[index],
        child: _ChannelListBodyWidgetItem(
          onActionCallback: onActionCallback,
        ),
      ),
    );
  }
}

class _ChannelListBodyWidgetItem extends StatelessWidget {
  final VoidCallback onActionCallback;

  _ChannelListBodyWidgetItem({
    @required this.onActionCallback,
  });

  @override
  Widget build(BuildContext context) {
    var activeChannelBloc = Provider.of<ChatActiveChannelBloc>(context);

    var channelBlocsBloc = ChannelBlocsBloc.of(context);
    var networkBlocsBloc = NetworkBlocsBloc.of(context);

    var channel = Provider.of<Channel>(context);

    return ProxyProvider<Channel, ChannelBloc>(
      update: (context, channel, _) => channelBlocsBloc.getChannelBloc(channel),
      child: ProxyProvider<ChannelBloc, Network>(
        update: (context, channelBloc, _) => channelBloc.network,
        child: ProxyProvider<Network, NetworkBloc>(
          update: (context, network, _) =>
              networkBlocsBloc.getNetworkBloc(network),
          child: StreamBuilder<bool>(
            stream: activeChannelBloc.isChannelActiveStream(channel),
            initialData: activeChannelBloc.isChannelActive(channel),
            builder: (context, snapshot) {
              var isChannelActive = snapshot.data;
              return Container(
                decoration: BoxDecoration(
                  color: isChannelActive
                      ? IAppIrcUiColorTheme.of(context).transparent
                      : IAppIrcUiColorTheme.of(context).lightGrey,
                ),
                child: ChannelListItemWidget(
                  onActionCallback: onActionCallback,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
