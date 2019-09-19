
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/app/network/network_server_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/network/network_user_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/form_blocs.dart';

class IRCNetworkPreferencesFormBloc extends FormBloc {

   Validator<String> networkValidator;
  IRCNetworkServerPreferencesFormBloc serverFormBloc;
  IRCNetworkUserPreferencesFormBloc userFormBloc;

  FormValueFieldBloc<String>  channelsFieldBloc;

  IRCNetworkPreferencesFormBloc(
      IRCNetworkPreferences preferences,) {
    serverFormBloc = IRCNetworkServerPreferencesFormBloc(
        preferences.networkConnectionPreferences.serverPreferences,
        networkValidator);
    userFormBloc = IRCNetworkUserPreferencesFormBloc(
        preferences.networkConnectionPreferences.userPreferences);

    channelsFieldBloc = FormValueFieldBloc<String> (preferences.channelsString, validators: [NotEmptyTextValidator()]);
  }

  @override
  List<FormFieldBloc> get children => [serverFormBloc, userFormBloc];

  IRCNetworkPreferences extractData() => IRCNetworkPreferences(
      IRCNetworkConnectionPreferences(
          serverPreferences: serverFormBloc.extractData(),
          userPreferences: userFormBloc.extractData()),
      channelsFieldBloc.value
          .split(IRCNetworkPreferences.channelsSeparator)
          .map((channelName) => IRCNetworkChannelPreferences.name(
              name: channelName, password: "")).toList());
}
