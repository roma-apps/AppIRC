import 'package:flutter_appirc/lounge/lounge_model.dart';

// const String appIRCLoungeInstance = "https://irc.pleroma.social/";
// const String appIRCLoungeInstance = "http://161.35.139.75:9103/";
// const String appIRCLoungeInstance = "http://161.35.139.75:9103/";
const String appIRCLoungeInstance = "http://89d8bebf742d.ngrok.io";
// const String appIRCLoungeInstance = "https://demo.thelounge.chat/";

LoungePreferences createDefaultLoungePreferences() => LoungePreferences(
      hostPreferences: LoungeHostPreferences(
        host: appIRCLoungeInstance,
      ),
      authPreferences: null,
    );
