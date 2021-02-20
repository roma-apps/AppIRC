import 'package:flutter_appirc/app/backend/lounge/connection/form/lounge_connection_model.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/login/lounge_login_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/lounge_connection_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/registration/lounge_registration_form_bloc.dart';
import 'package:flutter_appirc/app/backend/lounge/preferences/host/lounge_host_preferences_form_bloc.dart';
import 'package:flutter_appirc/form/field/form_field_bloc.dart';
import 'package:flutter_appirc/form/form_bloc.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

class LoungeConnectionFormBloc extends FormBloc {
  final LoungeConnectionBloc connectionBloc;

  LoungeHostPreferencesFormBloc hostFormBloc;
  LoungeLoginFormBloc loginFormBloc;
  LoungeRegistrationFormBloc registrationFormBloc;

  bool get isRegistrationSupported =>
      hostFormBloc?.hostInformation?.registrationSupported ?? false;

  LoungeConnectionFormBloc(this.connectionBloc) {
    var startPreferences = connectionBloc.preferences;

    hostFormBloc = LoungeHostPreferencesFormBloc(
        startPreferences.hostPreferences, connectionBloc.hostInformation);
    loginFormBloc = LoungeLoginFormBloc(startPreferences.authPreferences);
    registrationFormBloc =
        LoungeRegistrationFormBloc(startPreferences.authPreferences);

    addDisposable(streamSubscription: loginFormBloc.usernameFieldBloc
        .valueStream.listen(_onAuthChanged));
    addDisposable(streamSubscription: loginFormBloc.passwordFieldBloc
        .valueStream.listen(_onAuthChanged));

    addDisposable(streamSubscription: registrationFormBloc.usernameFieldBloc
        .valueStream.listen(_onAuthChanged));
    addDisposable(streamSubscription: registrationFormBloc.passwordFieldBloc
        .valueStream.listen(_onAuthChanged));

    addDisposable(
        streamSubscription: hostFormBloc.hostFieldBloc.valueStream.listen((_) {
      connectionBloc.onHostPreferencesChanged(extractHostPreferences());
    }));

  }

  void _onAuthChanged(_) {
    connectionBloc.onAuthPreferencesChanged(_extractCurrentAuthPreferences());
  }

  @override
  List<FormFieldBloc> get children {
    var children = <FormFieldBloc>[hostFormBloc];

    switch (connectionBloc.state) {
      case LoungeAuthState.login:
        children.add(loginFormBloc);
        break;
      case LoungeAuthState.registration:
        children.add(registrationFormBloc);
        break;
    }

    return children;
  }

  LoungePreferences extractData() => LoungePreferences(extractHostPreferences(),
      authPreferences: _extractCurrentAuthPreferences());

  LoungeAuthPreferences _extractCurrentAuthPreferences() {
    switch (connectionBloc.state) {
      case LoungeAuthState.login:
        return loginFormBloc.extractData();
        break;
      case LoungeAuthState.registration:
        return registrationFormBloc.extractData();
        break;
      default:
        return null;
    }
  }

  LoungeHostPreferences extractHostPreferences() => hostFormBloc.extractData();


}
