import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_new_message_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/service/lounge_service.dart';

class IRCNetworkChannelNewMessageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IRCNetworkChannelNewMessageState();
}

class IRCNetworkChannelNewMessageState
    extends State<IRCNetworkChannelNewMessageWidget> {
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var lounge = Provider.of<LoungeService>(context);
    var channelBloc = Provider.of<IRCNetworkChannelBloc>(context);

    var newMessageBloc =
        IRCNetworkChannelNewMessageBloc(lounge, channelBloc.channel);

    return Row(
      children: <Widget>[
        Flexible(
          child: TextFormField(
            controller: _messageController,
            textInputAction: TextInputAction.send,
            onFieldSubmitted: (term) {
              _sendMessage(newMessageBloc);
            },
          ),
        ),
        IconButton(
            icon: new Icon(Icons.message),
            onPressed: () {
              _sendMessage(newMessageBloc);
            }),
      ],
    );
  }

  _sendMessage(IRCNetworkChannelNewMessageBloc channelBloc) =>
      channelBloc.sendMessage(_messageController.text);
}
