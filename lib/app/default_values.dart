import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

const String appIRCLoungeInstance = "http://167.71.55.184:9000/";

LoungePreferences createDefaultLoungePreferences(
        BuildContext context) =>
LoungePreferences(LoungeHostPreferences(appIRCLoungeInstance));




