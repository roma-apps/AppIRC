import 'package:flutter_appirc/form/form_blocs.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

class LoungePreferencesFormBloc extends FormBloc {
  FormValueFieldBloc<String> hostFieldBloc;

  LoungePreferencesFormBloc(LoungePreferences loungePreferences) {
    hostFieldBloc = FormValueFieldBloc<String>(loungePreferences.host,
        validators: [NotEmptyTextValidator(), NoWhitespaceTextValidator()]);
  }

  @override
  List<FormFieldBloc> get children => [hostFieldBloc];

  LoungePreferences extractData() =>
      LoungePreferences(host: hostFieldBloc.value);
}
