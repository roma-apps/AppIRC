import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_server_preferences_form_widget.dart';
import 'package:flutter_appirc/app/network/network_user_preferences_widget_form.dart';
import 'package:flutter_appirc/form/form_widgets.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';

import 'network_preferences_form_bloc.dart';

class IRCNetworkPreferencesFormWidget extends StatefulWidget {
  final IRCNetworkPreferences startValues;
  final PreferencesActionCallback callback;

  IRCNetworkPreferencesFormWidget(this.startValues, this.callback);

  @override
  State<StatefulWidget> createState() =>
      IRCNetworkPreferencesFormWidgetState(startValues, callback);
}

class IRCNetworkPreferencesFormWidgetState
    extends State<IRCNetworkPreferencesFormWidget> {
  final PreferencesActionCallback callback;
  final IRCNetworkPreferences startValues;

  TextEditingController _channelsController;

  IRCNetworkPreferencesFormWidgetState(this.startValues, this.callback) {
    _channelsController =
        TextEditingController(text: startValues.channelsString);
  }

  @override
  void dispose() {
    super.dispose();
    _channelsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    IRCNetworkPreferencesFormBloc formBloc =
        Provider.of<IRCNetworkPreferencesFormBloc>(context);

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
                    child: IRCNetworkServerPreferencesFormWidget(startValues
                        .networkConnectionPreferences.serverPreferences)),
                Provider(
                    providable: formBloc.userFormBloc,
                    child: IRCNetworkUserPreferencesFormWidget(startValues
                        .networkConnectionPreferences.userPreferences)),
                buildFormTextRow(
                    appLocalizations.tr('irc_connection.channels_title'),
                    appLocalizations.tr('irc_connection.channels_hint'),
                    Icons.list,
                    formBloc.channelsFieldBloc,
                    _channelsController),
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

                return PlatformButton(
                  color: Colors.redAccent,
                  disabledColor: Colors.grey,
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
