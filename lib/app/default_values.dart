import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';

const String appIRCLoungeInstance = "https://demo.appirc.com/";
//const String appIRCLoungeInstance = "http://192.168.0.105:9000/";
//const String appIRCLoungeInstance = "http://167.71.55.184:9000/";
//const String appIRCLoungeInstance = "http://aa378c3f.ngrok.io/";

LoungePreferences createDefaultLoungePreferences(
        BuildContext context) =>
LoungePreferences(LoungeHostPreferences(appIRCLoungeInstance));




