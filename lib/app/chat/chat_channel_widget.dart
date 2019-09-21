import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_model.dart';
import 'package:flutter_appirc/app/message/messages_list_widget.dart';
import 'package:flutter_appirc/app/chat/chat_input_message_widget.dart';

class IRCNetworkChannelWidget extends StatelessWidget {


  @override
  Widget build(BuildContext context) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(child: IRCNetworkChannelMessagesListWidget()),
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
            child: IRCNetworkChannelNewMessageWidget(),
          ),
        )
      ],
    );
}