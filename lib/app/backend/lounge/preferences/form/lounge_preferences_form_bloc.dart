import 'package:flutter_appirc/app/backend/lounge/preferences/auth/lounge_auth_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/connection/lounge_connection_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/field/form_field_bloc.dart';
import 'package:flutter_appirc/form/form_bloc.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:rxdart/rxdart.dart';

final bool _authBlockEnabledFromStart = false;

class LoungePreferencesFormBloc extends FormBloc {
  LoungeConnectionPreferencesFormBloc _connectionFormBloc;
  LoungeAuthPreferencesFormBloc _authPreferencesFormBloc;

  LoungeConnectionPreferencesFormBloc get connectionFormBloc =>
      _connectionFormBloc;

  LoungeAuthPreferencesFormBloc get authPreferencesFormBloc =>
      _authPreferencesFormBloc;

  final LoungePreferences _startPreferences;

  BehaviorSubject<bool> _isAuthFormEnabledController;

  LoungePreferencesFormBloc(this._startPreferences) {
    _connectionFormBloc = LoungeConnectionPreferencesFormBloc(
        _startPreferences.connectionPreferences);
    _authPreferencesFormBloc =
        LoungeAuthPreferencesFormBloc(_startPreferences.authPreferences);

    _isAuthFormEnabledController =
        BehaviorSubject(seedValue: _authBlockEnabledFromStart);

    addDisposable(subject: _isAuthFormEnabledController);
  }

  @override
  List<FormFieldBloc> get children {
    if (isAuthFormEnabled) {
      return [connectionFormBloc, authPreferencesFormBloc];
    } else {
      return [connectionFormBloc];
    }
  }

  bool get isAuthFormEnabled => _isAuthFormEnabledController?.value ?? false;

  get isAuthFormEnabledStream => _isAuthFormEnabledController.stream.distinct();

  set isAuthFormEnabled(newValue) {
    _isAuthFormEnabledController.add(newValue);
    resubscribeInternalFormsErrors();
  }

  LoungePreferences extractData() =>
      LoungePreferences(connectionFormBloc.extractData(),
          authPreferences:
              isAuthFormEnabled ? authPreferencesFormBloc.extractData() : null);
}
