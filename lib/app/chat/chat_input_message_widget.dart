import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Colors, Icons;
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/skin/ui_skin.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

class IRCNetworkChannelNewMessageWidget extends StatefulWidget {


  @override
  State<StatefulWidget> createState() =>
      IRCNetworkChannelNewMessageState();
}

class IRCNetworkChannelNewMessageState
    extends State<IRCNetworkChannelNewMessageWidget> {


  final _messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {

    var channelBloc = Provider.of<NetworkChannelBloc>(context);

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
              sendMessage(channelBloc);
            },
          ),
        ),
        PlatformIconButton(
            color: Colors.white,
            androidIcon: new Icon(Icons.message),
            iosIcon: new Icon(Icons.message),
            onPressed: () {
              sendMessage(channelBloc);
            }),
      ],
    );
  }

  void sendMessage(NetworkChannelBloc channelBloc) {
    channelBloc.sendNetworkChannelRawMessage(_messageController.text);
  }

}
