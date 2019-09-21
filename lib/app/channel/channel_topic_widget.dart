import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_connection_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_connection_model.dart';
import 'package:flutter_appirc/app/chat/chat_model.dart';
import 'package:flutter_appirc/app/chat/chat_networks_list_bloc.dart';
import 'package:flutter_appirc/app/skin/ui_skin.dart';
import 'package:flutter_appirc/provider/provider.dart';

import 'channel_model.dart';

class IRCNetworkChannelTopicTitleWidget extends StatelessWidget {
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
            builder: (BuildContext context, AsyncSnapshot<NetworkChannelState> snapshot) {
              NetworkChannelState state = snapshot.data;
              var channelName = channelBloc.channel.name;

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

              if (subTitleText != null && subTitleText.isNotEmpty) {
                var topicStyle = UISkin.of(context).topicTextStyle;
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(channelName),
                    Text(subTitleText, style: topicStyle)
                  ],
                );
              } else {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[Text(channelName)],
                );
              }
            },
          );
        });
  }
}

class IRCNetworkChannelTopicEditWidget extends StatefulWidget {
  final NetworkChannel channel;

  IRCNetworkChannelTopicEditWidget(this.channel);

  @override
  State<StatefulWidget> createState() =>
      IRCNetworkChannelTopicEditWidgetState(channel);
}

class IRCNetworkChannelTopicEditWidgetState
    extends State<IRCNetworkChannelTopicEditWidget> {
  final NetworkChannel channel;

  IRCNetworkChannelTopicEditWidgetState(this.channel);

  @override
  Widget build(BuildContext context) {
    return Container();
//    var channelBloc = Provider.of<IRCNetworkChannelBloc>(context);
//    var lounge = Provider.of<LoungeService>(context);
//    var topicBloc = IRCNetworkChannelTopicBloc(lounge, channelBloc.channel);
//
//    return StreamBuilder<String>(
//      stream: topicBloc.outTopic,
//      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
//        var topic = snapshot.data;
//        var channelName = topicBloc.channel.name;
//        if (topic == null || topic.isEmpty) {
//          return Text(channelName);
//        } else {
//          var topicStyle = UISkin.of(context).topicTextStyle;
//
//          return Column(
//            crossAxisAlignment: CrossAxisAlignment.start,
//            mainAxisAlignment: MainAxisAlignment.center,
//            children: <Widget>[
//              Text(channelName),
//              Text(topic, style: topicStyle)
//            ],
//          );
//        }
//      },
//    );
  }
}
