import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_server_preferences_form_widget.dart';
import 'package:flutter_appirc/app/network/network_user_preferences_widget_form.dart';
import 'package:flutter_appirc/form/form_widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_appirc/skin/app_skin_bloc.dart';
import 'package:flutter_appirc/skin/button_skin_bloc.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'network_preferences_form_bloc.dart';

class ChatNetworkPreferencesFormWidget extends StatefulWidget {
  final ChatNetworkPreferences startValues;
  final PreferencesActionCallback callback;

  ChatNetworkPreferencesFormWidget(this.startValues, this.callback);

  @override
  State<StatefulWidget> createState() =>
      ChatNetworkPreferencesFormWidgetState(startValues, callback);
}

class ChatNetworkPreferencesFormWidgetState
    extends State<ChatNetworkPreferencesFormWidget> {
  final PreferencesActionCallback callback;
  final ChatNetworkPreferences startValues;

  TextEditingController _channelsController;

  ChatNetworkPreferencesFormWidgetState(this.startValues, this.callback) {
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
                Provider(
                    providable: formBloc.serverFormBloc,
                    child: ChatNetworkServerPreferencesFormWidget(startValues
                        .networkConnectionPreferences.serverPreferences)),
                Provider(
                    providable: formBloc.userFormBloc,
                    child: IRCNetworkUserPreferencesFormWidget(startValues
                        .networkConnectionPreferences.userPreferences)),
                buildFormTextRow(
                    context,
                    appLocalizations.tr('irc_connection.channels_title'),
                    appLocalizations.tr('irc_connection.channels_hint'),
                    Icons.list,
                    formBloc.channelsFieldBloc,
                    _channelsController)
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


                return createSkinnedPlatformButton(context,
                  child: Text(
                    AppLocalizations.of(context).tr('irc_connection.connect'),
                    style: TextStyle(color: Colors.white),
                  ),
                  onPressed: pressed,
                );
              })
        ],
      ),
    );
  }
}
