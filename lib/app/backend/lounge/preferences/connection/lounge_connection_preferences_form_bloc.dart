import 'package:flutter_appirc/form/form_blocs.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

class LoungeConnectionPreferencesFormBloc extends FormBloc {
  FormValueFieldBloc<String> hostFieldBloc;

  LoungeConnectionPreferencesFormBloc(LoungeConnectionPreferences loungePreferences) {
    hostFieldBloc = FormValueFieldBloc<String>(loungePreferences.host,
        validators: [NotEmptyTextValidator.instance, NoWhitespaceTextValidator.instance]);
  }

  @override
  List<FormFieldBloc> get children => [hostFieldBloc];

  LoungeConnectionPreferences extractData() =>
      LoungeConnectionPreferences.name(host: hostFieldBloc.value);
}
