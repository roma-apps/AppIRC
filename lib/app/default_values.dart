import 'package:flutter/widgets.dart';
import 'package:flutter_appirc/app/backend/backend_service.dart';
import 'package:flutter_appirc/app/network/network_model.dart';
import 'package:flutter_appirc/lounge/lounge_model.dart';
import 'package:flutter_appirc/provider/provider.dart';

LoungePreferences createDefaultLoungePreferences(
        BuildContext context) =>
//    LoungeConnectionPreferences(host: "https://demo.thelounge.chat/");
//LoungeConnectionPreferences(host: "https://irc.pleroma.social/");
//LoungeConnectionPreferences(host: "http://192.168.0.102:9000/");
//    LoungeConnectionPreferences(host: "http://192.168.0.103:9000/");
//    LoungeConnectionPreferences(host: "http://192.168.0.103:9000/");
//LoungePreferences(LoungeConnectionPreferences("http://192.168.1.103:9000/"));
LoungePreferences(LoungeConnectionPreferences("http://192.168.0.104:9000/"));
//LoungePreferences(LoungeConnectionPreferences("https://irc.pleroma.social/"));
//LoungePreferences(LoungeConnectionPreferences("https://demo.thelounge.chat/"));




