import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Colors, Icons;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channels/irc_network_channel_bloc.dart';
import 'package:flutter_appirc/app/channels/irc_network_channel_new_message_bloc.dart';
import 'package:flutter_appirc/app/networks/irc_network_channel_model.dart';
import 'package:flutter_appirc/app/skin/ui_skin.dart';
import 'package:flutter_appirc/lounge/lounge_service.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class IRCNetworkChannelNewMessageWidget extends StatefulWidget {
  final IRCNetworkChannel channel;


  IRCNetworkChannelNewMessageWidget(this.channel);

  @override
  State<StatefulWidget> createState() =>
      IRCNetworkChannelNewMessageState(channel);
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

    var uiSkin = UISkin.of(context);

    var hintStr = AppLocalizations.of(context).tr("chat.enter_message.hint");

    return Row(
      children: <Widget>[
        Flexible(
          child: PlatformTextField(
            android: (_) => MaterialTextFieldData(decoration: InputDecoration(
                hintText: hintStr,
                hintStyle: uiSkin.appSkin.enterMessageTextStyle.copyWith(color: Colors.white60))),
            ios: (_) => CupertinoTextFieldData(placeholder: hintStr),
            cursorColor: Colors.white,
            style: uiSkin.appSkin.enterMessageTextStyle,
            controller: _messageController,
            onSubmitted: (term) {
              _sendMessage(newMessageBloc);
            },
          ),
        ),
        PlatformIconButton(
            color: Colors.white,
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
