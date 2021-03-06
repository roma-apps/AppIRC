import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/input_message/chat_input_message_widget.dart';
import 'package:flutter_appirc/app/message/list/jump_to_newest/message_list_jump_to_newest_bloc.dart';
import 'package:flutter_appirc/app/message/list/load_more/message_list_load_more_bloc.dart';
import 'package:flutter_appirc/app/message/list/message_list_bloc.dart';
import 'package:flutter_appirc/app/message/list/message_list_widget.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/provider/provider.dart';

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

    var channelBloc = ChannelBloc.of(context);
    MessageListBloc messageListBloc = Provider.of(context);
    var messageListLoadMoreBloc =
        MessageListLoadMoreBloc(channelBloc, messageListBloc);
    var messagesListJumpToNewestBloc = MessagesListJumpToNewestBloc(messageListBloc);

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.start,
        children: <Widget>[
          Expanded(
              child: Provider(
                  providable: messageListLoadMoreBloc,
                  child: Provider(
                      providable: messagesListJumpToNewestBloc,
                      child: MessageListWidget(messageListLoadMoreBloc,
                          messagesListJumpToNewestBloc)))),
          ChannelNewMessageWidget()
        ]);
  }
}
