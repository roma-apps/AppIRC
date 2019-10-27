import 'package:flutter_appirc/form/field/form_field_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_validation.dart';
import 'package:flutter_appirc/form/form_bloc.dart';
import 'package:flutter_appirc/form/form_value_field_bloc.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

class LoungeConnectionPreferencesFormBloc extends FormBloc {
  FormValueFieldBloc<String> hostFieldBloc;

  LoungeConnectionPreferencesFormBloc(LoungeConnectionPreferences startPreferences) {
    hostFieldBloc = FormValueFieldBloc<String>(startPreferences.host,
        validators: [NotEmptyTextValidator.instance, NoWhitespaceTextValidator.instance]);
  }

  @override
  List<FormFieldBloc> get children => [hostFieldBloc];

  LoungeConnectionPreferences extractData() =>
      LoungeConnectionPreferences.name(host: hostFieldBloc.value);
}
