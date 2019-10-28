import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart' show Icons, TextInputAction;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/join_channel/network_join_channel_form_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_widget.dart';
import 'package:flutter_appirc/provider/provider.dart';

class NetworkJoinChannelFormWidget extends StatefulWidget {
  final String startChannelName;
  final String startPassword;

  NetworkJoinChannelFormWidget.name({@required this.startChannelName, @required  this
      .startPassword});

  @override
  State<StatefulWidget> createState() =>
      NetworkJoinChannelFormWidgetState(startChannelName, startPassword);
}

class NetworkJoinChannelFormWidgetState
    extends State<NetworkJoinChannelFormWidget> {
  final String startChannelName;
  final String startPassword;

  TextEditingController _channelController;
  TextEditingController _passwordController;

  NetworkJoinChannelFormWidgetState(this.startChannelName, this.startPassword) {
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
    NetworkJoinChannelFormBloc formBloc =
        Provider.of<NetworkJoinChannelFormBloc>(context);

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
