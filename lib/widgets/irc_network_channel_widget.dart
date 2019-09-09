import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_chat_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/widgets/irc_network_channel_messages_widget.dart';
import 'package:flutter_appirc/widgets/irc_network_channel_new_message_widget.dart';

class IRCNetworkChannelWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var lounge = Provider.of<LoungeService>(context);
    var chatBloc = Provider.of<IRCChatBloc>(context);

    return StreamBuilder<IRCNetworkChannel>(
        stream: chatBloc.activeChannelStream,
        builder:
            (BuildContext context, AsyncSnapshot<IRCNetworkChannel> snapshot) {
          if (snapshot.data == null) {
            return Text(AppLocalizations.of(context).tr("chat.no_active_chat"));
          } else {
            return Provider<IRCNetworkChannelBloc>(
              bloc: IRCNetworkChannelBloc(lounge, snapshot.data),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: IRCNetworkChannelMessagesWidget()),
                  Container(child: IRCNetworkChannelNewMessageWidget())
                ],
              ),
            );
          }
        });
  }
}
