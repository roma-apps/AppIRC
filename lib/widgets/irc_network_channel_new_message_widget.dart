import 'package:flutter/material.dart' show Icons;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_new_message_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class IRCNetworkChannelNewMessageWidget extends StatefulWidget {
  final IRCNetworkChannel channel;


  IRCNetworkChannelNewMessageWidget(this.channel);

  @override
  State<StatefulWidget> createState() => IRCNetworkChannelNewMessageState(channel);
}

class IRCNetworkChannelNewMessageState
    extends State<IRCNetworkChannelNewMessageWidget> {

  final IRCNetworkChannel channel;


  IRCNetworkChannelNewMessageState(this.channel);

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
          child: PlatformTextField(
            controller: _messageController,
            onSubmitted: (term) {
              _sendMessage(newMessageBloc);
            },
          ),
        ),
        PlatformIconButton(
            androidIcon: new Icon(Icons.message),
            iosIcon: new Icon(Icons.message),
            onPressed: () {
              _sendMessage(newMessageBloc);
            }),
      ],
    );
  }

  _sendMessage(IRCNetworkChannelNewMessageBloc channelBloc) =>
      channelBloc.sendMessage(_messageController.text);
}
