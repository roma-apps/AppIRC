import 'package:flutter_appirc/form/form_blocs.dart';

class IRCNetworkChannelJoinFormBloc extends FormBloc {
  FormValueFieldBloc<String> channelFieldBloc;
  FormValueFieldBloc<String> passwordFieldBloc;

  IRCNetworkChannelJoinFormBloc(
      {String startChannel = "", String startPassword = ""}) {
    channelFieldBloc = FormValueFieldBloc<String>(startChannel,
        validators: [NoWhitespaceTextValidator(), NotEmptyTextValidator()]);
    passwordFieldBloc = FormValueFieldBloc<String>(startPassword,
        validators: [NoWhitespaceTextValidator()]);
  }

  @override
  List<FormFieldBloc> get children => [channelFieldBloc, passwordFieldBloc];

  String extractChannel() => channelFieldBloc.value;

  String extractPassword() => passwordFieldBloc.value;
}
