import 'package:flutter/material.dart' show Icons, TextInputAction;
import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/server/network_server_preferences_form_widget.dart';
import 'package:flutter_appirc/app/network/preferences/user/network_user_preferences_form_widget.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_widget.dart';
import 'package:flutter_appirc/generated/l10n.dart';
import 'package:flutter_platform_widgets/flutter_platform_widgets.dart';
import 'package:provider/provider.dart';

class NetworkPreferencesFormWidget extends StatefulWidget {
  final NetworkPreferences startValues;
  final Function(BuildContext context, NetworkPreferences preferences) callback;
  final String buttonText;

  NetworkPreferencesFormWidget(
    this.startValues,
    this.callback,
    this.buttonText,
  );

  @override
  State<StatefulWidget> createState() => NetworkPreferencesFormWidgetState(
        startValues,
        callback,
        buttonText,
      );
}

class NetworkPreferencesFormWidgetState
    extends State<NetworkPreferencesFormWidget> {
  final Function(BuildContext context, NetworkPreferences preferences) callback;
  final NetworkPreferences startValues;
  final String buttonText;

  TextEditingController _channelsController;

  NetworkPreferencesFormWidgetState(
    this.startValues,
    this.callback,
    this.buttonText,
  ) {
    _channelsController = TextEditingController(
      text: startValues.channelsWithoutPassword
          .map((channel) => channel.name)
          .join(
            NetworkPreferencesFormBloc.channelsNamesSeparator,
          ),
    );
  }

  @override
  void dispose() {
    super.dispose();
    _channelsController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var formBloc = Provider.of<NetworkPreferencesFormBloc>(context);

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Column(
        children: <Widget>[
          Expanded(
            child: ListView(
              children: <Widget>[
                formBloc.serverFormBloc.visible
                    ? Provider.value(
                        value: formBloc.serverFormBloc,
                        child: NetworkServerPreferencesFormWidget(
                          startValues
                              .networkConnectionPreferences.serverPreferences,
                        ),
                      )
                    : SizedBox.shrink(),
                Provider.value(
                  value: formBloc.userFormBloc,
                  child: NetworkUserPreferencesFormWidget(
                    startValues.networkConnectionPreferences.userPreferences,
                  ),
                ),
                buildFormTextRow(
                  context: context,
                  bloc: formBloc.channelsFieldBloc,
                  controller: _channelsController,
                  icon: Icons.list,
                  label: S
                      .of(context)
                      .irc_connection_preferences_field_channels_label,
                  hint: S
                      .of(context)
                      .irc_connection_preferences_field_channels_hint,
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

              return PlatformButton(
                child: Text(
                  buttonText,
                ),
                onPressed: pressed,
              );
            },
          ),
        ],
      ),
    );
  }
}
