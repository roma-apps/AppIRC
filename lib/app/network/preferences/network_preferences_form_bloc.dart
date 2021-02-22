import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/channel/preferences/channel_preferences_model.dart';
import 'package:flutter_appirc/app/network/list/network_list_bloc.dart';
import 'package:flutter_appirc/app/network/preferences/network_preferences_model.dart';
import 'package:flutter_appirc/app/network/preferences/server/network_server_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/network/preferences/user/network_user_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/field/form_field_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_validation.dart';
import 'package:flutter_appirc/form/form_bloc.dart';
import 'package:flutter_appirc/form/form_validation.dart';
import 'package:flutter_appirc/form/form_value_field_bloc.dart';

class NetworkPreferencesFormBloc extends FormBloc {
  static const channelsNamesSeparator = " ";
  final Validator<String> networkValidator;
  NetworkServerPreferencesFormBloc serverFormBloc;
  NetworkUserPreferencesFormBloc userFormBloc;

  final bool serverPreferencesVisible;

  FormValueFieldBloc<String> channelsFieldBloc;

  final NetworkPreferences preferences;

  NetworkPreferencesFormBloc({
    @required this.preferences,
    @required this.networkValidator,
    @required bool isNeedShowChannels,
    @required bool isNeedShowCommands,
    @required bool serverPreferencesEnabled,
    @required this.serverPreferencesVisible,
  }) {
    serverFormBloc = NetworkServerPreferencesFormBloc(
      preferences.networkConnectionPreferences.serverPreferences,
      networkValidator,
      serverPreferencesEnabled,
      serverPreferencesVisible,
    );
    userFormBloc = NetworkUserPreferencesFormBloc(
      preferences.networkConnectionPreferences.userPreferences,
      isNeedShowCommands,
    );

    channelsFieldBloc = FormValueFieldBloc<String>(
      preferences.channelsWithoutPassword
          .map((channel) => channel.name)
          .join(channelsNamesSeparator),
      visible: isNeedShowChannels,
      validators: [
        NotEmptyTextValidator.instance,
      ],
    );
  }

  @override
  List<FormFieldBloc> get children {
    return serverPreferencesVisible
        ? [
            serverFormBloc,
            userFormBloc,
          ]
        : [
            userFormBloc,
          ];
  }

  NetworkPreferences extractData() => NetworkPreferences(
      NetworkConnectionPreferences(
          localId: preferences.localId,
          serverPreferences: serverFormBloc.extractData(),
          userPreferences: userFormBloc.extractData()),
      channelsFieldBloc.value
          .split(NetworkPreferences.channelsSeparator)
          .map(
            (channelName) => ChannelPreferences(
              name: channelName,
              password: "",
            ),
          )
          .toList());
}

CustomValidator<String> buildNetworkValidator(NetworkListBloc networkListBloc) {
  var networkValidator = CustomValidator<String>(
    (networkName) async {
      var alreadyExist =
          await networkListBloc.isNetworkWithNameExist(networkName);
      ValidationError error;
      if (alreadyExist) {
        error = NotUniqueTextValidationError();
      }
      return error;
    },
  );
  return networkValidator;
}
