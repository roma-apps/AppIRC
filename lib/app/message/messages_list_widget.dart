import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/channel_bloc.dart';
import 'package:flutter_appirc/app/message/message_widgets.dart';
import 'package:flutter_appirc/app/message/messages_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

class IRCNetworkChannelMessagesListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var channelBloc = Provider.of<NetworkChannelBloc>(context);


    
    return StreamBuilder<List<IRCChatMessage>>(
        stream: channelBloc.messagesStream,
        builder: (BuildContext context,
            AsyncSnapshot<List<IRCChatMessage>> snapshot) {
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
            var scrollController = ScrollController();

            SchedulerBinding.instance.addPostFrameCallback((_) {
              scrollController.animateTo(
                  scrollController.position.maxScrollExtent,
                  duration: const Duration(milliseconds: 100),
                  curve: Curves.easeOut);
            });

            return Padding(
              padding: const EdgeInsets.all(10.0),
              child: ListView.builder(
                  itemCount: messages.length,
                  controller: scrollController,
                  itemBuilder: (BuildContext context, int index) {
                    var message = messages[index];

                    switch (message.chatMessageType) {
                      case IRCChatMessageType.SPECIAL:
                        var specialMessage = message as IRCChatSpecialMessage;
                        return Text(specialMessage.data.toString());
                        break;
                      case IRCChatMessageType.REGULAR:
                        return IRCNetworkChannelMessageWidget(message);
                        break;
                    }

                    throw Exception(
                        "Invalid message type = ${message.chatMessageType}");
                  }),
            );
          }
        });
  }
}

_isNeedPrint(IRCChatMessage message) {
  if (message is NetworkChannelMessage) {
    return message.type != IRCNetworkChannelMessageType.UNHANDLED &&
        message.type != IRCNetworkChannelMessageType.RAW;
  } else {
    return true;
  }
}
