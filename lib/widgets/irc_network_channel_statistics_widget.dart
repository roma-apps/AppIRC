import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_chat_channel_statistic_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_messages_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_message_model.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/skin/ui_skin.dart';

Widget _buildChannelUnreadBadgeCount(
    BuildContext context, IRCNetworkChannelStatistics channelStatistics) {
  var unreadCount = channelStatistics.unreadCount;
  if (unreadCount > 0) {
    return Container(
        decoration: BoxDecoration(color: Colors.grey),
        child: Text(unreadCount.toString()));
  } else {
    return Container();
  }
}


StreamBuilder<IRCNetworkChannelStatistics> buildChannelUnreadCountBadge(
    LoungeService lounge, IRCNetworkChannel channel) {
  var channelStatisticBloc = IRCChatChannelStatisticBloc(lounge, channel: channel);

  return StreamBuilder<IRCNetworkChannelStatistics>(
    stream: channelStatisticBloc.channelStatistricStream,
    builder: (BuildContext context,
        AsyncSnapshot<IRCNetworkChannelStatistics> snapshot) {
      var channelStatistics = snapshot.data;
      if (channelStatistics != null) {
        return _buildChannelUnreadBadgeCount(context, channelStatistics);
      } else {
        return Container();
      }
    },
  );
}
