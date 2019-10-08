import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/network/network_server_preferences_form_widget.dart';
import 'package:flutter_appirc/app/network/network_user_preferences_widget_form.dart';
import 'package:flutter_appirc/form/form_widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';

class ChatNetworkPreferencesFormWidget extends StatefulWidget {
  final ChatNetworkPreferences startValues;
  final ChatNetworkPreferencesActionCallback callback;
  final String buttonText;

  ChatNetworkPreferencesFormWidget(
      this.startValues, this.callback, this.buttonText);

  @override
  State<StatefulWidget> createState() =>
      ChatNetworkPreferencesFormWidgetState(startValues, callback, buttonText);
}

class ChatNetworkPreferencesFormWidgetState
    extends State<ChatNetworkPreferencesFormWidget> {
  final ChatNetworkPreferencesActionCallback callback;
  final ChatNetworkPreferences startValues;
  final String buttonText;

  TextEditingController _channelsController;

  ChatNetworkPreferencesFormWidgetState(
      this.startValues, this.callback, this.buttonText) {
    _channelsController = TextEditingController(
        text: startValues.channelsWithoutPassword
            .map((channel) => channel.name)
            .join(ChatNetworkPreferencesFormBloc.channelsNamesSeparator));
  }

  @override
  void dispose() {
    super.dispose();
    _channelsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    ChatNetworkPreferencesFormBloc formBloc =
        Provider.of<ChatNetworkPreferencesFormBloc>(context);

    var appLocalizations = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                formBloc.serverFormBloc.visible
                    ? Provider(
                        providable: formBloc.serverFormBloc,
                        child: ChatNetworkServerPreferencesFormWidget(
                            startValues.networkConnectionPreferences
                                .serverPreferences))
                    : SizedBox.shrink(),
                Provider(
                    providable: formBloc.userFormBloc,
                    child: NetworkUserPreferencesFormWidget(startValues
                        .networkConnectionPreferences.userPreferences)),
                buildFormTextRow(
                  context,
                  formBloc.channelsFieldBloc,
                  _channelsController,
                  Icons.list,
                  appLocalizations.tr('irc_connection.channels_title'),
                  appLocalizations.tr('irc_connection.channels_hint'),
                  textInputAction: TextInputAction.done,
                )
              ],
            ),
          ),
          StreamBuilder<bool>(
              stream: formBloc.dataValidStream,
              builder: (context, snapshot) {
                var pressed;
                var dataValid = snapshot.data != false;
                if (dataValid) {
                  pressed = () {
                    callback(context, formBloc.extractData());
                  };
                }

                return createSkinnedPlatformButton(
                  context,
                  child: Text(
                    buttonText,
                  ),
                  onPressed: pressed,
                );
              })
        ],
      ),
    );
  }
}
