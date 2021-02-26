import 'dart:async';

import 'package:flutter_appirc/app/backend/lounge/connect/lounge_backend_connect_model.dart';
import 'package:flutter_appirc/app/backend/lounge/connection/lounge_connection_model.dart';
import 'package:flutter_appirc/disposable/disposable_owner.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/socket_io/socket_io_service.dart';
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
  BehaviorSubject<LoungeConnectDetails> _loungeConnectDetailsSubject;

  LoungeConnectDetails get hostInformation =>
      _loungeConnectDetailsSubject?.value;

  Stream<LoungeConnectDetails> get hostInformationStream =>
      _loungeConnectDetailsSubject.stream;

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

    _loungeConnectDetailsSubject = BehaviorSubject();

    addDisposable(subject: _stateSubject);
    addDisposable(subject: _loungeConnectDetailsSubject);
  }

  bool get isRegistrationSupported =>
      _extractIsRegistrationSupported(hostInformation);

  Stream<bool> get isRegistrationSupportedStream => hostInformationStream.map(
        (hostInformation) => _extractIsRegistrationSupported(
          hostInformation,
        ),
      );

  bool _extractIsRegistrationSupported(LoungeConnectDetails hostInformation) {
    return hostInformation
            ?.privatePart?.signUpAvailableResponseBody?.signUpAvailable ==
        true;
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

    _loungeConnectDetailsSubject.add(null);
    _stateSubject.add(null);
  }

  void onHostConnectionResult(LoungeHostPreferences hostPreferences,
      LoungeConnectDetails hostInformation) {
    _logger.fine(() => "onHostConnectionResult "
        "hostInformation $hostInformation");
    if (hostInformation == null) {
      return;
    }

    hostInformation = hostInformation;
    var connected = hostInformation.connected;
    _loungeConnectDetailsSubject.add(hostInformation);

    if (connected && hostInformation.isPrivateMode && state == null) {
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
