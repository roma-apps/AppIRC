import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

const String appIRCLoungeInstance = "https://demo.appirc.com/";

LoungePreferences createDefaultLoungePreferences(
        BuildContext context) =>
LoungePreferences(LoungeHostPreferences(appIRCLoungeInstance));




