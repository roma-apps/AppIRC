import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/chat_bloc.dart';
import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/widgets/channel_widget.dart';
import 'package:flutter_appirc/widgets/channels_list_widget.dart';
import 'package:logger_flutter/logger_flutter.dart';

class ChatPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final ChatBloc chatBloc = Provider.of<ChatBloc>(context);
    return Scaffold(
        appBar: AppBar(
//        title: Text(AppLocalizations.of(context).tr('chat.title')),
          title: StreamBuilder<Channel>(
            stream: chatBloc.outActiveChannel,
            builder: (BuildContext context, AsyncSnapshot<Channel> snapshot) {
              if(snapshot.data == null) {
                return Text(AppLocalizations.of(context).tr('chat.title'));
              } else {
                return Text(snapshot.data.name);
              }
            },
          ),
        ),
        body: Center(child: LogConsole()),
//        body: Center(child: ChannelWidget()),
        drawer: Drawer(child: ChannelsListWidget()));
  }
}
