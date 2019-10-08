import 'package:flutter_appirc/app/backend/lounge/lounge_auth_preferences_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_connection_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/form_blocs.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:rxdart/rxdart.dart';

class LoungePreferencesFormBloc extends FormBloc {
  LoungeConnectionPreferencesFormBloc connectionFormBloc;
  LoungeAuthPreferencesFormBloc authPreferencesFormBloc;

  final LoungePreferences preferences;

  BehaviorSubject<bool> _isAuthFormEnabledController;

  LoungePreferencesFormBloc(this.preferences) {
    connectionFormBloc =
        LoungeConnectionPreferencesFormBloc(preferences.connectionPreferences);
    authPreferencesFormBloc =
        LoungeAuthPreferencesFormBloc(preferences.authPreferences);

//    var authBlockEnabledFromStart = preferences
//        .authPreferences != null && preferences.authPreferences !=
//        LoungeAuthPreferences.empty;
    var authBlockEnabledFromStart = false;
    _isAuthFormEnabledController =
        BehaviorSubject(seedValue: authBlockEnabledFromStart);

    addDisposable(subject: _isAuthFormEnabledController);
  }

  @override
  List<FormFieldBloc> get children {
    if (isAuthFormEnabled == true) {
      return [connectionFormBloc, authPreferencesFormBloc];
    } else {
      return [connectionFormBloc];
    }
  }

  bool get isAuthFormEnabled => _isAuthFormEnabledController?.value;

  set isAuthFormEnabled(newValue) {
    _isAuthFormEnabledController.add(newValue);
    resubscribeInternalFormsErrors();
  }

  get isAuthFormEnabledStream => _isAuthFormEnabledController.stream.distinct();

  LoungePreferences extractData() =>
      LoungePreferences(connectionFormBloc.extractData(),
          authPreferences:
              isAuthFormEnabled ? authPreferencesFormBloc.extractData() : null);
}
