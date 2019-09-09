import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_topic_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/skin/ui_skin.dart';

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
