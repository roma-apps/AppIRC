import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/input_message/chat_input_message_widget.dart';
import 'package:flutter_appirc/app/message/list/jump_to_newest/message_list_jump_to_newest_bloc.dart';
import 'package:flutter_appirc/app/message/list/load_more/message_list_load_more_bloc.dart';
import 'package:flutter_appirc/app/message/list/message_list_bloc.dart';
import 'package:flutter_appirc/app/message/list/message_list_widget.dart';
import 'package:flutter_appirc/disposable/disposable_provider.dart';

import 'package:logging/logging.dart';
import 'package:provider/provider.dart';

var _logger = Logger("chat_channel_widget.dart");

class ChannelWidget extends StatefulWidget {
  ChannelWidget();

  @override
  _ChannelWidgetState createState() => _ChannelWidgetState();
}

class _ChannelWidgetState extends State<ChannelWidget> {
  @override
  Widget build(BuildContext context) {
    _logger.fine(() => "build");

    var channelBloc = ChannelBloc.of(context);
    // whe listen false here?
    var messageListBloc = Provider.of<MessageListBloc>(context, listen: false);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: DisposableProvider<MessageListLoadMoreBloc>(
            create: (context) =>
                MessageListLoadMoreBloc(channelBloc, messageListBloc),
            child: DisposableProvider<MessagesListJumpToNewestBloc>(
              create: (context) =>
                  MessagesListJumpToNewestBloc(messageListBloc),
              child: MessageListWidget(),
            ),
          ),
        ),
        ChannelNewMessageWidget()
      ],
    );
  }
}
