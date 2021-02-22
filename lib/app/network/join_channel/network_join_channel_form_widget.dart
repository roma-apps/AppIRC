import 'package:flutter/material.dart' show Icons, TextInputAction;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/join_channel/network_join_channel_form_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_widget.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:provider/provider.dart';

class NetworkJoinChannelFormWidget extends StatefulWidget {
  final String startChannelName;
  final String startPassword;

  NetworkJoinChannelFormWidget({
    @required this.startChannelName,
    @required this.startPassword,
  });

  @override
  State<StatefulWidget> createState() => NetworkJoinChannelFormWidgetState(
        startChannelName,
        startPassword,
      );
}

class NetworkJoinChannelFormWidgetState
    extends State<NetworkJoinChannelFormWidget> {
  final String startChannelName;
  final String startPassword;

  TextEditingController _channelController;
  TextEditingController _passwordController;

  NetworkJoinChannelFormWidgetState(
    this.startChannelName,
    this.startPassword,
  ) {
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
    var formBloc = Provider.of<NetworkJoinChannelFormBloc>(context);

    return Column(
      children: <Widget>[
        buildFormTextRow(
          context: context,
          bloc: formBloc.channelFieldBloc,
          controller: _channelController,
          icon: Icons.add,
          label: S.of(context).chat_network_join_channel_field_channel_label,
          hint: S.of(context).chat_network_join_channel_field_channel_hint,
          textInputAction: TextInputAction.next,
          nextBloc: formBloc.passwordFieldBloc,
        ),
        buildFormTextRow(
          context: context,
          bloc: formBloc.passwordFieldBloc,
          controller: _passwordController,
          icon: Icons.lock,
          label: S.of(context).chat_network_join_channel_field_password_label,
          hint: S.of(context).chat_network_join_channel_field_password_hint,
          textInputAction: TextInputAction.done,
          obscureText: true,
        ),
      ],
    );
  }
}
