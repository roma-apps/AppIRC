import 'package:flutter_appirc/app/backend/lounge/lounge_backend_model.dart';
import 'package:flutter_appirc/form/field/form_field_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_validation.dart';
import 'package:flutter_appirc/form/form_bloc.dart';
import 'package:flutter_appirc/form/form_value_field_bloc.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:rxdart/rxdart.dart';

class LoungeHostPreferencesFormBloc extends FormBloc {
  FormValueFieldBloc<String> hostFieldBloc;

  // ignore: close_sinks
  BehaviorSubject<LoungeHostInformation> _hostInformationSubject =
      BehaviorSubject(seedValue: null);

  Stream<LoungeHostInformation> get hostInformationStream =>
      _hostInformationSubject.stream;

  LoungeHostInformation get hostInformation => _hostInformationSubject.value;

  set hostInformation(LoungeHostInformation newHostInformation) {
    _hostInformationSubject.add(newHostInformation);
  }

  Stream<bool> get connectedStream => hostInformationStream
      .map((hostInformation) => hostInformation?.connected);

  bool get connected => hostInformation?.connected;

  LoungeHostPreferencesFormBloc(LoungeHostPreferences startPreferences,
      LoungeHostInformation startHostInformation) {
    hostFieldBloc = FormValueFieldBloc<String>(startPreferences.host,
        validators: [
          NotEmptyTextValidator.instance,
          NoWhitespaceTextValidator.instance
        ]);

    _hostInformationSubject = BehaviorSubject(seedValue: startHostInformation);

    addDisposable(subject: _hostInformationSubject);
  }

  @override
  List<FormFieldBloc> get children => [hostFieldBloc];

  LoungeHostPreferences extractData() =>
      LoungeHostPreferences.name(host: hostFieldBloc.value);
}
