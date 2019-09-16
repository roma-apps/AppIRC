import 'package:flutter/cupertino.dart';
import 'package:flutter_appirc/form/form_bloc.dart';
import 'package:flutter_appirc/form/form_field_bloc.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

class LoungePreferencesFormBloc extends FormBloc {
  TextEditingController _hostController;
  FormNotEmptyTextFieldBloc hostFieldBloc;

  LoungePreferencesFormBloc(LoungePreferences loungePreferences) {
    _hostController = TextEditingController(text: loungePreferences.host);
    hostFieldBloc = FormNotEmptyTextFieldBloc(_hostController);
  }

  @override
  List<FormTextFieldBloc> get fieldBlocs => [hostFieldBloc];

  LoungePreferences extractData() =>
      LoungePreferences(host: _hostController.text);
}
