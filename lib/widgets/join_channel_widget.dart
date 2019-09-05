import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/join_channel_bloc.dart';
import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/service/thelounge_service.dart';

import 'form_widgets.dart';

class JoinChannelFormWidget extends StatefulWidget {
  final Network network;
  final VoidCallback joinCallback;

  JoinChannelFormWidget(this.network, this.joinCallback);

  @override
  State<StatefulWidget> createState() =>
      JoinChannelFormState(network, joinCallback);
}

class JoinChannelFormState extends State<JoinChannelFormWidget> {
  final Network network;
  final VoidCallback connectCallback;

  JoinChannelFormState(this.network, this.connectCallback);

  final passwordController = TextEditingController();
  final channelController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final TheLoungeService loungeService =
        Provider.of<TheLoungeService>(context);

    var joinChannelBloc = JoinChannelBloc(loungeService, network);

    return Column(
      children: <Widget>[
        formTextRow(AppLocalizations.of(context).tr('join_channel.channel'),
            channelController, (value) {}),
        formTextRow(AppLocalizations.of(context).tr('join_channel.password'),
            passwordController, (value) {}),
        RaisedButton(
          child: Text(AppLocalizations.of(context).tr('join_channel.join')),
          onPressed: () {
            var password = passwordController.text;
            var channel = channelController.text;

            joinChannelBloc.joinChannel(channel, password);
            connectCallback();
          },
        )
      ],
    );
  }
}
