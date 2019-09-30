import 'package:flutter_appirc/form/form_blocs.dart';

import 'network_model.dart';

class NetworkUserPreferencesFormBloc extends FormBloc {
  FormValueFieldBloc<String> nickFieldBloc;
  FormValueFieldBloc<String> passwordFieldBloc;
  FormValueFieldBloc<String> realNameFieldBloc;
  FormValueFieldBloc<String> userNameFieldBloc;

  NetworkUserPreferencesFormBloc(ChatNetworkUserPreferences preferences) {
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

  ChatNetworkUserPreferences extractData() => ChatNetworkUserPreferences(
      nickname: nickFieldBloc.value,
      password: passwordFieldBloc.value,
      realName: realNameFieldBloc.value,
      username: userNameFieldBloc.value);
}
