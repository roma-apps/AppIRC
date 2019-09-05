import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/channel_bloc.dart';
import 'package:flutter_appirc/blocs/chat_bloc.dart';
import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/provider.dart';

//final dateFormat = new DateFormat('yyyy-MM-dd hh:mm');

class TopicTitleWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    ChannelTopicBloc bloc = Provider.of<ChannelTopicBloc>(context);
    return StreamBuilder<String>(
      stream: bloc.outTopic,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        var topic = snapshot.data;
        var channelName = bloc.channel.name;
        if (topic == null || topic.isEmpty) {
          return Text(channelName);
        } else {
          var captionStyle = Theme.of(context).textTheme.caption;
          var topicStyle = captionStyle.copyWith(color: Colors.white);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text(channelName),
              Text(topic, style: topicStyle)
            ],
          );
        }
      },
    );
  }
}

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
              bloc: ChannelBloc(chatBloc.lounge, snapshot.data),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  Expanded(child: MessagesListChannelWidget()),
                  Container(
                    decoration: BoxDecoration(color: Colors.red),
                      child: EnterMessageChannelWidget())
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
          if (snapshot.data == null || snapshot.data.length == 0) {
            return Text(AppLocalizations.of(context).tr("chat.empty_chat"));
          } else {
            return Padding(
              padding: const EdgeInsets.all(20.0),
              child: ListView.builder(
                  itemCount: snapshot.data.length,
                  itemBuilder: (BuildContext context, int index) {
                    ChannelMessage message = snapshot.data[index];

                    if (message.text == null) {
                      message.text = "";
                    }
                    if (message.author == null) {
                      message.author = "";
                    }
                    return Container(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Row(
                              children: <Widget>[
                                Text(
                                  message.author,
                                  style: Theme.of(context).textTheme.body2,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(
                                    message.date.toString(),
                                    style: Theme.of(context).textTheme.body2,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(2.0),
                            child: Column(
                              children: <Widget>[
                                Text(message.type),
                                Text(message.text),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
            );
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

    return Row(
      children: <Widget>[
        Flexible(
          child: TextFormField(
            controller: messageController,
            textInputAction: TextInputAction.send,
            onFieldSubmitted: (term) {
              _sendMessage(channelBloc);
            },
          ),
        ),
        IconButton(
            icon: new Icon(Icons.message),
            onPressed: () {
              _sendMessage(channelBloc);
            }),
      ],
    );
  }

  _sendMessage(ChannelBloc channelBloc) =>
      channelBloc.sendMessage(messageController.text);
}
