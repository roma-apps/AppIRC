import 'dart:async';

import 'package:flutter_appirc/app/backend/lounge/lounge_backend_model.dart';
import 'package:flutter_appirc/form/field/form_field_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_validation.dart';
import 'package:flutter_appirc/form/form_bloc.dart';
import 'package:flutter_appirc/form/form_value_field_bloc.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:rxdart/subjects.dart';

class LoungeHostPreferencesFormBloc extends FormBloc {
  final FormValueFieldBloc<String> hostFieldBloc;

  // ignore: close_sinks
  final BehaviorSubject<LoungeHostInformation> hostInformationSubject;

  Stream<LoungeHostInformation> get hostInformationStream =>
      hostInformationSubject.stream;

  LoungeHostInformation get hostInformation => hostInformationSubject.value;

  set hostInformation(LoungeHostInformation newHostInformation) {
    hostInformationSubject.add(newHostInformation);
  }

  Stream<bool> get connectedStream => hostInformationStream
      .map((hostInformation) => hostInformation?.connected);

  bool get connected => hostInformation?.connected;

  LoungeHostPreferencesFormBloc(LoungeHostPreferences startPreferences,
      LoungeHostInformation startHostInformation)
      : hostFieldBloc = FormValueFieldBloc<String>(
          startPreferences.host,
          validators: [
            NotEmptyTextValidator.instance,
            NoWhitespaceTextValidator.instance
          ],
        ),
        hostInformationSubject = BehaviorSubject.seeded(startHostInformation) {
    addDisposable(disposable: hostFieldBloc);
    addDisposable(subject: hostInformationSubject);
  }

  @override
  List<FormFieldBloc> get children => [
        hostFieldBloc,
      ];

  LoungeHostPreferences extractData() => LoungeHostPreferences(
        host: hostFieldBloc.value,
      );
}
