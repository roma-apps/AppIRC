import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

const String appIRCLoungeInstance = "https://irc.pleroma.social/";
// const String appIRCLoungeInstance = "http://localhost:9000";
// const String appIRCLoungeInstance = "https://demo.thelounge.chat/";
// const String appIRCLoungeInstance = "https://de1f8af02855.ngrok.io/";

LoungePreferences createDefaultLoungePreferences(BuildContext context) =>
    LoungePreferences(
      LoungeHostPreferences(
        host: appIRCLoungeInstance,
      ),
    );
