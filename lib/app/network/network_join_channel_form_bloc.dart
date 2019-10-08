import 'package:flutter_appirc/form/form_blocs.dart';

class NetworkChannelJoinFormBloc extends FormBloc {
  FormValueFieldBloc<String> channelFieldBloc;
  FormValueFieldBloc<String> passwordFieldBloc;

  NetworkChannelJoinFormBloc(
      {String startChannel = "", String startPassword = ""}) {
    channelFieldBloc = FormValueFieldBloc<String>(startChannel,
        validators: [NoWhitespaceTextValidator.instance, NotEmptyTextValidator.instance]);
    passwordFieldBloc = FormValueFieldBloc<String>(startPassword,
        validators: [NoWhitespaceTextValidator.instance]);
  }

  @override
  List<FormFieldBloc> get children => [channelFieldBloc, passwordFieldBloc];

  String extractChannel() => channelFieldBloc.value;

  String extractPassword() => passwordFieldBloc.value;
}
