import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/channel_bloc.dart';
import 'package:flutter_appirc/blocs/chat_bloc.dart';
import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/provider.dart';

class ChannelWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ChatBloc chatBloc = Provider.of<ChatBloc>(context);

    return StreamBuilder<Channel>(
        stream: chatBloc.outActiveChannel,
        builder: (BuildContext context, AsyncSnapshot<Channel> snapshot) {
          if (snapshot.data == null) {
            return Text(AppLocalizations.of(context).tr("chat.no_active_chat"));
          } else {
            return Provider<ChannelBloc>(
              bloc: ChannelBloc(chatBloc.lounge, chatBloc, snapshot.data),
              child: Column(
                children: <Widget>[
                  Expanded(child: MessagesListChannelWidget()),
                  EnterMessageChannelWidget()
                ],
              ),
            );
          }
        });
  }
}

class MessagesListChannelWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ChannelBloc channelBloc = Provider.of<ChannelBloc>(context);

    return StreamBuilder<List<ChannelMessage>>(
        stream: channelBloc.outMessages,
        builder: (BuildContext context,
            AsyncSnapshot<List<ChannelMessage>> snapshot) {
          if (snapshot.data == null && snapshot.data.length == 0) {
            return Text(AppLocalizations.of(context).tr("chat.empty_chat"));
          } else {
            return ListView.builder(
                itemBuilder: (BuildContext context, int index) {
              ChannelMessage message = snapshot.data[index];

              return Column(
                children: <Widget>[
                  Text(message.author),
                  Text(message.text),
                ],
              );
            });
          }
        });
  }
}

class EnterMessageChannelWidget extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => EnterMessageChannelState();
}

class EnterMessageChannelState extends State<EnterMessageChannelWidget> {
  final messageController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    ChannelBloc channelBloc = Provider.of<ChannelBloc>(context);

    return Flexible(
      child: Row(
        children: <Widget>[
          TextFormField(
            controller: messageController,
            textInputAction: TextInputAction.send,
            onFieldSubmitted: (term) {
              _sendMessage(channelBloc);
            },
          ),
          IconButton(
              icon: new Icon(Icons.message),
              onPressed: _sendMessage(channelBloc)),
        ],
      ),
    );
  }

  _sendMessage(ChannelBloc channelBloc) =>
      channelBloc.sendMessage(messageController.text);
}
