import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_appirc/blocs/async_operation_bloc.dart';
import 'package:flutter_appirc/blocs/join_channel_bloc.dart';
import 'package:flutter_appirc/models/chat_model.dart';
import 'package:flutter_appirc/provider.dart';
import 'package:flutter_appirc/service/lounge_service.dart';
import 'package:flutter_appirc/widgets/loading_button_widget.dart';

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
    final LoungeService loungeService =
        Provider.of<LoungeService>(context);

    var joinChannelBloc = JoinChannelBloc(loungeService, network);

    return Column(
      children: <Widget>[
        formTextRow(AppLocalizations.of(context).tr('join_channel.channel'),
            channelController, (value) {}),
        formTextRow(AppLocalizations.of(context).tr('join_channel.password'),
            passwordController, (value) {}),
        Provider<AsyncOperationBloc>(
          bloc: joinChannelBloc,
          child: LoadingButtonWidget(
            child: Text(AppLocalizations.of(context).tr('join_channel.join')),
            onPressed: () {
              sendJoinChannelMessage(joinChannelBloc);
            },
          ),
        )
      ],
    );
  }

  void sendJoinChannelMessage(JoinChannelBloc joinChannelBloc) async {
      var password = passwordController.text;
    var channel = channelController.text;
    
    await joinChannelBloc.sendJoinChannelRequest(channel, password);
    connectCallback();
  }
}
