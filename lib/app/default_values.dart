import 'package:flutter_appirc/lounge/lounge_model.dart';

// const String appIRCLoungeInstance = "https://irc.pleroma.social/";
const String appIRCLoungeInstance = "http://973099570f9d.ngrok.io";
// const String appIRCLoungeInstance = "https://demo.thelounge.chat/";

LoungePreferences createDefaultLoungePreferences() => LoungePreferences(
      hostPreferences: LoungeHostPreferences(
        host: appIRCLoungeInstance,
      ),
      authPreferences: null,
    );
