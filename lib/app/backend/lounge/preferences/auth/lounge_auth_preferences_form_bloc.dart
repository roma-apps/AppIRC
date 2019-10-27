import 'package:flutter_appirc/form/field/form_field_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_validation.dart';
import 'package:flutter_appirc/form/form_bloc.dart';
import 'package:flutter_appirc/form/form_value_field_bloc.dart';
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
