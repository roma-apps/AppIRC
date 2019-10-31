import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/chat/input_message/chat_input_message_widget.dart';
import 'package:flutter_appirc/app/message/list/message_list_widget.dart';
import 'package:flutter_appirc/app/message/list/search/message_list_search_widget.dart';
import 'package:flutter_appirc/logger/logger.dart';

MyLogger _logger = MyLogger(logTag: "chat_channel_widget.dart", enabled: true);

class ChannelWidget extends StatefulWidget {
  ChannelWidget();

  @override
  _ChannelWidgetState createState() => _ChannelWidgetState();
}

class _ChannelWidgetState extends State<ChannelWidget> {
  @override
  Widget build(BuildContext context) {
    _logger.d(() => "build");
    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          MessageListSearchWidget(),
          Expanded(child: MessageListWidget()),
          ChannelNewMessageWidget()
        ]);
  }
}
