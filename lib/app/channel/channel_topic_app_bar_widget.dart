import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/channel_topic_form_widget.dart';
import 'package:flutter_appirc/app/chat/chat_app_bar_widget.dart';
import 'package:flutter_appirc/app/chat/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_connection_model.dart';
import 'package:flutter_appirc/platform_widgets/platform_alert_dialog.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'channel_model.dart';

class NetworkChannelTopicTitleAppBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var channelBloc = Provider.of<NetworkChannelBloc>(context);
    var chatBloc = Provider.of<ChatConnectionBloc>(context);

    return StreamBuilder<ChatConnectionState>(
        stream: chatBloc.connectionStateStream,
        initialData: chatBloc.connectionState,
        builder: (BuildContext context,
            AsyncSnapshot<ChatConnectionState> snapshot) {
          ChatConnectionState connectionState = snapshot.data;

          return StreamBuilder<NetworkChannelState>(
            stream: channelBloc.networkChannelStateStream,
            initialData: channelBloc.networkChannelState,
            builder: (BuildContext context,
                AsyncSnapshot<NetworkChannelState> snapshot) {
              NetworkChannelState state = snapshot.data;
              var channel = channelBloc.channel;
              var channelName = channel.name;

              String topic = state.topic;

              String subTitleText;

              switch (connectionState) {
                case ChatConnectionState.CONNECTED:
                  subTitleText = topic;
                  break;
                case ChatConnectionState.CONNECTING:
                  subTitleText = AppLocalizations.of(context)
                      .tr("chat.connection.connecting");
                  break;
                case ChatConnectionState.DISCONNECTED:
                  subTitleText = AppLocalizations.of(context)
                      .tr("chat.connection.disconnected");
                  break;
              }

              if (connectionState == ChatConnectionState.CONNECTED &&
                  channel.isCanHaveTopic) {
                return GestureDetector(
                    onTap: () {
                      showTopicDialog(context, channelBloc);
                    },
                    child: ChatAppBarWidget(channelName, subTitleText));
              } else {
                return ChatAppBarWidget(channelName, subTitleText);
              }
            },
          );
        });
  }
}
