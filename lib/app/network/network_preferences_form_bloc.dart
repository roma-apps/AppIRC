import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_server_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/network/network_user_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/form_blocs.dart';

class ChatNetworkPreferencesFormBloc extends FormBloc {
  static const channelsNamesSeparator = " ";
  Validator<String> networkValidator;
  NetworkServerPreferencesFormBloc serverFormBloc;
  NetworkUserPreferencesFormBloc userFormBloc;

  FormValueFieldBloc<String> channelsFieldBloc;

  final ChatNetworkPreferences preferences;

  ChatNetworkPreferencesFormBloc(
    this.preferences,
    bool isNeedShowChannels,
    bool isNeedShowCommands,
      bool serverPreferencesEnabled, bool serverPreferencesVisible
  ) {
    serverFormBloc = NetworkServerPreferencesFormBloc(
        preferences.networkConnectionPreferences.serverPreferences,
        networkValidator, serverPreferencesEnabled, serverPreferencesVisible);
    userFormBloc = NetworkUserPreferencesFormBloc(
        preferences.networkConnectionPreferences.userPreferences,
        isNeedShowCommands);

    channelsFieldBloc = FormValueFieldBloc<String>(
        preferences.channelsWithoutPassword
            .map((channel) => channel.name)
            .join(channelsNamesSeparator),
        visible: isNeedShowChannels,
        validators: [NotEmptyTextValidator.instance]);
  }

  @override
  List<FormFieldBloc> get children => [serverFormBloc, userFormBloc];

  ChatNetworkPreferences extractData() => ChatNetworkPreferences(
      ChatNetworkConnectionPreferences(
        localId: preferences.localId,
          serverPreferences: serverFormBloc.extractData(),
          userPreferences: userFormBloc.extractData()),
      channelsFieldBloc.value
          .split(ChatNetworkPreferences.channelsSeparator)
          .map((channelName) => ChatNetworkChannelPreferences.name(
              name: channelName, password: ""))
          .toList());
}
