import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

LoungeConnectionPreferences createDefaultLoungePreferences(
        BuildContext context) =>
//    LoungeConnectionPreferences(host: "https://demo.thelounge.chat/");
//LoungeConnectionPreferences(host: "https://irc.pleroma.social/");
LoungeConnectionPreferences(host: "http://192.168.0.102:9000/");
//    LoungeConnectionPreferences(host: "http://192.168.0.103:9000/");
//    LoungeConnectionPreferences(host: "http://192.168.0.103:9000/");
//LoungePreferences(host: "http://192.168.1.103:9000/");




