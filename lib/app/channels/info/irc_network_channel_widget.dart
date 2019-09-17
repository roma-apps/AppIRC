import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channels/irc_network_channel_messages_list_widget.dart';
import 'package:flutter_appirc/app/channels/irc_network_channel_new_message_widget.dart';
import 'package:flutter_appirc/app/networks/irc_network_channel_model.dart';

class IRCNetworkChannelWidget extends StatelessWidget {

  final IRCNetworkChannel channel;


  IRCNetworkChannelWidget(this.channel);

  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(child: IRCNetworkChannelMessagesListWidget(channel)),
        Container(
          decoration: BoxDecoration(
            color: Colors.red,
            border: Border(
            top: BorderSide(
              color: Colors.redAccent,
              width: 1.0,
              style: BorderStyle.solid,
            ),
          ),),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: IRCNetworkChannelNewMessageWidget(channel),
          ),
        )
      ],
    );
}
