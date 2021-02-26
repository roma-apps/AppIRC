import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/channel/topic/channel_topic_dialog.dart';
import 'package:flutter_appirc/app/chat/app_bar/chat_app_bar_widget.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/connection/chat_connection_model.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:provider/provider.dart';

class ChannelTopicTitleAppBarWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var channelBloc = ChannelBloc.of(context);
    var chatBloc = Provider.of<ChatConnectionBloc>(context);

    return StreamBuilder<ChatConnectionState>(
      stream: chatBloc.connectionStateStream,
      initialData: chatBloc.connectionState,
      builder:
          (BuildContext context, AsyncSnapshot<ChatConnectionState> snapshot) {
        ChatConnectionState connectionState = snapshot.data;

        return StreamBuilder<String>(
          stream: channelBloc.channelTopicStream,
          initialData: channelBloc.channelTopic,
          builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
            String topic = snapshot.data;

            var channel = channelBloc.channel;
            var channelName = channel.name;

            String subTitleText;

            switch (connectionState) {
              case ChatConnectionState.connected:
                subTitleText = topic;
                break;
              case ChatConnectionState.connecting:
                subTitleText =
                    S.of(context).chat_state_connection_status_connecting;
                break;
              case ChatConnectionState.disconnected:
                subTitleText =
                    S.of(context).chat_state_connection_status_disconnected;
                break;
            }

            if (connectionState == ChatConnectionState.connected &&
                channel.isCanHaveTopic) {
              return GestureDetector(
                onTap: () {
                  showTopicDialog(context, channelBloc);
                },
                child: ChatAppBarWidget(
                  channelName,
                  subTitleText,
                ),
              );
            } else {
              return ChatAppBarWidget(
                channelName,
                subTitleText,
              );
            }
          },
        );
      },
    );
  }
}
