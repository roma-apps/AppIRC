import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/network_join_channel_form_bloc.dart';
import 'package:flutter_appirc/form/form_widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';

class IRCNetworkChannelJoinFormWidget extends StatefulWidget {
  final String startChannelName;
  final String startPassword;


  IRCNetworkChannelJoinFormWidget(this.startChannelName, this.startPassword);

  @override
  State<StatefulWidget> createState() => IRCNetworkChannelJoinFormWidgetState(startChannelName, startPassword);
}

class IRCNetworkChannelJoinFormWidgetState
    extends State<IRCNetworkChannelJoinFormWidget> {
  final String startChannelName;
  final String startPassword;

  TextEditingController _channelController;
  TextEditingController _passwordController;


  IRCNetworkChannelJoinFormWidgetState(this.startChannelName,
      this.startPassword) {
    _channelController =
        TextEditingController(text: startChannelName);
    _passwordController =
        TextEditingController(text: startPassword);

  }


  @override
  void dispose() {
    super.dispose();
    _channelController.dispose();
    _passwordController.dispose();
  }


  @override
  Widget build(BuildContext context) {
    IRCNetworkChannelJoinFormBloc formBloc =
        Provider.of<IRCNetworkChannelJoinFormBloc>(context);

    var appLocalizations = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        buildFormTextRow(
            appLocalizations.tr('join_channel.channel.label'),
            appLocalizations.tr('join_channel.channel.hint'),
            Icons.add,
            formBloc.channelFieldBloc, _channelController),
        buildFormTextRow(
            appLocalizations.tr('join_channel.password.label'),
            appLocalizations.tr('join_channel.password.hint'),
            Icons.lock,
            formBloc.passwordFieldBloc, _passwordController),
      ],
    );
  }
}
