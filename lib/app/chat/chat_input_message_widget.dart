import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Colors, Icons;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/chat/chat_input_message_skin_bloc.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class IRCNetworkChannelNewMessageWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => IRCNetworkChannelNewMessageState();
}

class IRCNetworkChannelNewMessageState
    extends State<IRCNetworkChannelNewMessageWidget> {
  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    var channelBloc = Provider.of<NetworkChannelBloc>(context);

    var hintStr = AppLocalizations.of(context).tr("chat.enter_message.hint");
    var inputMessageSkinBloc = Provider.of<ChatInputMessageSkinBloc>(context);
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: inputMessageSkinBloc.dividerColor,
            width: 1.0,
            style: BorderStyle.solid,
          ),
        ),
      ),
      child: Row(
        children: <Widget>[
          Flexible(
              child: PlatformTextField(
            android: (_) {
              return MaterialTextFieldData(
                  decoration: InputDecoration(
                      hintText: hintStr,
                      hintStyle:
                          inputMessageSkinBloc.inputMessageHintTextStyle));
            },
            ios: (_) => CupertinoTextFieldData(placeholder: hintStr),
            cursorColor: inputMessageSkinBloc.cursorColor,
            style: inputMessageSkinBloc.inputMessageTextStyle,
            controller: _messageController,
            onSubmitted: (term) {
              sendMessage(channelBloc);
            },
          )),
          PlatformIconButton(
              color: inputMessageSkinBloc.iconSendMessageColor,
              icon: new Icon(Icons.message),
              onPressed: () {
                sendMessage(channelBloc);
              }),
        ],
      ),
    );
  }

  void sendMessage(NetworkChannelBloc channelBloc) {
    channelBloc.sendNetworkChannelRawMessage(_messageController.text);
  }
}
