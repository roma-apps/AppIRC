import 'package:flutter_appirc/app/network/preferences/server/network_server_preferences_model.dart';
import 'package:flutter_appirc/form/field/form_field_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_validation.dart';
import 'package:flutter_appirc/form/form_bloc.dart';
import 'package:flutter_appirc/form/form_validation.dart';
import 'package:flutter_appirc/form/form_value_field_bloc.dart';

class NetworkServerPreferencesFormBloc extends FormBloc {
  final Validator<String> networkValidator;

  FormValueFieldBloc<String> nameFieldBloc;
  FormValueFieldBloc<String> hostFieldBloc;
  FormValueFieldBloc<String> portFieldBloc;
  FormValueFieldBloc<bool> tlsFieldBloc;
  FormValueFieldBloc<bool> trustedFieldBloc;

  final bool enabled;
  final bool visible;

  NetworkServerPreferencesFormBloc(NetworkServerPreferences preferences,
      this.networkValidator, this.enabled, this.visible) {
    nameFieldBloc = FormValueFieldBloc<String>(preferences.name,
        validators: [
          NoWhitespaceTextValidator.instance,
          NotEmptyTextValidator.instance
        ],
        enabled: enabled,
        visible: visible);

    hostFieldBloc = FormValueFieldBloc<String>(preferences.serverHost,
        validators: [
          NoWhitespaceTextValidator.instance,
          NotEmptyTextValidator.instance
        ],
        enabled: enabled,
        visible: visible);
    portFieldBloc = FormValueFieldBloc<String>(preferences.serverPort,
        validators: [
          NoWhitespaceTextValidator.instance,
          NotEmptyTextValidator.instance
        ],
        enabled: enabled,
        visible: visible);

    tlsFieldBloc = FormValueFieldBloc<bool>(preferences.useTls,
        enabled: enabled, visible: visible);
    trustedFieldBloc = FormValueFieldBloc<bool>(
        preferences.useOnlyTrustedCertificates,
        enabled: enabled,
        visible: visible);
  }

  @override
  List<FormFieldBloc> get children =>
      [nameFieldBloc, hostFieldBloc, portFieldBloc];

  NetworkServerPreferences extractData() => NetworkServerPreferences(
      name: nameFieldBloc.value,
      serverHost: hostFieldBloc.value,
      serverPort: portFieldBloc.value,
      useTls: tlsFieldBloc.value,
      useOnlyTrustedCertificates: trustedFieldBloc.value);
}
