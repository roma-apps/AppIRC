import 'package:flutter_appirc/lounge/lounge_model.dart';

// const String appIRCLoungeInstance = "https://irc.pleroma.social/";
const String appIRCLoungeInstance = "http://973099570f9d.ngrok.io";
// const String appIRCLoungeInstance = "https://demo.thelounge.chat/";
// const String appIRCLoungeInstance = "https://de1f8af02855.ngrok.io/";

LoungePreferences createDefaultLoungePreferences() => LoungePreferences(
      hostPreferences: LoungeHostPreferences(
        host: appIRCLoungeInstance,
      ),
      authPreferences: null,
    );
