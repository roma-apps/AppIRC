import 'package:flutter_appirc/form/form_blocs.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

class LoungeAuthPreferencesFormBloc extends FormBloc {
  FormValueFieldBloc<String> usernameFieldBloc;
  FormValueFieldBloc<String> passwordFieldBloc;



  LoungeAuthPreferencesFormBloc( LoungeAuthPreferences startPreferences) {
    usernameFieldBloc = FormValueFieldBloc<String>(startPreferences?.username,
        validators: [NotEmptyTextValidator.instance, NoWhitespaceTextValidator.instance]);
    passwordFieldBloc = FormValueFieldBloc<String>(startPreferences?.password,
        validators: [NotEmptyTextValidator.instance, NoWhitespaceTextValidator.instance]);
  }

  @override
  List<FormFieldBloc> get children => [usernameFieldBloc, passwordFieldBloc];

  LoungeAuthPreferences extractData() => LoungeAuthPreferences.name(
      username: usernameFieldBloc.value, password: passwordFieldBloc.value);
}
