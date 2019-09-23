import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart'
    show Colors, Icons, PopupMenuButton, PopupMenuEntry, PopupMenuItem;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/channel_topic_widget.dart';
import 'package:flutter_appirc/app/channel/channel_unread_count_widget.dart';
import 'package:flutter_appirc/app/channel/channels_list_skin_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_active_channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_network_channels_states_bloc.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/widgets/menu_widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class IRCNetworkChannelsListWidget extends StatelessWidget {
  final Network network;

  IRCNetworkChannelsListWidget(this.network);

  @override
  Widget build(BuildContext context) {
    var channels = network.channelsWithoutLobby;
    return ListView.builder(
        shrinkWrap: true,
        itemCount: channels.length,
        itemBuilder: (BuildContext context, int index) {
          return _channelItem(context, network, channels[index]);
        });
  }

  Widget _channelItem(
      BuildContext context, Network network, NetworkChannel channel) {
    var ircChatActiveChannelBloc =
        Provider.of<IRCChatActiveChannelBloc>(context);

    return StreamBuilder<NetworkChannel>(
        stream: ircChatActiveChannelBloc.activeChannelStream,
        builder:
            (BuildContext context, AsyncSnapshot<NetworkChannel> snapshot) {
          var activeChannel = snapshot.data;
          var isChannelActive = activeChannel?.remoteId == channel.remoteId;
          if (isChannelActive) {
            return Container(
                decoration: BoxDecoration(
                    color: Provider.of<ChannelsListSkinBloc>(context)
                        .getChannelItemBackgroundColor(isChannelActive)),
                child: _buildChannelRow(context, ircChatActiveChannelBloc,
                    network, channel, isChannelActive));
          } else {
            return Container(
                child: _buildChannelRow(context, ircChatActiveChannelBloc,
                    network, channel, isChannelActive));
          }
        });
  }

  Widget _buildChannelRow(
      BuildContext context,
      IRCChatActiveChannelBloc ircChatActiveChannelBloc,
      Network network,
      NetworkChannel channel,
      bool isChannelActive) {
    var networkBloc = Provider.of<NetworkBloc>(context);

    var iconData = Icons.message;

    switch (channel.type) {
      case NetworkChannelType.LOBBY:
        iconData = Icons.message;
        break;
      case NetworkChannelType.SPECIAL:
        iconData = Icons.list;
        break;
      case NetworkChannelType.QUERY:
        iconData = Icons.account_circle;
        break;
      case NetworkChannelType.CHANNEL:
        iconData = Icons.group;
        break;
      case NetworkChannelType.UNKNOWN:
        iconData = Icons.message;
        break;
    }

    var channelBloc = NetworkChannelBloc(
        Provider.of<ChatInputOutputBackendService>(context),
        network,
        channel,
        Provider.of<ChatNetworkChannelsStateBloc>(context));
    return Provider(
      providable: channelBloc,
      child: StreamBuilder(
          stream: channelBloc.networkChannelStateStream,
          builder: (context, snapshot) {
            NetworkChannelState channelState = snapshot.data;
            if (channelState == null) {
              channelState = NetworkChannelState.empty;
            }

            var channelsListSkinBloc =
                Provider.of<ChannelsListSkinBloc>(context);
            return Row(children: <Widget>[
              Padding(
                padding: const EdgeInsets.fromLTRB(12.0, 0.0, 0.0, 0.0),
                child: Icon(iconData,
                    color: channelsListSkinBloc
                        .getChannelItemIconColor(isChannelActive)),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: GestureDetector(
                    onTap: () =>
                        ircChatActiveChannelBloc.changeActiveChanel(channel),
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Container(
                              margin: EdgeInsets.all(8.0),
                              child: Text(channel.name,
                                  style: channelsListSkinBloc
                                      .getChannelItemTextStyle(
                                          isChannelActive)))
                        ]),
                  ),
                ),
              ),
              StreamBuilder<NetworkState>(
                  stream: networkBloc.networkStateStream,
                  initialData: NetworkState.empty,
                  builder: (BuildContext context,
                      AsyncSnapshot<NetworkState> snapshot) {
                    var networkState = snapshot.data;

                    return buildConnectionIcon(
                        context,
                        channelsListSkinBloc
                            .getChannelItemIconColor(isChannelActive),
                        networkState.connected && channelState.connected);
                  }),
              buildChannelUnreadCountBadge(context, isChannelActive),
              _buildPopupMenuButton(context, channel, channelState,
                  channelsListSkinBloc.getChannelItemIconColor(isChannelActive))
            ]);
          }),
    );
  }

  PopupMenuButton<ChannelDropDownAction> _buildPopupMenuButton(
      BuildContext context,
      NetworkChannel channel,
      NetworkChannelState state,
      Color foregroundColor) {
    var channelBloc = Provider.of<NetworkChannelBloc>(context);

    return PopupMenuButton<ChannelDropDownAction>(
      icon: Icon(Icons.more_vert, color: foregroundColor),
      onSelected: (value) async {
        switch (value) {
          case ChannelDropDownAction.LEAVE:
            channelBloc.leaveNetworkChannel();
            break;
          case ChannelDropDownAction.TOPIC:
            showPlatformDialog(
                context: context,
                builder: (_) => IRCNetworkChannelTopicEditWidget(channel),
                androidBarrierDismissible: true);
            break;
          case ChannelDropDownAction.LIST_BANNED:
            channelBloc.printNetworkChannelBannedUsers();
            break;
          case ChannelDropDownAction.USER_INFORMATION:
            channelBloc.printUserInfo(network.name);
            break;
        }
      },
      itemBuilder: (context) {
        return _buildMenuItems(context, channel, state);
      },
    );
  }

  List<PopupMenuEntry<ChannelDropDownAction>> _buildMenuItems(
      BuildContext context, NetworkChannel channel, NetworkChannelState state) {
    List<PopupMenuEntry<ChannelDropDownAction>> menuItems;

    var appLocalizations = AppLocalizations.of(context);

    switch (channel.type) {
      case NetworkChannelType.LOBBY:
        menuItems = [];
        break;
      case NetworkChannelType.SPECIAL:
        menuItems = [_buildCloseMenuItem(context)];
        break;
      case NetworkChannelType.QUERY:
        _buildUserChannelMenuItems(context);
        break;
      case NetworkChannelType.CHANNEL:
        menuItems = _buildChannelMenuItems(context, channel);
        break;
      case NetworkChannelType.UNKNOWN:
        menuItems = [];
        break;
    }

    if (state.editTopicPossible == true) {
      menuItems.insert(
          0,
          buildDropdownMenuItemRow(
              value: ChannelDropDownAction.TOPIC,
              text: appLocalizations.tr("settings.channel_dropdown_menu.topic"),
              iconData: Icons.edit));
    }

    return menuItems;
  }

  List<PopupMenuEntry<ChannelDropDownAction>> _buildChannelMenuItems(
      BuildContext context, NetworkChannel channel) {
    var appLocalizations = AppLocalizations.of(context);

    var items = <PopupMenuEntry<ChannelDropDownAction>>[
      buildDropdownMenuItemRow(
          value: ChannelDropDownAction.LIST_BANNED,
          text:
              appLocalizations.tr("settings.channel_dropdown_menu.list_banned"),
          iconData: Icons.list),
      buildDropdownMenuItemRow(
          value: ChannelDropDownAction.LEAVE,
          text: appLocalizations.tr("settings.channel_dropdown_menu.leave"),
          iconData: Icons.clear)
    ];

    return items;
  }

  List<PopupMenuEntry<ChannelDropDownAction>> _buildUserChannelMenuItems(
      BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);

    return <PopupMenuEntry<ChannelDropDownAction>>[
      buildDropdownMenuItemRow(
          value: ChannelDropDownAction.USER_INFORMATION,
          text: appLocalizations
              .tr("settings.channel_dropdown_menu.user_infromation"),
          iconData: Icons.edit),
      _buildCloseMenuItem(context)
    ];
  }

  PopupMenuItem<ChannelDropDownAction> _buildCloseMenuItem(
      BuildContext context) {
    var appLocalizations = AppLocalizations.of(context);
    return buildDropdownMenuItemRow(
        value: ChannelDropDownAction.LEAVE,
        text: appLocalizations.tr("settings.channel_dropdown_menu.close"),
        iconData: Icons.clear);
  }
}

enum ChannelDropDownAction { LEAVE, TOPIC, LIST_BANNED, USER_INFORMATION }

buildConnectionIcon(
    BuildContext context, Color foregroundColor, bool connected) {
  if (!connected) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Icon(Icons.cloud_off, color: foregroundColor),
    );
  } else {
    return Container();
  }
}
