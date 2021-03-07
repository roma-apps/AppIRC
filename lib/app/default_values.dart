import 'package:flutter_appirc/lounge/lounge_model.dart';

const String appIRCLoungeInstance = "https://irc.pleroma.social/";

LoungePreferences createDefaultLoungePreferences() => LoungePreferences(
      hostPreferences: LoungeHostPreferences(
        host: appIRCLoungeInstance,
      ),
      authPreferences: null,
    );
