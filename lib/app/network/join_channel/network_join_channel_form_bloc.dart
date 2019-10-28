import 'package:flutter_appirc/form/field/form_field_bloc.dart';
import 'package:flutter_appirc/form/field/text/form_text_field_validation.dart';
import 'package:flutter_appirc/form/form_bloc.dart';
import 'package:flutter_appirc/form/form_value_field_bloc.dart';

class NetworkJoinChannelFormBloc extends FormBloc {
  FormValueFieldBloc<String> channelFieldBloc;
  FormValueFieldBloc<String> passwordFieldBloc;

  NetworkJoinChannelFormBloc(
      {String startChannel = "", String startPassword = ""}) {
    channelFieldBloc = FormValueFieldBloc<String>(startChannel, validators: [
      NoWhitespaceTextValidator.instance,
      NotEmptyTextValidator.instance
    ]);
    passwordFieldBloc = FormValueFieldBloc<String>(startPassword,
        validators: [NoWhitespaceTextValidator.instance]);
  }

  @override
  List<FormFieldBloc> get children => [channelFieldBloc, passwordFieldBloc];

  String extractChannel() => channelFieldBloc.value;

  String extractPassword() => passwordFieldBloc.value;
}
