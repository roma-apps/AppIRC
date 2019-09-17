import 'package:flutter_appirc/form/form_blocs.dart';

import 'irc_network_model.dart';

class IRCNetworkUserPreferencesFormBloc extends FormBloc {
  FormValueFieldBloc<String> nickFieldBloc;
  FormValueFieldBloc<String> passwordFieldBloc;
  FormValueFieldBloc<String> realNameFieldBloc;
  FormValueFieldBloc<String> userNameFieldBloc;

  IRCNetworkUserPreferencesFormBloc(IRCNetworkUserPreferences preferences) {
    nickFieldBloc = FormValueFieldBloc<String>(
        preferences.nickname,
        validators: [NotEmptyTextValidator(), NoWhitespaceTextValidator()]);
    passwordFieldBloc = FormValueFieldBloc<String>(preferences.password, validators: [NoWhitespaceTextValidator()]);
    realNameFieldBloc = FormValueFieldBloc<String>(preferences.realName, validators: [NotEmptyTextValidator()]);
    userNameFieldBloc = FormValueFieldBloc<String>(preferences.username, validators: [NotEmptyTextValidator()]);
  }

  @override
  List<FormFieldBloc> get children =>
      [nickFieldBloc, passwordFieldBloc, realNameFieldBloc, userNameFieldBloc];

  IRCNetworkUserPreferences extractData() => IRCNetworkUserPreferences(
      nickname: nickFieldBloc.value,
      password: passwordFieldBloc.value,
      realName: realNameFieldBloc.value,
      username: userNameFieldBloc.value);
}
