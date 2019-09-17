import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channels/info/irc_network_channel_topic_bloc.dart';
import 'package:flutter_appirc/app/channels/irc_network_channel_bloc.dart';
import 'package:flutter_appirc/app/networks/irc_network_channel_model.dart';
import 'package:flutter_appirc/app/skin/ui_skin.dart';
import 'package:flutter_appirc/lounge/lounge_service.dart';
import 'package:flutter_appirc/provider/provider.dart';

class IRCNetworkChannelTopicTitleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var channelBloc = Provider.of<IRCNetworkChannelBloc>(context);
    var lounge = Provider.of<LoungeService>(context);
    var topicBloc = IRCNetworkChannelTopicBloc(lounge, channelBloc.channel);

    return StreamBuilder<String>(
      stream: topicBloc.outTopic,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        var topic = snapshot.data;
        var channelName = topicBloc.channel.name;
        if (topic == null || topic.isEmpty) {
          return Text(channelName);
        } else {
          var topicStyle = UISkin.of(context).appSkin.topicTextStyle;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(channelName),
              Text(topic, style: topicStyle)
            ],
          );
        }
      },
    );
  }
}

class IRCNetworkChannelTopicEditWidget extends StatefulWidget {
  final IRCNetworkChannel channel;

  IRCNetworkChannelTopicEditWidget(this.channel);

  @override
  State<StatefulWidget> createState() =>
      IRCNetworkChannelTopicEditWidgetState(channel);
}

class IRCNetworkChannelTopicEditWidgetState
    extends State<IRCNetworkChannelTopicEditWidget> {
  final IRCNetworkChannel channel;

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
//          var topicStyle = UISkin.of(context).appSkin.topicTextStyle;
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
