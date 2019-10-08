import 'package:flutter_appirc/form/form_blocs.dart';

import 'network_model.dart';

class NetworkServerPreferencesFormBloc extends FormBloc {
  final Validator<String> networkValidator;

  FormValueFieldBloc<String> nameFieldBloc;
  FormValueFieldBloc<String> hostFieldBloc;
  FormValueFieldBloc<String> portFieldBloc;
  FormValueFieldBloc<bool> tlsFieldBloc;
  FormValueFieldBloc<bool> trustedFieldBloc;

  bool enabled;
  bool visible;

  NetworkServerPreferencesFormBloc(
      ChatNetworkServerPreferences preferences, this.networkValidator,
      bool enabled, bool visible) {
    enabled = enabled;
    visible = visible;

    nameFieldBloc = FormValueFieldBloc<String>(preferences.name,
        validators: [NoWhitespaceTextValidator(), NotEmptyTextValidator()],
        enabled: enabled,
        visible: visible);

    hostFieldBloc = FormValueFieldBloc<String>(preferences.serverHost,
        validators: [NoWhitespaceTextValidator(), NotEmptyTextValidator()],
        enabled: enabled,
        visible: visible);
    portFieldBloc = FormValueFieldBloc<String>(preferences.serverPort,
        validators: [NoWhitespaceTextValidator(), NotEmptyTextValidator()],
        enabled: enabled,
        visible: visible);

    tlsFieldBloc = FormValueFieldBloc<bool>(preferences.useTls, enabled: enabled,
        visible: visible);
    trustedFieldBloc =
        FormValueFieldBloc<bool>(preferences.useOnlyTrustedCertificates, enabled: enabled,
            visible: visible);
  }

  @override
  List<FormFieldBloc> get children =>
      [nameFieldBloc, hostFieldBloc, portFieldBloc];

  ChatNetworkServerPreferences extractData() => ChatNetworkServerPreferences(
      name: nameFieldBloc.value,
      serverHost: hostFieldBloc.value,
      serverPort: portFieldBloc.value,
      useTls: tlsFieldBloc.value,
      useOnlyTrustedCertificates: trustedFieldBloc.value);
}
