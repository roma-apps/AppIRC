import 'package:flutter_appirc/form/form_blocs.dart';

import 'network_model.dart';

class ChatNetworkServerPreferencesFormBloc extends FormBloc {
  final Validator<String> networkValidator;

  FormValueFieldBloc<String> nameFieldBloc;
  FormValueFieldBloc<String> hostFieldBloc;
  FormValueFieldBloc<String> portFieldBloc;
  FormValueFieldBloc<bool> tlsFieldBloc;
  FormValueFieldBloc<bool> trustedFieldBloc;

  ChatNetworkServerPreferencesFormBloc(
      ChatNetworkServerPreferences preferences, this.networkValidator) {
    nameFieldBloc = FormValueFieldBloc<String>(preferences.name,
        validators: [NoWhitespaceTextValidator(), NotEmptyTextValidator()]);

    hostFieldBloc = FormValueFieldBloc<String>(preferences.serverHost,
        validators: [NoWhitespaceTextValidator(), NotEmptyTextValidator()]);
    portFieldBloc = FormValueFieldBloc<String>(preferences.serverPort,
        validators: [NoWhitespaceTextValidator(), NotEmptyTextValidator()]);

    tlsFieldBloc = FormValueFieldBloc<bool>(preferences.useTls);
    trustedFieldBloc =
        FormValueFieldBloc<bool>(preferences.useOnlyTrustedCertificates);
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
