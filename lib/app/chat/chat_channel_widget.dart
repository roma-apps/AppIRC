import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_input_message_widget.dart';
import 'package:flutter_appirc/app/message/messages_list_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';

import 'chat_input_message_bloc.dart';

class NetworkChannelWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {


    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(child: NetworkChannelMessagesListWidget()),
        NetworkChannelNewMessageWidget()
      ],
    );
  }
}
