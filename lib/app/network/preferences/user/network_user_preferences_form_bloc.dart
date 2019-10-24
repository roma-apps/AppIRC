import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/form/form_blocs.dart';

class NetworkUserPreferencesFormBloc extends FormBloc {
  FormValueFieldBloc<String> nickFieldBloc;
  FormValueFieldBloc<String> passwordFieldBloc;
  FormValueFieldBloc<String> realNameFieldBloc;
  FormValueFieldBloc<String> userNameFieldBloc;
  FormValueFieldBloc<String> commandsFieldBloc;

  NetworkUserPreferencesFormBloc(
      ChatNetworkUserPreferences preferences, bool isNeedShowCommands) {
    nickFieldBloc = FormValueFieldBloc<String>(preferences.nickname,
        validators: [NotEmptyTextValidator.instance, NoWhitespaceTextValidator.instance]);
    passwordFieldBloc = FormValueFieldBloc<String>(preferences.password,
        validators: [NoWhitespaceTextValidator.instance]);
    realNameFieldBloc = FormValueFieldBloc<String>(preferences.realName,
        validators: [NotEmptyTextValidator.instance]);
    userNameFieldBloc = FormValueFieldBloc<String>(preferences.username,
        validators: [NotEmptyTextValidator.instance]);
    commandsFieldBloc =
        FormValueFieldBloc<String>(preferences.commands, validators: [], visible: isNeedShowCommands);
  }

  @override
  List<FormFieldBloc> get children =>
      [nickFieldBloc, passwordFieldBloc, realNameFieldBloc, userNameFieldBloc];

  ChatNetworkUserPreferences extractData() => ChatNetworkUserPreferences(
      nickname: nickFieldBloc.value,
      password: passwordFieldBloc.value,
      realName: realNameFieldBloc.value,
      username: userNameFieldBloc.value,
      commands: commandsFieldBloc.value);
}
