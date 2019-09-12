import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/widgets/irc_network_channel_messages_widget.dart';
import 'package:flutter_appirc/widgets/irc_network_channel_new_message_widget.dart';

class IRCNetworkChannelWidget extends StatelessWidget {

  final IRCNetworkChannel channel;


  IRCNetworkChannelWidget(this.channel);

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(child: IRCNetworkChannelMessagesWidget(channel)),
        Container(child: IRCNetworkChannelNewMessageWidget(channel))
      ],
    );
}
