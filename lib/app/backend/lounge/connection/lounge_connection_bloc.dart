import 'dart:async';

import 'package:adhara_socket_io/adhara_socket_io.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/form/lounge_connection_model.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_model.dart';
import 'package:flutter_appirc/logger/logger.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';
import 'package:rxdart/subjects.dart';

MyLogger _logger =
    MyLogger(logTag: "lounge_connection_form_bloc.dart", enabled: true);

class LoungeConnectionBloc extends Providable {
  final SocketIOManager socketIOManager;

  LoungePreferences get preferences => LoungePreferences.name(
      hostPreferences: hostPreferences, authPreferences: authPreferences);

  LoungeHostPreferences hostPreferences;
  LoungeAuthPreferences authPreferences;

  // ignore: close_sinks
  BehaviorSubject<LoungeAuthState> _stateSubject;

  LoungeAuthState get state => _stateSubject?.value;

  Stream<LoungeAuthState> get stateStream => _stateSubject.stream;

  // ignore: close_sinks
  BehaviorSubject<LoungeHostInformation> _hostInformationSubject;

  LoungeHostInformation get hostInformation => _hostInformationSubject?.value;

  Stream<LoungeHostInformation> get hostInformationStream =>
      _hostInformationSubject.stream;

  bool get connected => hostInformation?.connected ?? false;

  Stream<bool> get connectedStream => hostInformationStream
      .map((hostInformation) => hostInformation?.connected ?? false);

  LoungeConnectionBloc(
      this.socketIOManager, this.hostPreferences, this.authPreferences) {
    addDisposable(subject: _stateSubject);

    if (authPreferences == null &&
        authPreferences == LoungeAuthPreferences.empty) {
      _stateSubject = BehaviorSubject.seeded(LoungeAuthState.login);
    } else {
      _stateSubject = BehaviorSubject();
    }

    _hostInformationSubject =
        BehaviorSubject.seeded(LoungeHostInformation.notConnected());

    addDisposable(subject: _stateSubject);
    addDisposable(subject: _hostInformationSubject);
  }

  bool get isRegistrationSupported =>
      _extractIsRegistrationSupported(hostInformation);

  Stream<bool> get isRegistrationSupportedStream => hostInformationStream.map(
      (hostInformation) => _extractIsRegistrationSupported(hostInformation));

  bool _extractIsRegistrationSupported(LoungeHostInformation hostInformation) {
    return hostInformation?.connected == true ??
        hostInformation?.registrationSupported == true;
  }

  onAuthPreferencesChanged(LoungeAuthPreferences authPreferences) {
    this.authPreferences = authPreferences;
  }

  onHostPreferencesChanged(LoungeHostPreferences hostPreferences) {
    var isNewValue = hostPreferences.host != this.hostPreferences.host;
    _logger.d(() => "onHostPreferencesChanged isNewValue $isNewValue"
        " hostPreferences $hostPreferences");
    if (!isNewValue) {
      return;
    }
    this.hostPreferences = hostPreferences;

    _hostInformationSubject.add(LoungeHostInformation.notConnected());
    _stateSubject.add(null);
  }

  onHostConnectionResult(LoungeHostPreferences hostPreferences,
      LoungeHostInformation hostInformation) {
    _logger.d(() => "onHostConnectionResult "
        "hostInformation $hostInformation");
    if (hostInformation == null) {
      return;
    }

    hostInformation = hostInformation;
    var connected = hostInformation.connected;
    _hostInformationSubject.add(hostInformation);

    if (connected && hostInformation.authRequired && state == null) {
      _stateSubject.add(LoungeAuthState.login);
    } else {
      _stateSubject.add(null);
    }
  }

  void switchToRegistration() {
    _stateSubject.add(LoungeAuthState.registration);
  }

  void switchToLogin() {
    _stateSubject.add(LoungeAuthState.login);
  }
}
