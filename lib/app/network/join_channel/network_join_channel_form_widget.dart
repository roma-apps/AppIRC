import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Icons, TextInputAction;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/join_channel/network_join_channel_form_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';

class NetworkChannelJoinFormWidget extends StatefulWidget {
  final String startChannelName;
  final String startPassword;

  NetworkChannelJoinFormWidget(this.startChannelName, this.startPassword);

  @override
  State<StatefulWidget> createState() =>
      NetworkChannelJoinFormWidgetState(startChannelName, startPassword);
}

class NetworkChannelJoinFormWidgetState
    extends State<NetworkChannelJoinFormWidget> {
  final String startChannelName;
  final String startPassword;

  TextEditingController _channelController;
  TextEditingController _passwordController;

  NetworkChannelJoinFormWidgetState(this.startChannelName, this.startPassword) {
    _channelController = TextEditingController(text: startChannelName);
    _passwordController = TextEditingController(text: startPassword);
  }

  @override
  void dispose() {
    super.dispose();
    _channelController.dispose();
    _passwordController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    NetworkChannelJoinFormBloc formBloc =
        Provider.of<NetworkChannelJoinFormBloc>(context);

    var appLocalizations = AppLocalizations.of(context);
    return Column(
      children: <Widget>[
        buildFormTextRow(
          context: context,
          bloc: formBloc.channelFieldBloc,
          controller: _channelController,
          icon: Icons.add,
          label: appLocalizations
              .tr('chat.network.join_channel.field.channel.label'),
          hint: appLocalizations
              .tr('chat.network.join_channel.field.channel.hint'),
          textInputAction: TextInputAction.next,
          nextBloc: formBloc.passwordFieldBloc,
        ),
        buildFormTextRow(
            context: context,
            bloc: formBloc.passwordFieldBloc,
            controller: _passwordController,
            icon: Icons.lock,
            label: appLocalizations
                .tr('chat.network.join_channel.field.password.label'),
            hint: appLocalizations
                .tr('chat.network.join_channel.field.password.hint'),
            textInputAction: TextInputAction.done,
            obscureText: true),
      ],
    );
  }
}
