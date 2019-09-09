import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_bloc.dart';
import 'package:flutter_appirc/blocs/irc_network_channel_messages_bloc.dart';
import 'package:flutter_appirc/helpers/provider.dart';
import 'package:flutter_appirc/models/irc_network_channel_message_model.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/skin/ui_skin.dart';

class IRCNetworkChannelMessagesWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var channelBloc = Provider.of<IRCNetworkChannelBloc>(context);
    var loungeService = Provider.of<LoungeService>(context);

    var messagesBloc =
        IRCNetworkChannelMessagesBloc(loungeService, channelBloc.channel);

    return StreamBuilder<List<IRCNetworkChannelMessage>>(
        stream: messagesBloc.messagesStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<IRCNetworkChannelMessage>> snapshot) {
          var messages = snapshot.data;
          if (messages != null) {
            messages = messages
                .where((message) =>
                    message.text != null && message.text.isNotEmpty)
                .toList();
          }

          if (messages == null || messages.length == 0) {
            return Text(AppLocalizations.of(context).tr("chat.empty_chat"));
          } else {
            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                  itemCount: messages.length,
                  itemBuilder: (BuildContext context, int index) {
                    var message = messages[index];

                    if (message.author == null) {
                      message.author = "";
                    }

                    var uiSkin = UISkin.of(context);
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Container(
                        decoration: BoxDecoration(
                            border:
                                Border.all(color: uiSkin.appSkin.accentColor)),
                        child: Container(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: <Widget>[
                                    Text(
                                      message.author,
                                      style: uiSkin
                                          .appSkin.channelMessagesNickTextStyle,
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(4.0),
                                      child: Text(
                                        message.date.toString(),
                                        style: uiSkin.appSkin
                                            .channelMessagesDateTextStyle,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(2.0),
                                child: Text("${message.type}: ${message.text}"),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }),
            );
          }
        });
  }
}
