import 'package:flutter_appirc/form/form_blocs.dart';

import 'network_model.dart';

class IRCNetworkServerPreferencesFormBloc extends FormBloc {
  final Validator<String> networkValidator;

  FormValueFieldBloc<String> nameFieldBloc;
  FormValueFieldBloc<String> hostFieldBloc;
  FormValueFieldBloc<String> portFieldBloc;
  FormValueFieldBloc<bool> tlsFieldBloc;
  FormValueFieldBloc<bool> trustedFieldBloc;

  IRCNetworkServerPreferencesFormBloc(
      IRCNetworkServerPreferences preferences, this.networkValidator) {
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

  IRCNetworkServerPreferences extractData() => IRCNetworkServerPreferences(
      name: nameFieldBloc.value,
      serverHost: hostFieldBloc.value,
      serverPort: portFieldBloc.value,
      useTls: tlsFieldBloc.value,
      useOnlyTrustedCertificates: trustedFieldBloc.value);
}
