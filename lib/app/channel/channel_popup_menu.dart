import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_blocs_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/channel/topic/channel_topic_dialog.dart';
import 'package:flutter_appirc/app/network/network_bloc.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_popup_menu.dart';
import 'package:flutter_appirc/app/user/list/user_list_page.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_appirc/platform_aware/platform_aware_popup_menu_widget.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class ChannelPopupMenuButtonWidget extends StatelessWidget {
  final Color iconColor;

  const ChannelPopupMenuButtonWidget({
    @required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    var networkBloc = NetworkBloc.of(context);
    var channelBloc = ChannelBloc.of(context);

    var channel = channelBloc.channel;
    var network = networkBloc.network;

    if (channel.type == ChannelType.lobby) {
      return buildNetworkPopupMenuButton(
        context: context,
        networkBloc: networkBloc,
        iconColor: iconColor,
      );
    }

    return createPlatformPopupMenuButton(
      context,
      child: Icon(Icons.more_vert, color: iconColor),
      actions: _buildMenuItems(
        context: context,
        network: network,
        channel: channel,
      ),
    );
  }
}

List<PlatformAwarePopupMenuAction> _buildMenuItems({
  @required BuildContext context,
  @required Network network,
  @required Channel channel,
}) {
  List<PlatformAwarePopupMenuAction> menuItems;

  ChannelBloc channelBloc =
      Provider.of<ChannelBlocsBloc>(context).getChannelBloc(channel);

  switch (channel.type) {
    case ChannelType.lobby:
      menuItems = [];
      break;
    case ChannelType.special:
      menuItems = [_buildCloseMenuItem(context, channelBloc)];
      break;
    case ChannelType.query:
      menuItems = _buildUserChannelMenuItems(context, channelBloc);
      break;
    case ChannelType.channel:
      menuItems = _buildChannelMenuItems(context, channelBloc);
      break;
    case ChannelType.unknown:
      menuItems = [];
      break;
  }

  return menuItems;
}

List<PlatformAwarePopupMenuAction> _buildChannelMenuItems(
  BuildContext context,
  ChannelBloc channelBloc,
) {
  var items = <PlatformAwarePopupMenuAction>[
    _buildMembersMenuItem(context, channelBloc),
    _buildBannedUsersMenuItem(context, channelBloc),
    _buildCloseMenuItem(context, channelBloc),
  ];

  // TODO: report bug to lounge. Lounge have field "editTopic" in channel state
  //  but it is  false even if user can access to change topic for current channel
  //  if (channelBloc.channelState.editTopicPossible == true) {
  //    items.insert(0, _buildEditTopicMenuItem(context, channelBloc));
  //  }
  items.insert(
    0,
    _buildEditTopicMenuItem(
      context,
      channelBloc,
    ),
  );

  return items;
}

List<PlatformAwarePopupMenuAction> _buildUserChannelMenuItems(
  BuildContext context,
  ChannelBloc channelBloc,
) {
  return <PlatformAwarePopupMenuAction>[
    _buildUserInformationMenuItem(context, channelBloc),
    _buildCloseMenuItem(context, channelBloc)
  ];
}

PlatformAwarePopupMenuAction _buildCloseMenuItem(
  BuildContext context,
  ChannelBloc channelBloc,
) {
  return PlatformAwarePopupMenuAction(
    text: S.of(context).chat_channel_action_leave,
    iconData: Icons.clear,
    actionCallback: (action) {
      channelBloc.leaveChannel();
    },
  );
}

PlatformAwarePopupMenuAction _buildMembersMenuItem(
  BuildContext context,
  ChannelBloc channelBloc,
) =>
    PlatformAwarePopupMenuAction(
      text: S.of(context).chat_channel_action_users,
      iconData: Icons.group,
      actionCallback: (action) {
        Navigator.push(
          context,
          platformPageRoute(
            context: context,
            builder: (context) => ChannelUsersPage(
              channel: channelBloc.channel,
            ),
          ),
        );
      },
    );

PlatformAwarePopupMenuAction _buildUserInformationMenuItem(
  BuildContext context,
  ChannelBloc channelBloc,
) {
  return PlatformAwarePopupMenuAction(
    text: S.of(context).chat_channel_action_user_information,
    iconData: Icons.account_box,
    actionCallback: (action) {
      channelBloc.printUserInfo(channelBloc.channel.name);
    },
  );
}

PlatformAwarePopupMenuAction _buildBannedUsersMenuItem(
  BuildContext context,
  ChannelBloc channelBloc,
) {
  return PlatformAwarePopupMenuAction(
    text: S.of(context).chat_channel_action_list_banned,
    iconData: Icons.list,
    actionCallback: (action) {
      channelBloc.printChannelBannedUsers();
    },
  );
}

PlatformAwarePopupMenuAction _buildEditTopicMenuItem(
  BuildContext context,
  ChannelBloc channelBloc,
) {
  return PlatformAwarePopupMenuAction(
    text: S.of(context).chat_channel_action_topic,
    iconData: Icons.edit,
    actionCallback: (action) {
      showTopicDialog(
        context,
        channelBloc,
      );
    },
  );
}
