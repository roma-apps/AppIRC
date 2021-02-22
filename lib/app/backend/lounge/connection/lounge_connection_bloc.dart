import 'dart:async';

import 'package:flutter_appirc/app/backend/lounge/connection/form/lounge_connection_model.dart';
import 'package:flutter_appirc/app/backend/lounge/lounge_backend_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/socketio/socket_io_service.dart';
import 'package:logging/logging.dart';
import 'package:rxdart/subjects.dart';

var _logger = Logger("lounge_connection_form_bloc.dart");

class LoungeConnectionBloc extends DisposableOwner {
  final SocketIOService socketIOService;

  LoungePreferences get preferences => LoungePreferences(
        hostPreferences: hostPreferences,
        authPreferences: authPreferences,
      );

  // todo: should be final or subject
  LoungeHostPreferences hostPreferences;
  // todo: should be final or subject
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
    this.socketIOService,
    this.hostPreferences,
    this.authPreferences,
  ) {
    addDisposable(subject: _stateSubject);

    if (authPreferences == null &&
        authPreferences == LoungeAuthPreferences.empty) {
      _stateSubject = BehaviorSubject.seeded(LoungeAuthState.login);
    } else {
      _stateSubject = BehaviorSubject();
    }

    _hostInformationSubject = BehaviorSubject.seeded(
      LoungeHostInformation.notConnected(),
    );

    addDisposable(subject: _stateSubject);
    addDisposable(subject: _hostInformationSubject);
  }

  bool get isRegistrationSupported =>
      _extractIsRegistrationSupported(hostInformation);

  Stream<bool> get isRegistrationSupportedStream => hostInformationStream.map(
        (hostInformation) => _extractIsRegistrationSupported(
          hostInformation,
        ),
      );

  bool _extractIsRegistrationSupported(LoungeHostInformation hostInformation) {
    return hostInformation?.connected == true ??
        hostInformation?.registrationSupported == true;
  }

  void onAuthPreferencesChanged(LoungeAuthPreferences authPreferences) {
    this.authPreferences = authPreferences;
  }

  void onHostPreferencesChanged(LoungeHostPreferences hostPreferences) {
    var isNewValue = hostPreferences.host != this.hostPreferences.host;
    _logger.fine(() => "onHostPreferencesChanged \n"
        "isNewValue $isNewValue\n"
        "hostPreferences $hostPreferences\n");
    if (!isNewValue) {
      return;
    }
    this.hostPreferences = hostPreferences;

    _hostInformationSubject.add(
      LoungeHostInformation.notConnected(),
    );
    _stateSubject.add(null);
  }

  void onHostConnectionResult(LoungeHostPreferences hostPreferences,
      LoungeHostInformation hostInformation) {
    _logger.fine(() => "onHostConnectionResult "
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
