import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_messages_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_message_model.dart';
import 'package:flutter_appirc/models/irc_network_channel_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/widgets/irc_network_channel_message_widget.dart';

class IRCNetworkChannelMessagesListWidget extends StatelessWidget {
  final IRCNetworkChannel channel;

  IRCNetworkChannelMessagesListWidget(this.channel);

  @override
  Widget build(BuildContext context) {
    var loungeService = Provider.of<LoungeService>(context);

    var messagesBloc = IRCNetworkChannelMessagesBloc(loungeService, channel);

    return StreamBuilder<List<IRCNetworkChannelMessage>>(
        stream: messagesBloc.messagesStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<IRCNetworkChannelMessage>> snapshot) {
          var messages = snapshot.data;
          if (messages != null) {
            messages =
                messages.where((message) => _isNeedPrint(message)).toList();
          }

          if (messages == null || messages.length == 0) {
            return Center(
                child: Text(
                    AppLocalizations.of(context).tr("chat.empty_channel")));
          } else {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) =>
                      IRCNetworkChannelMessageWidget(messages[index])),
            );
          }
        });
  }
}

_isNeedPrint(IRCNetworkChannelMessage message) =>
    message.type != IRCNetworkChannelMessageType.UNHANDLED &&
    message.type != IRCNetworkChannelMessageType.RAW;
